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
    if lib then
        exports.ox_target:addModel(config.atms, {{
            name = 'renewed_banking_openui',
            event = 'Renewed-Banking:client:openBankUI',
            icon = 'fas fa-money-check',
            label = Lang:t("menu.view_bank"),
            atm = true,
            canInteract = function(_, distance)
                return distance < 2.5
            end
        }})
        return
    end
    exports['qb-target']:AddTargetModel(config.atms,{
        options = {{
            type = "client",
            event = "Renewed-Banking:client:openBankUI",
            icon = "fas fa-money-check",
            label = Lang:t("menu.view_bank"),
            atm = true
        }},
        distance = 2.5
    })

end)

local pedSpawned = false
local peds = {basic = {}, adv ={}}
local blips = {}
local function createPeds()
    if pedSpawned then return end
    for k=1, #config.peds do
        local model = joaat(config.peds[k].model)

        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local coords = config.peds[k].coords
        local bankPed = CreatePed(0, model, coords.x, coords.y, coords.z-1, coords.w, false, false)

        TaskStartScenarioInPlace(bankPed, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
        FreezeEntityPosition(bankPed, true)
        SetEntityInvincible(bankPed, true)
        SetBlockingOfNonTemporaryEvents(bankPed, true)
        table.insert(config.peds[k].createAccounts and peds.adv or peds.basic, bankPed)

        blips[k] = AddBlipForCoord(coords.x, coords.y, coords.z-1)
        SetBlipSprite(blips[k], 108)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], 0.80)
        SetBlipColour (blips[k], 2)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bank")
        EndTextCommandSetBlipName(blips[k])
    end
    if lib then
        local targetOpts ={{
            name = 'renewed_banking_openui',
            event = 'Renewed-Banking:client:openBankUI',
            icon = 'fas fa-money-check',
            label = Lang:t("menu.view_bank"),
            atm = false,
            canInteract = function(_, distance)
                return distance < 4.5
            end
        }}
        exports.ox_target:addLocalEntity(peds.basic, targetOpts)
        targetOpts[#targetOpts+1]={
            name = 'renewed_banking_accountmng',
            event = 'Renewed-Banking:client:accountManagmentMenu',
            icon = 'fas fa-money-check',
            label = Lang:t("menu.manage_bank"),
            atm = false,
            canInteract = function(_, distance)
                return distance < 4.5
            end
        }
        exports.ox_target:addLocalEntity(peds.adv, targetOpts)
    else
        exports['qb-target']:AddTargetEntity(peds.basic, {
            options = {
                {
                    type = "client",
                    event = "Renewed-Banking:client:openBankUI",
                    icon = "fas fa-money-check",
                    label = Lang:t("menu.view_bank"),
                    atm = false
                }
            },
            distance = 2.0
        })
        exports['qb-target']:AddTargetEntity(peds.adv, {
            options = {
                {
                    type = "client",
                    event = "Renewed-Banking:client:openBankUI",
                    icon = "fas fa-money-check",
                    label = Lang:t("menu.view_bank"),
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
    end
    pedSpawned = true
end

local function deletePeds()
    if not pedSpawned then return end
    local k=1
    for x,v in pairs(peds)do
        for i=1, #v do
            DeletePed(v[i])
            RemoveBlip(blips[k])
            k += 1
        end
        peds[x] = {}
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
    deletePeds()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if lib then
        exports.ox_target:removeModel(config.atms, {'renewed_banking_openui'})
        exports.ox_target:removeEntity(peds.basic, {'renewed_banking_openui'})
        exports.ox_target:removeEntity(peds.adv, {'renewed_banking_openui','renewed_banking_accountmng'})
    else
        exports['qb-target']:RemoveTargetModel(config.atms, Lang:t("menu.view_bank"))
        exports['qb-target']:RemoveTargetEntity(peds.basic, Lang:t("menu.view_bank"))
        exports['qb-target']:RemoveTargetEntity(peds.adv, {Lang:t("menu.view_bank"), Lang:t("menu.manage_bank")})
    end
    deletePeds()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if not FullyLoaded then return end
    Wait(100)
    createPeds()
    SendNUIMessage({
        action = "updateLocale",
        translations = Translations.ui,
    })

end)

RegisterNetEvent("Renewed-Banking:client:sendNotification", function(msg)
    if not msg then return end
    SendNUIMessage({
        action = "notify",
        status = msg,
    })
end)

RegisterNetEvent('Renewed-Banking:client:viewAccountsMenu', function()
    TriggerServerEvent("Renewed-Banking:server:getPlayerAccounts")
end)

local bankingMenus = {
    [1] = {
        event = "Renewed-Banking:client:accountManagmentMenu",
        menu = function()
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
            exports["qb-menu"]:openMenu(table)
        end,
        lib = function()
            lib.registerContext({
                id = 'renewed_banking_account_management',
                title = Lang:t("menu.bank_name"),
                position = 'top-right',
                options = {
                    {
                        title = Lang:t("menu.create_account"),
                        icon = 'file-invoice-dollar',
                        metadata = {Lang:t("menu.create_account_txt")},
                        event = "Renewed-Banking:client:createAccountMenu"
                    },
                    {
                        title = Lang:t("menu.manage_account"),
                        icon = 'users-gear',
                        metadata = {Lang:t("menu.manage_account_txt")},
                        event = 'Renewed-Banking:client:viewAccountsMenu'
                    }
                }
            })
            lib.showContext("renewed_banking_account_management")
        end
    },
    [2] = {
        event = "Renewed-Banking:client:createAccountMenu",
        menu = function()
            local dialog = exports["qb-input"]:ShowInput({
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
        end,
        lib = function()
            local input = lib.inputDialog(Lang:t("menu.bank_name"), {{
                type = "input",
                label = Lang:t("menu.account_id"),
                placeholder = "a_test_account"
            }})
            if input and input[1] then
                input[1] = input[1]:lower():gsub("%s+", "")
                TriggerServerEvent("Renewed-Banking:server:createNewAccount", input[1])
            end
        end
    },
    [3] = {
        event = "Renewed-Banking:client:accountsMenu",
        menu = function(data)
            local table = {{
                isMenuHeader = true,
                header = Lang:t("menu.bank_name")
            }}
            if #data >= 1 then
                for k=1, #data do
                    table[#table+1] = {
                        header = data[k],
                        txt = Lang:t("menu.view_members"),
                        params = {
                            event = 'Renewed-Banking:client:accountsMenuView',
                            args = {
                                account = data[k],
                            }
                        }
                    }
                end
            else
                table[#table+1] = {
                    header = Lang:t("menu.no_account"),
                    txt = Lang:t("menu.no_account_txt"),
                    isMenuHeader = true
                }
            end
            exports["qb-menu"]:openMenu(table)
        end,
        lib = function(data)
            local menuOpts = {}
            if #data >= 1 then
                for k=1, #data do
                    menuOpts[#menuOpts+1] = {
                        title = data[k],
                        icon = 'users-gear',
                        metadata = {Lang:t("menu.view_members")},
                        event = "Renewed-Banking:client:accountsMenuView",
                        args = {
                            account = data[k],
                        }
                    }
                end
            else
                menuOpts[#menuOpts+1] = {
                    title = Lang:t("menu.no_account"),
                    metadata = {Lang:t("menu.no_account_txt")},
                }
            end
            lib.registerContext({
                id = 'renewed_banking_account_list',
                title = Lang:t("menu.bank_name"),
                position = 'top-right',
                menu = "renewed_banking_account_management",
                options = menuOpts
            })
            lib.showContext("renewed_banking_account_list")
        end
    },
    [4] = {
        event = "Renewed-Banking:client:accountsMenuView",
        menu = function(data)
            local table = {
                {
                    isMenuHeader = true,
                    header = Lang:t("menu.bank_name")
                },
                {
                    header = Lang:t("menu.manage_members"),
                    txt = Lang:t("menu.manage_members_txt"),
                    params = {
                        isServer =true,
                        event = 'Renewed-Banking:server:viewMemberManagement',
                        args = data
                    }
                },
                {
                    header = Lang:t("menu.edit_acc_name"),
                    txt = Lang:t("menu.edit_acc_name_txt"),
                    params = {
                        event = 'Renewed-Banking:client:changeAccountName',
                        args = data
                    }
                }
            }
            exports["qb-menu"]:openMenu(table)
        end,
        lib = function(data)
            lib.registerContext({
                id = 'renewed_banking_account_view',
                title = Lang:t("menu.bank_name"),
                position = 'top-right',
                menu = "renewed_banking_account_list",
                options = {
                    {
                        title = Lang:t("menu.manage_members"),
                        icon = 'users-gear',
                        metadata = {Lang:t("menu.manage_members_txt")},
                        serverEvent = "Renewed-Banking:server:viewMemberManagement",
                        args = data
                    },
                    {
                        title = Lang:t("menu.edit_acc_name"),
                        icon = 'users-gear',
                        metadata = {Lang:t("menu.edit_acc_name_txt")},
                        event = "Renewed-Banking:client:changeAccountName",
                        args = data
                    }
                }
            })
            lib.showContext("renewed_banking_account_view")
        end
    },
    [5] = {
        event = "Renewed-Banking:client:viewMemberManagement",
        menu = function(data)
            local table = {{
                isMenuHeader = true,
                header = Lang:t("menu.bank_name")
            }}
            local account = data.account
            for k,v in pairs(data.members) do
                table[#table+1] = {
                    header = v,
                    txt = Lang:t("menu.remove_member_txt"),
                    params = {
                        event = 'Renewed-Banking:client:removeMemberConfirmation',
                        args = {
                            account = account,
                            cid = k,
                        }
                    }
                }
            end
            table[#table+1] = {
                header = Lang:t("menu.add_member"),
                txt = Lang:t("menu.add_member_txt"),
                params = {
                    event = 'Renewed-Banking:client:addAccountMember',
                    args = {
                        account = account
                    }
                }
            }
            exports["qb-menu"]:openMenu(table)
        end,
        lib = function(data)
            local menuOpts = {}
            local account = data.account
            for k,v in pairs(data.members) do
                menuOpts[#menuOpts+1] = {
                    title = v,
                    metadata = {Lang:t("menu.remove_member_txt")},
                    event = 'Renewed-Banking:client:removeMemberConfirmation',
                    args = {
                        account = account,
                        cid = k,
                    }
                }
            end
            menuOpts[#menuOpts+1] = {
                title = Lang:t("menu.add_member"),
                metadata = {Lang:t("menu.add_member_txt")},
                event = 'Renewed-Banking:client:addAccountMember',
                args = {
                    account = account
                }
            }
            lib.registerContext({
                id = 'renewed_banking_member_manage',
                title = Lang:t("menu.bank_name"),
                position = 'top-right',
                menu = 'renewed_banking_account_view',
                options = menuOpts
            })
            lib.showContext("renewed_banking_member_manage")
        end
    },
    [6] = {
        event = "Renewed-Banking:client:removeMemberConfirmation",
        menu = function(data)
            local table = {
                {
                    isMenuHeader = true,
                    header = Lang:t("menu.bank_name")
                },
                {
                    header = Lang:t("menu.back"),
                    icon = "fa-solid fa-angle-left",
                    params = {
                        isServer =true,
                        event = "Renewed-Banking:client:accountsMenuView",
                        args = data
                    }
                },
                {
                    header = Lang:t("menu.remove_member"),
                    txt = Lang:t("menu.remove_member_txt2", {id=data.cid}),
                    params = {
                        isServer = true,
                        event = 'Renewed-Banking:server:removeAccountMember',
                        args = data
                    }
                }
            }
            exports["qb-menu"]:openMenu(table)
        end,
        lib = function(data)
            lib.registerContext({
                id = 'renewed_banking_member_remove',
                title = Lang:t("menu.bank_name"),
                position = 'top-right',
                menu = "renewed_banking_account_view",
                options = {
                    {
                        title = Lang:t("menu.remove_member"),
                        metadata = {Lang:t("menu.remove_member_txt2", {id=data.cid})},
                        serverEvent = 'Renewed-Banking:server:removeAccountMember',
                        args = data
                    }
                }
            })
            lib.showContext("renewed_banking_member_remove")
        end
    },
    [7] = {
        event = "Renewed-Banking:client:addAccountMember",
        menu = function(data)
            local dialog = exports["qb-input"]:ShowInput({
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
        end,
        lib = function(data)
            local input = lib.inputDialog(Lang:t("menu.add_account_member"), {{
                type = "input",
                label = Lang:t("menu.citizen_id"),
                placeholder = "1001"
            }})
            if input and input[1] then
                input[1] = input[1]:upper():gsub("%s+", "")
                TriggerServerEvent("Renewed-Banking:server:addAccountMember", data.account, input[1])
            end
        end
    },
    [8] = {
        event = "Renewed-Banking:client:changeAccountName",
        menu = function(data)
            local dialog = exports["qb-input"]:ShowInput({
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
        end,
        lib = function(data)
            local input = lib.inputDialog(Lang:t("menu.change_account_name"), {{
                type = "input",
                label = Lang:t("menu.account_id"),
                placeholder = "savings-1001"
            }})
            if input and input[1] then
                input[1] = input[1]:lower():gsub("%s+", "")
                TriggerServerEvent("Renewed-Banking:server:changeAccountName", data.account, input[1])
            end
        end
    }
}
for k=1, #bankingMenus do
    RegisterNetEvent(bankingMenus[k].event, lib and bankingMenus[k].lib or bankingMenus[k].menu)
end