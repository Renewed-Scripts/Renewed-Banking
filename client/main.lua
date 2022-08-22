local QBCore = exports['qb-core']:GetCoreObject()
local playerJob = nil
local bankingData = nil
local isVisible = false

RegisterCommand("openBankUI", function()
    QBCore.Functions.TriggerCallback('renewed-banking:server:initalizeBanking', function(result)
        if result then
            isVisible = not isVisible
            SendNUIMessage({
                action = "setVisible",
                status = isVisible,
                accounts = result
            })
            SendNUIMessage({
                action = "updateAccount",
            })
            SetNuiFocus(isVisible, isVisible)
        end
    end)
end)

RegisterNUICallback("closeInterface", function(_, cb)
    isVisible = false
    SetNuiFocus(false, false)
    cb("ok")
end)