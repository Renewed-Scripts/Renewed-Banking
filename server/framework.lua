local Framework = Config.framework == 'qb' and 'qb' or Config.framework == 'esx' and 'esx' or 'Unknown'
local QBCore, ESX, Jobs, Gangs = nil, nil, nil, nil
local deadPlayers = {}

CreateThread(function()
    if Framework == 'Unknown' then
        StopResource(GetCurrentResourceName())
    end
    if Framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
        Jobs = QBCore.Shared.Jobs
        Gangs = QBCore.Shared.Gangs

        -- Backwards Compatability
        ExportHandler("qb-management", "GetAccount", GetAccountMoney)
        ExportHandler("qb-management", "GetGangAccount", GetAccountMoney)
        ExportHandler("qb-management", "AddMoney", AddAccountMoney)
        ExportHandler("qb-management", "AddGangMoney", AddAccountMoney)
        ExportHandler("qb-management", "RemoveMoney", RemoveAccountMoney)
        ExportHandler("qb-management", "RemoveGangMoney", RemoveAccountMoney)

        if Config.updateGroupsInDatabase then
            local currentGroupList = {}
            local groupData        = {}
            local groupDataDB      = {}

            MySQL.query('SELECT * FROM `bank_accounts_new` WHERE `creator` IS NULL', {},
                function(response)
                    -- Transcode SQL query results into a table, with the index being the group name
                    for _, v in pairs(response) do
                        QBCore.Debug(response)
                        if v.creator == nil then
                            groupDataDB[v.id] = true
                            table.insert(currentGroupList, v.id)
                        end
                    end

                    -- Iterate through the Jobs table provided by QBCore to check they have `bankAuth` and transcoding them into a general table for checking if they need to be added to Database
                    for job, data in pairs(Jobs) do
                        for _, v in pairs(data.grades) do
                            if v.bankAuth then
                                groupData[job] = true
                            end
                        end
                    end

                    -- Iterate through the Gangs table provided by QBCore to check they have `bankAuth` and transcoding them into a general table for checking if they need to be added to Database
                    for gang, data in pairs(Gangs) do
                        for _, v in pairs(data.grades) do
                            if v.bankAuth then
                                groupData[gang] = true
                            end
                        end
                    end

                    -- Iterate through the groups table (Jobs & Gangs) that we transcoded from QBCore earlier and completing a diff check on the the groups currently in the Database.
                    local newGroupsList  = {}
                    local newGroupsToAdd = {}
                    for group, _ in pairs(groupData) do
                        if groupDataDB[group] == nil then
                            table.insert(newGroupsToAdd, { "INSERT INTO `bank_accounts_new` (id) VALUES (?)", { group } })
                            table.insert(newGroupsList, group)
                        end
                    end

                    -- Execute SQL queries for adding the groups.
                    if #newGroupsToAdd > 0 then
                        MySQL.transaction.await(newGroupsToAdd)
                    end

                    -- Iterate through the groups table (Jobs & Gangs) that we transcoded from QBCore earlier and completing a diff check on the the groups currently in the Database.
                    local oldGroupsList     = {}
                    local oldGroupsToRemove = {}
                    if Config.removeOldGroupsInDB then
                        for group, _ in pairs(groupDataDB) do
                            if groupData[group] == nil then
                                table.insert(oldGroupsToRemove,
                                    { "DELETE FROM `bank_accounts_new` WHERE (id) = (?)", { group } })
                                table.insert(oldGroupsList, group)
                            else
                                groupData[group] = nil
                            end
                        end
                        -- Execute SQL queries for deletion of the groups.
                        if #oldGroupsToRemove > 0 then
                            MySQL.transaction.await(oldGroupsToRemove)
                        end
                    end

                    -- If we have debugMessages enabled and there are changes.. print them to the console
                    if Config.debugGroupChanges then
                        if #currentGroupList > 0 and (#newGroupsToAdd > 0 or #oldGroupsToRemove > 0) then
                            PrintServerConsoleMessage("Groups in DB", currentGroupList)
                        end
                        if #newGroupsToAdd > 0 then
                            PrintServerConsoleMessage("Groups to Add", newGroupsList)
                        end
                        if Config.removeOldGroupsInDB then
                            if #oldGroupsToRemove > 0 then
                                PrintServerConsoleMessage("Groups to Del", oldGroupsList)
                            end
                        end
                    end
                end
            )
        end
    elseif Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
        ESX.RefreshJobs()
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

function PrintServerConsoleMessage(string, data)
    print("")
    print("------------ " .. string .. " ------------")
    QBCore.Debug(data)
    print("---------------------------------------")
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
            for k, v in pairs(jobs) do
                temp[#temp + 1] = {
                    name = k,
                    grade = tostring(v.grade)
                }
            end
            return temp
        else
            return {
                name = Player.PlayerData.job.name,
                grade = tostring(Player.PlayerData.job.grade.level)
            }
        end
    elseif Framework == 'esx' then
        return {
            name = Player.job.name,
            grade = tostring(Player.job.grade)
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
    local numGrade = tonumber(grade)
    if Framework == 'qb' then
        return Jobs[job].grades[grade] and Jobs[job].grades[grade].bankAuth or Jobs[job].grades[numGrade] and Jobs[job].grades[numGrade].bankAuth
    elseif Framework == 'esx' then
        return Jobs[job].grades[grade] and Jobs[job].grades[grade].name == 'boss' or Jobs[job].grades[numGrade] and Jobs[job].grades[numGrade].name == 'boss'
    end
end

function IsGangAuth(Player, gang)
    if Framework == 'qb' then
        local grade = tostring(Player.PlayerData.gang.grade.level)
        local gradeNum = tonumber(grade)
        return Gangs[gang].grades[grade] and Gangs[gang].grades[grade].bankAuth or Gangs[gang].grades[gradeNum] and Gangs[gang].grades[gradeNum].bankAuth
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
