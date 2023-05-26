local Framework = Config.framework
QBCore, ESX, FullyLoaded = nil, nil, nil
if Framework == 'qb'then
	QBCore = exports['qb-core']:GetCoreObject()
    FullyLoaded = Framework == 'qb' and LocalPlayer.state.isLoggedIn
elseif Framework == 'esx'then
    ESX = exports['es_extended']:getSharedObject()
    FullyLoaded = Framework == 'esx' and ESX.PlayerLoaded or false
else
	print('^6[^3Renewed-Banking^6]^0 Unsupported Framework detected!')
end

AddStateBagChangeHandler('isLoggedIn', nil, function(_, _, value)
    FullyLoaded = value
end)

local function initalizeBanking()
    CreatePeds()
    local locales = lib.getLocales()
    SendNUIMessage({
        action = 'updateLocale',
        translations = locales,
        currency = Config.currency
    })
end
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(100)
    initalizeBanking()
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    Wait(100)
    FullyLoaded = true
    initalizeBanking()
end)

AddEventHandler('onResourceStart', function(resourceName)
    Wait(100)
    if resourceName ~= GetCurrentResourceName() then return end
    if not FullyLoaded then return end
    initalizeBanking()
end)


AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    DeletePeds()
end)

AddEventHandler('esx:onPlayerLogout', function()
    DeletePeds()
end)
