local QBCore = exports['qb-core']:GetCoreObject()
local playerJob = nil
local bankingData = nil
local isVisible = false

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

local targetOptions = {{
    type = "client",
    event = "Renewed-Banking:client:openBankUI",
    icon = "fas fa-money-check",
    label = "View Bank Account",
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

    exports['qb-target']:AddTargetModel({
        `prop_atm_01`,
        `prop_atm_02`,
        `prop_atm_03`,
        `prop_fleeca_atm`
    },{
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