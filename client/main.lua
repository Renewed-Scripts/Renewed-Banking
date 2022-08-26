local QBCore = exports['qb-core']:GetCoreObject()
local playerJob = nil
local bankingData = nil
local isVisible = false

local function openBankUI()
    SendNUIMessage({action = "setLoading", status = true})
    QBCore.Functions.TriggerCallback('renewed-banking:server:initalizeBanking', function(result)
        if not result then QBCore.Functions.Notify('Failed to load Banking Data!', 'error', 7500) end
        SetTimeout(3500, function()
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
RegisterNetEvent("Renewed-Banking:client:openBankUI", openBankUI)

local function closeBankUI()
    isVisible = false
    SetNuiFocus(false, false)
end

RegisterNUICallback("closeInterface", function(_, cb)
    closeBankUI()
    cb("ok")
end)
RegisterCommand("closeBankUI", function() closeBankUI() end)

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

    exports['qb-target']:AddTargetModel({
        `prop_atm_01`,
        `prop_atm_02`,
        `prop_atm_03`,
        `prop_fleeca_atm`
    },{
        options = {{
            type = "client",
            event = "Renewed-Banking:client:openBankUI",
            icon = "fas fa-money-check",
            label = "View Bank Account",
        },},
        distance = 1.5
     })
end)

