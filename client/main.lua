local QBCore = exports['qb-core']:GetCoreObject()
local isVisible = false

local FullyLoaded = LocalPlayer.state.isLoggedIn

AddStateBagChangeHandler('isLoggedIn', nil, function(_, _, value)
    FullyLoaded = value
end)

local function nuiHandler(val)
    isVisible = val
    SetNuiFocus(val, val)
end

local function openBankUI(isAtm)
    SendNUIMessage({action = "setLoading", status = true})
    nuiHandler(true)
    QBCore.Functions.TriggerCallback('renewed-banking:server:initalizeBanking', function(result)
        if not result then
            nuiHandler(false)
            QBCore.Functions.Notify(Lang:t("notify.loading_failed"), 'error', 7500)
            return
        end
        SetTimeout(1000, function()
            SendNUIMessage({
                action = "setVisible",
                status = isVisible,
                accounts = result,
                loading = false,
                atm = isAtm
            })
        end)
    end)
end

RegisterNetEvent("Renewed-Banking:client:openBankUI", function(data)
    local txt = data.atm and 'Opening ATM' or 'Opening Bank'
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_ATM", 0, 1)
    QBCore.Functions.Progressbar('Renewed-Banking', txt, math.random(3000,5000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        openBankUI(data.atm)
        Wait(500)
        ClearPedTasksImmediately(PlayerPedId())
    end, function()
        ClearPedTasksImmediately(PlayerPedId())
        QBCore.Functions.Notify('Cancelled...', 'error', 7500)
    end)
end)

RegisterNUICallback("closeInterface", function(_, cb)
    nuiHandler(false)
    cb("ok")
end)

RegisterCommand("closeBankUI", function() nuiHandler(false) end)

local bankActions = {"deposit", "withdraw", "transfer"}
CreateThread(function ()
    for k=1, #bankActions do
        RegisterNUICallback(bankActions[k], function(data, cb)
            local pushingP = promise.new()
            QBCore.Functions.TriggerCallback("Renewed-Banking:server:"..bankActions[k], function(result)
                pushingP:resolve(result)
            end, data)
            local newTransaction = Citizen.Await(pushingP)
            cb(newTransaction)
        end)
    end

    exports['qb-target']:AddTargetModel(config.atms,{
        options = {{
            type = "client",
            event = "Renewed-Banking:client:openBankUI",
            icon = "fas fa-money-check",
            label = Lang:t("menu.view_bank"),
            entity = entity,
            atm = true
        }},
        distance = 1.5
    })
end)

local pedSpawned = false
local bankPeds = {}
local blips = {}
local function createPeds()
    if pedSpawned then return end
    for k=1, #config.peds do
        local model = joaat(config.peds[k].model)

        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local coords = config.peds[k].coords
        bankPeds[k] = CreatePed(0, model, coords.x, coords.y, coords.z-1, coords.w, false, false)

        TaskStartScenarioInPlace(bankPeds[k], 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
        FreezeEntityPosition(bankPeds[k], true)
        SetEntityInvincible(bankPeds[k], true)
        SetBlockingOfNonTemporaryEvents(bankPeds[k], true)

        exports['qb-target']:AddTargetEntity(bankPeds[k], {
            options = {
                {
                    type = "client",
                    event = "Renewed-Banking:client:openBankUI",
                    icon = "fas fa-money-check",
                    label = Lang:t("menu.view_bank"),
                    entity = entity,
                    atm = false
                },
                {
                    type = "client",
                    event = "Renewed-Banking:client:accountManagmentMenu",
                    icon = "fas fa-money-check",
                    label = Lang:t("menu.manage_bank")
                }
            },
            distance = 2.0
        })


        blips[k] = AddBlipForCoord(coords.x, coords.y, coords.z-1, coords.w)
        SetBlipSprite(blips[k], 108)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], 0.80)
        SetBlipColour (blips[k], 2)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bank")
        EndTextCommandSetBlipName(blips[k])
    end

    pedSpawned = true
end

local function deletePeds()
    if not pedSpawned then return end
    for k=1, #bankPeds do
        DeletePed(bankPeds[k])
        RemoveBlip(blips[k])
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(100)
    createPeds()
    SendNUIMessage({
        action = "updateLocale",
        translations = Translations.ui,
    })
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    Wait(100)
    deletePeds()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
    	Wait(100)
        deletePeds()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        if FullyLoaded then
            createPeds()
            SendNUIMessage({
                action = "updateLocale",
                translations = Translations.ui,
            })
        end
    end
end)

RegisterNetEvent("Renewed-Banking:client:sendNotification", function(msg)
    if not msg then return end
    SendNUIMessage({
        action = "notify",
        status = msg,
    })
end)

RegisterNetEvent('Renewed-Banking:client:accountManagmentMenu', function(data)
    local table = {
        {
            isMenuHeader = true,
            header = Lang:t("menu.bank_name")
        },
        {
            header = Lang:t("menu.create_account"),
            txt = Lang:t("menu.create_account_txt"),
            params = {
                event = 'Renewed-Banking:client:createAccountMenu'
            }
        },
        {
            header = Lang:t("menu.manage_account"),
            txt = Lang:t("menu.manage_account_txt"),
            params = {
                event = 'Renewed-Banking:client:viewAccountsMenu'
            }
        }
    }
    exports['qb-menu']:openMenu(table)
end)

RegisterNetEvent('Renewed-Banking:client:createAccountMenu', function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = Lang:t("menu.bank_name"),
        submitText = Lang:t("menu.create_account"),
        inputs = {
            {
                text = Lang:t("menu.account_id"),
                name = "accountid",
                type = "text",
                isRequired = true
            }
        }
    })
    if dialog and dialog.accountid then
        dialog.accountid = dialog.accountid:lower():gsub("%s+", "")
        TriggerServerEvent("Renewed-Banking:server:createNewAccount", dialog.accountid)
    end
end)

RegisterNetEvent('Renewed-Banking:client:viewAccountsMenu', function(data)
    TriggerServerEvent("Renewed-Banking:server:getPlayerAccounts")
end)

RegisterNetEvent('Renewed-Banking:client:addAccountMember', function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = Lang:t("menu.bank_name"),
        submitText = Lang:t("menu.add_account_member"),
        inputs = {
            {
                text = Lang:t("menu.citizen_id"),
                name = "accountid",
                type = "text",
                isRequired = true
            }
        }
    })
    if dialog and dialog.accountid then
        dialog.accountid = dialog.accountid:upper():gsub("%s+", "")
        TriggerServerEvent("Renewed-Banking:server:addAccountMember", data.account, dialog.accountid)
    end
end)

RegisterNetEvent('Renewed-Banking:client:changeAccountName', function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = Lang:t("menu.bank_name"),
        submitText = Lang:t("menu.change_account_name"),
        inputs = {
            {
                text = Lang:t("menu.account_id"),
                name = "accountid",
                type = "text",
                isRequired = true
            }
        }
    })
    if dialog and dialog.accountid then
        dialog.accountid = dialog.accountid:lower():gsub("%s+", "")
        TriggerServerEvent("Renewed-Banking:server:changeAccountName", data.account, dialog.accountid)
    end
end)