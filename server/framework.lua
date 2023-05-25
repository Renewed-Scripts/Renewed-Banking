local Framework = Config.framework == 'qb' and 'qb' or Config.framework == 'esx' and 'esx' or 'Unknown'
local QBCore, ESX, Jobs = nil, nil, nil
local deadPlayers = {}

CreateThread(function()
    if Framework == 'Unknown' then
        StopResource(GetCurrentResourceName())
    end
    if Framework == 'qb'then
        QBCore = exports['qb-core']:GetCoreObject()
        Jobs = QBCore.Shared.Jobs

        -- Backwards Compatability
        ExportHandler("qb-management", "GetAccount", GetAccountMoney)
        ExportHandler("qb-management", "GetGangAccount", GetAccountMoney)
        ExportHandler("qb-management", "AddMoney", AddAccountMoney)
        ExportHandler("qb-management", "AddGangMoney", AddAccountMoney)
        ExportHandler("qb-management", "RemoveMoney", RemoveAccountMoney)
        ExportHandler("qb-management", "RemoveGangMoney", RemoveAccountMoney)
    elseif Framework == 'esx'then
        ESX = exports['es_extended']:getSharedObject()
        Jobs = ESX.GetJobs()

        -- Backwards Compatability
        ExportHandler("esx_society", "GetSociety", GetAccountMoney)
        RegisterServerEvent('esx_society:getSociety', GetAccountMoney)
        RegisterServerEvent('esx_society:depositMoney', AddAccountMoney)
        RegisterServerEvent('esx_society:withdrawMoney', RemoveAccountMoney)
    end
end)

function GetSocietyLabel(society)
    if Framework == 'qb' then
        return Jobs[society] and Jobs[society].label or QBCore.Shared.Gangs[society] and QBCore.Shared.Gangs[society].label or society
    elseif Framework == 'esx' then
        return Jobs[society] and Jobs[society].label or society
    end
end

function GetPlayerObject(source)
    if Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    end
end

function GetPlayerObjectFromID(identifier)
    if Framework == 'qb' then
        identifier = identifier:upper()
        return QBCore.Functions.GetPlayerByCitizenId(identifier)
    elseif Framework == 'esx' then
        return ESX.GetPlayerFromIdentifier(identifier)
    end
end

function GetCharacterName(Player)
    if Framework == 'qb' then
        return ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    elseif Framework == 'esx' then
        return Player.name
    end
end

function GetIdentifier(Player)
    if Framework == 'qb' then
        return Player.PlayerData.citizenid
    elseif Framework == 'esx' then
        return Player.identifier
    end
end

function GetFunds(Player)
    if Framework == 'qb' then
        local funds = {
            cash = Player.PlayerData.money.cash,
            bank = Player.PlayerData.money.bank
        }
        return funds
    elseif Framework == 'esx' then
        local funds = {
            cash = Player.getAccount('money').money,
            bank = Player.getAccount('bank').money
        }
        return funds
    end
end

function AddMoney(Player, Amount, Type, comment)
    if Framework == 'qb' then
        Player.Functions.AddMoney(Type, Amount, comment)
    elseif Framework == 'esx' then
        if Type == 'cash' then
            Player.addAccountMoney('money', Amount, comment)
        elseif Type == 'bank' then
            Player.addAccountMoney('bank', Amount, comment)
        end
    end
end

function RemoveMoney(Player, Amount, Type, comment)
    if Framework == 'qb' then
        local currentAmount = Player.Functions.GetMoney(Type)
        if currentAmount >= Amount then
            Player.Functions.RemoveMoney(Type, Amount, comment)
            return true
        end
    elseif Framework == 'esx' then
        if Type == 'cash' then
            local currentAmount = Player.getAccount('money').money
            if currentAmount >= Amount then
                Player.removeAccountMoney('money', Amount, comment)
                return true
            end
        elseif Type == 'bank' then
            local currentAmount = Player.getAccount('bank').money
            if currentAmount >= Amount then
                Player.removeAccountMoney('bank', Amount, comment)
                return true
            end
        end
    end
    return false
end

function GetJobs(Player)
    if Framework == 'qb' then
        if Config.renewedMultiJob then
            local jobs = exports['qb-phone']:getJobs(Player.PlayerData.citizenid)
            local temp = {}
            for k,v in pairs(jobs) do
                temp[#temp+1] = {
                    name = k,
                    grade = v.grade
                }
            end
            return temp
        else
            return {
                name = Player.PlayerData.job.name,
                grade = Player.PlayerData.job.grade.level
            }
        end
    elseif Framework == 'esx' then
        return {
            name = Player.job.name,
            grade = Player.job.grade
        }
    end
end

function GetGang(Player)
    if Framework == 'qb' then
        return Player.PlayerData.gang.name
    elseif Framework == 'esx' then
        return false
    end
end

function IsJobAuth(job, grade)
    if Framework == 'qb' then
        return Jobs[job].grades[grade].bankAuth
    elseif Framework == 'esx' then
        return Jobs[job].grades[grade].name == 'boss'
    end
end
function IsGangAuth(Player, gang)
    if Framework == 'qb' then
        return QBCore.Shared.Gangs[gang].grades[tostring(Player.PlayerData.gang.grade.level)].bankAuth
    elseif Framework == 'esx' then
        return false
    end
end

function Notify(src, settings)
    TriggerClientEvent("ox_lib:notify", src, settings)
end

function IsDead(Player)
    if Framework == 'qb' then
        return Player.PlayerData.metadata.isdead
    elseif Framework == 'esx' then
        return deadPlayers[Player.source]
    end
end

--Misc Framework Events

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local cid = Player.PlayerData.citizenid
    UpdatePlayerAccount(cid)
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
	deadPlayers[source] = true
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
    local Player = GetPlayerObject(source)
    local cid = GetIdentifier(Player)
	if deadPlayers[source] then
		deadPlayers[source] = nil
	end
    UpdatePlayerAccount(cid)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	if deadPlayers[playerId] then
		deadPlayers[playerId] = nil
	end
end)


AddEventHandler('onResourceStart', function(resourceName)
    Wait(250)
    if resourceName == GetCurrentResourceName() then
        for _, v in ipairs(GetPlayers()) do
            local Player = GetPlayerObject(v)
            if Player then
                local cid = GetIdentifier(Player)
                UpdatePlayerAccount(cid)
            end
        end
    end
end)
