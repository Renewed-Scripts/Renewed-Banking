local QBCore = exports['qb-core']:GetCoreObject()
local isVisible = false

local FullyLoaded = LocalPlayer.state.isLoggedIn

AddStateBagChangeHandler('isLoggedIn', nil, function(_, _, value)
    FullyLoaded = value
end)

local function openBankUI()
    SendNUIMessage({action = "setLoading", status = true})
    QBCore.Functions.TriggerCallback('renewed-banking:server:initalizeBanking', function(result)
        if not result then QBCore.Functions.Notify('Failed to load Banking Data!', 'error', 7500) end
        SetTimeout(1000, function()
            isVisible = true
            SendNUIMessage({
                action = "setVisible",
                status = isVisible,
                accounts = result,
                loading = false
            })
            SetNuiFocus(isVisible, isVisible)
        end)
    end)
end

RegisterNetEvent("Renewed-Banking:client:openBankUI", function(data)
    if not data.entity then return end
    local isPed = IsEntityAPed(data.entity)
    local txt = isPed and 'Opening Bank' or 'Opening ATM'

    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_ATM", 0, 1)
    QBCore.Functions.Progressbar('Renewed-Banking', txt, math.random(3000,5000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        openBankUI()
        Wait(500)
        ClearPedTasksImmediately(PlayerPedId())
    end, function()
        ClearPedTasksImmediately(PlayerPedId())
        QBCore.Functions.Notify('Cancelled...', 'error', 7500)
    end)
end)

local function closeBankUI()
    isVisible = false
    SetNuiFocus(false, false)
end

RegisterNUICallback("closeInterface", function(_, cb)
    closeBankUI()
    cb("ok")
end)

RegisterCommand("closeBankUI", function() closeBankUI() end)

local targetOptions = {{
    type = "client",
    event = "Renewed-Banking:client:openBankUI",
    icon = "fas fa-money-check",
    label = "View Bank Account",
    entity = entity
}}

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
        options = targetOptions,
        distance = 1.5
    })
end)

local pedSpawned = false
local bankPeds = {}
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
            options = targetOptions,
            distance = 2.0
        })
    end

    pedSpawned = true
end

local function deletePeds()
    if not pedSpawned then return end
    for k=1, #bankPeds do
        DeletePed(bankPeds[k])
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    createPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deletePeds()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        deletePeds()
    end
end)

AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
      Wait(100)
      if FullyLoaded then
        createPeds()
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