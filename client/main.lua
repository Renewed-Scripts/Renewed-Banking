local isVisible = false
local progressBar = Config.progressbar == 'circle' and lib.progressCircle or lib.progressBar
PlayerPed = cache.ped

lib.onCache('ped', function(newPed)
	PlayerPed = newPed
end)

local function nuiHandler(val)
    isVisible = val
    SetNuiFocus(val, val)
end

local function openBankUI(isAtm)
    SendNUIMessage({action = 'setLoading', status = true})
    nuiHandler(true)
    lib.callback('renewed-banking:server:initalizeBanking', false, function(accounts)
        if not accounts then
            nuiHandler(false)
            lib.notify({title = locale('bank_name'), description = locale('loading_failed'), type = 'error'})
            return
        end
        SetTimeout(1000, function()
            SendNUIMessage({
                action = 'setVisible',
                status = isVisible,
                accounts = accounts,
                loading = false,
                atm = isAtm
            })
        end)
    end)
end

RegisterNetEvent('Renewed-Banking:client:openBankUI', function(data)
    local txt = data.atm and locale('open_atm') or locale('open_bank')
    TaskStartScenarioInPlace(PlayerPed, 'PROP_HUMAN_ATM', 0, true)
    if progressBar({
        label = txt,
        duration = math.random(3000,5000),
        position = 'bottom',
        useWhileDead = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        }
    }) then
        openBankUI(data.atm)
        Wait(500)
        ClearPedTasksImmediately(PlayerPed)
    else
        ClearPedTasksImmediately(PlayerPed)
        lib.notify({title = locale('bank_name'), description = locale('canceled'), type = 'error'})
    end
end)

RegisterNUICallback('closeInterface', function(_, cb)
    nuiHandler(false)
    cb('ok')
end)

RegisterCommand('closeBankUI', function() nuiHandler(false) end, false)

local bankActions = {'deposit', 'withdraw', 'transfer'}
CreateThread(function ()
    for k=1, #bankActions do
        RegisterNUICallback(bankActions[k], function(data, cb)
            local newTransaction = lib.callback.await('Renewed-Banking:server:'..bankActions[k], false, data)
            cb(newTransaction)
        end)
    end
    exports.ox_target:addModel(Config.atms, {{
        name = 'renewed_banking_openui',
        event = 'Renewed-Banking:client:openBankUI',
        icon = 'fas fa-money-check',
        label = locale('view_bank'),
        atm = true,
        canInteract = function(_, distance)
            return distance < 2.5
        end
    }})
end)

local pedSpawned = false
local blips = {}
function CreatePeds()
    if pedSpawned then return end
    for k = 1, #Config.peds do
        local coords = Config.peds[k].coords
        local pedPoint = lib.points.new({
            coords = coords,
            distance = 300,
            model = joaat(Config.peds[k].model),
            heading = coords.w,
            ped = nil,
            targetOptions = {{
                name = 'renewed_banking_accountmng',
                event = 'Renewed-Banking:client:accountManagmentMenu',
                icon = 'fas fa-money-check',
                label = locale('manage_bank'),
                atm = false,
                canInteract = function(_, distance)
                    return distance < 4.5 and Config.peds[k].createAccounts
                end
            },{
                name = 'renewed_banking_openui',
                event = 'Renewed-Banking:client:openBankUI',
                icon = 'fas fa-money-check',
                label = locale('view_bank'),
                atm = false,
                canInteract = function(_, distance)
                    return distance < 4.5
                end
            }}
        })

        function pedPoint:onEnter()
            lib.requestModel(self.model, 10000)

            self.ped = CreatePed(0, self.model, self.coords.x, self.coords.y, self.coords.z-1, self.heading, false, false)
            SetEntityHeading(self.ped, self.heading)
            SetModelAsNoLongerNeeded(self.model)

            TaskStartScenarioInPlace(self.ped, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
            FreezeEntityPosition(self.ped, true)
            SetEntityInvincible(self.ped, true)
            SetBlockingOfNonTemporaryEvents(self.ped, true)
            exports.ox_target:addLocalEntity(self.ped, self.targetOptions)
        end

        function pedPoint:onExit()
            exports.ox_target:removeLocalEntity(self.ped, self.advanced and 'renewed_banking_accountmng' or 'renewed_banking_openui')
            if DoesEntityExist(self.ped) then
                DeletePed(self.ped)
            end
            self.ped = nil
        end

        blips[k] = AddBlipForCoord(coords.x, coords.y, coords.z-1)
        SetBlipSprite(blips[k], 108)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], 0.80)
        SetBlipColour (blips[k], 2)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Bank')
        EndTextCommandSetBlipName(blips[k])
    end
    pedSpawned = true
end

function DeletePeds()
    if not pedSpawned then return end
    local points = lib.points.getAllPoints()
    for i = 1, #points do
        if DoesEntityExist(points[i].ped) then
            DeletePed(points[i].ped)
        end
        points[i]:remove()
    end
    for i = 1, #blips do
        RemoveBlip(blips[i])
    end
    pedSpawned = false
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    exports.ox_target:removeModel(Config.atms, {'renewed_banking_openui'})
    DeletePeds()
end)

RegisterNetEvent('Renewed-Banking:client:sendNotification', function(msg)
    if not msg then return end
    SendNUIMessage({
        action = 'notify',
        status = msg,
    })
end)

RegisterNetEvent('Renewed-Banking:client:viewAccountsMenu', function()
    TriggerServerEvent('Renewed-Banking:server:getPlayerAccounts')
end)
