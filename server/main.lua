local QBCore = exports['qb-core']:GetCoreObject()
local cachedAccounts = {}
local cachedPlayers = {}

CreateThread(function()
    MySQL.query('SELECT * FROM management_funds WHERE type = @type ', {['@type'] = 'boss'}, function(accounts)
        for _,v in pairs (accounts) do
            local job = v.job_name
            cachedAccounts[job] = { --  cachedAccounts[#cachedAccounts+1]
                id = job,
                type = "Organization",
                name = QBCore.Shared.Jobs[job] and QBCore.Shared.Jobs[job].label, -- or QBCore.Shared.Gangs[job] and QBCore.Shared.Gangs[job].label
                frozen = v.isFrozen == 1,
                amount = v.amount,
                transactions = json.decode(v.transactions),
            }
        end
    end)
end)

function getTimeElapsed(seconds)
    local retData = ""
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours / 24)
    local weeks = math.floor(days / 7)

    if weeks ~= 0 and weeks > 1 then
        retData = weeks .. " weeks ago"
    elseif weeks ~= 0 and weeks == 1 then
        retData = "A day ago"
    elseif days ~= 0 and days > 1 then
        retData = days .. " days ago"
    elseif days ~= 0 and days == 1 then
        retData = "A day ago"
    elseif hours ~= 0 and hours > 1 then
        retData = hours .. " hours ago"
    elseif hours ~= 0 and hours == 1 then
        retData = "A hour ago"
    elseif minutes ~= 0 and minutes > 1 then
        retData = minutes .. " minutes ago"
    elseif minutes ~= 0 and minutes == 1 then
        retData = "A minute ago"
    else
        retData = "A few seconds ago"
    end

    return retData
end

local function getBankData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local bankData = {}
    local time = os.time()

    bankData[#bankData+1] = {
        id = Player.PlayerData.citizenid,
        type = "Personal",
        name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
        frozen = cachedPlayers[Player.PlayerData.citizenid].isFrozen,
        amount = Player.PlayerData.money.bank,
        cash = Player.PlayerData.money.cash,
        transactions = json.decode(json.encode(cachedPlayers[Player.PlayerData.citizenid].transactions)),
    }

    for k=1, #bankData[1].transactions do
        bankData[1].transactions[k].time = getTimeElapsed(time-bankData[1].transactions[k].time)
    end

    local org = json.decode(json.encode(cachedAccounts[Player.PlayerData.job.name]))
    if org and QBCore.Shared.Jobs[Player.PlayerData.job.name].grades[tostring(Player.PlayerData.job.grade.level)].bankAuth then
        for k=1, #org.transactions do
            org.amount = exports['qb-management']:GetAccount(Player.PlayerData.job.name)
            org.transactions[k].time = getTimeElapsed(time-org.transactions[k].time)
        end
        bankData[#bankData+1] = org
    end
    return bankData
end
QBCore.Functions.CreateCallback("renewed-banking:server:initalizeBanking", function(source, cb)
    local bankData = getBankData(source)
    cb(bankData)
end)

local function updatePlayerAccount(cid)
    MySQL.query('SELECT * FROM player_transactions WHERE id = @id ', {['@id'] = cid}, function(account)
        if #account < 1 then
            cachedPlayers[cid] = {
                isFrozen = 0,
                transactions = {}
            }
            return
        end
        for _,v in pairs(account) do
            cachedPlayers[cid] = {
                isFrozen = 0,
                transactions = json.decode(v.transactions)
            }
        end
    end)
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local Player = QBCore.Functions.GetPlayer(source)
    local cid = Player.PlayerData.citizenid
    updatePlayerAccount(cid)
end)

-- Events
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, v in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(v)
            if Player then
                local cid = Player.PlayerData.citizenid
                updatePlayerAccount(cid)
            end
        end
    end
end)

local function genTransactionID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

local function handleTransaction(account, title, amount, message, issuer, receiver, type, transID)
    local transaction = {
        trans_id = transID or genTransactionID(),
        title = title,
        amount = amount,
        trans_type = type,
        receiver = receiver,
        message = message,
        issuer = issuer,
        time = os.time()
    }
    if cachedAccounts[account] then
        table.insert(cachedAccounts[account].transactions, 1, transaction)
        MySQL.query("INSERT INTO management_funds (job_name, transactions) VALUES (:job_name, :transactions) ON DUPLICATE KEY UPDATE transactions = :transactions",{
            ['job_name'] = account,
            ['transactions'] = json.encode(cachedAccounts[account].transactions)
        })
    elseif cachedPlayers[account] then
        table.insert(cachedPlayers[account].transactions, 1, transaction)
        MySQL.query("INSERT INTO player_transactions (id, transactions) VALUES (:id, :transactions) ON DUPLICATE KEY UPDATE transactions = :transactions",{
            ['id'] = account,
            ['transactions'] = json.encode(cachedPlayers[account].transactions)
        })
    else
        print("^6[^4Renewed-Banking^6] ^0 Account not found account_id="..account)
    end
    return transaction
end exports("handleTransaction", handleTransaction)

QBCore.Functions.CreateCallback("Renewed-Banking:server:deposit", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not data then print("^6[^4Renewed-Banking^6] ^0 No Data Recieved From Client "..GetPlayerName(source)) end
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then QBCore.Functions.Notify(source, 'Invalid amount to deposit', 'error', 5000) end
    if not data.comment or data.comment == "" then data.comment = ("%s %s has deposited $%s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, amount) end
    if Player.Functions.RemoveMoney('cash', amount, data.comment) then
        if cachedAccounts[data.fromAccount] then
            exports['qb-management']:AddMoney(data.fromAccount, amount)
        else
            Player.Functions.AddMoney('bank', amount, data.comment)
        end
        local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
        handleTransaction(data.fromAccount,"Personal Account / " .. data.fromAccount, amount, data.comment, name, name, "deposit")
        local bankData = getBankData(source)
        cb(bankData)
    else
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Account does not have enough money!")
        cb(false)
    end
end)

QBCore.Functions.CreateCallback("Renewed-Banking:server:withdraw", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not data then print("^6[^4Renewed-Banking^6] ^0 No Data Recieved From Client "..GetPlayerName(source)) end
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then QBCore.Functions.Notify(source, 'Invalid amount to withdraw', 'error', 5000) end
    if not data.comment or data.comment == "" then data.comment = ("%s %s has withdrawed $%s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, amount) end

    local canWithdraw = false
    if cachedAccounts[data.fromAccount] then
        canWithdraw = exports['qb-management']:RemoveMoney(data.fromAccount, amount)
    else
        canWithdraw = Player.Functions.RemoveMoney('bank', amount, data.comment)
    end
    if canWithdraw then
        Player.Functions.AddMoney('cash', amount, data.comment)
        local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
        handleTransaction(data.fromAccount,"Personal Account / " .. data.fromAccount, amount, data.comment, name, name, "withdraw")
        local bankData = getBankData(source)
        cb(bankData)
    else
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Account does not have enough money!")
        cb(false)
    end
end)

local function getPlayerData(source, id)
    local Player = QBCore.Functions.GetPlayer(id)
    if not Player then Player = QBCore.Functions.GetPlayerByCitizenId(id) end
    if not Player then
        local msg = ("Cannot Find Account(%s) To Transfer To"):format(id)
        print("^6[^4Renewed-Banking^6] ^0 "..msg)
        QBCore.Functions.Notify(source, msg, 'error', 5000)
    end
    return Player
end

QBCore.Functions.CreateCallback("Renewed-Banking:server:transfer", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not data then print("^6[^4Renewed-Banking^6] ^0 No Data Recieved From Client "..GetPlayerName(source)) end
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then QBCore.Functions.Notify(source, 'Invalid amount to withdraw', 'error', 5000) end
    if not data.comment or data.comment == "" then data.comment = ("%s %s has withdrawed $%s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, amount) end
    if cachedAccounts[data.fromAccount] then
        if cachedAccounts[data.stateid] then
            local canTransfer = exports['qb-management']:RemoveMoney(data.fromAccount, amount)
            if canTransfer then
                exports['qb-management']:AddMoney(data.stateid, amount)
                local transaction = handleTransaction(data.fromAccount, ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount), amount, data.comment, cachedAccounts[data.fromAccount].name, cachedAccounts[data.stateid].name, "withdraw")
                handleTransaction(data.stateid, ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount), amount, data.comment, cachedAccounts[data.fromAccount].name, cachedAccounts[data.stateid].name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Account does not have enough money!")
                cb(false)
                return
            end
        else
            local Player2 = getPlayerData(source, data.stateid)
            if not Player2 then
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Failed to transfer to account!")
                cb(false)
                return
            end
            local canTransfer = exports['qb-management']:RemoveMoney(data.fromAccount, amount)
            if canTransfer then
                Player2.Functions.AddMoney('bank', amount, data.comment)
                local name = ("%s %s"):format(Player2.PlayerData.charinfo.firstname, Player2.PlayerData.charinfo.lastname)
                local transaction = handleTransaction(data.fromAccount, ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount), amount, data.comment, cachedAccounts[data.fromAccount].name, name, "withdraw")
                handleTransaction(data.stateid, ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount), amount, data.comment, cachedAccounts[data.fromAccount].name, name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Account does not have enough money!")
                cb(false)
                return
            end
        end
    else
        if cachedAccounts[data.stateid] then
            if Player.Functions.RemoveMoney('bank', amount, data.comment) then
                exports['qb-management']:AddMoney(data.stateid, amount)
                local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
                local transaction = handleTransaction(data.fromAccount, ("Personal Account / %s"):format(data.fromAccount), amount, data.comment, name, cachedAccounts[data.stateid].name, "withdraw")
                handleTransaction(data.stateid, ("Personal Account / %s"):format(data.fromAccount), amount, data.comment, name, cachedAccounts[data.stateid].name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Account does not have enough money!")
                cb(false)
                return
            end
        else
            local Player2 = getPlayerData(source, data.stateid)
            if not Player2 then
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Failed to transfer to unknown account!")
                cb(false)
                return
            end
            if Player.Functions.RemoveMoney('bank', amount, data.comment) then
                Player2.Functions.AddMoney('bank', amount, data.comment)
                local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
                local name2 = ("%s %s"):format(Player2.PlayerData.charinfo.firstname, Player2.PlayerData.charinfo.lastname)
                local transaction = handleTransaction(data.fromAccount, ("Personal Account / %s"):format(data.fromAccount), amount, data.comment, name, name2, "withdraw")
                handleTransaction(data.stateid, ("Personal Account / %s"):format(data.fromAccount), amount, data.comment, name, name2, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Account does not have enough money!")
                cb(false)
                return
            end
        end
    end
    local bankData = getBankData(source)
    cb(bankData)
end)