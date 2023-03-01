local QBCore = exports['qb-core']:GetCoreObject()

if not LoadResourceFile("Renewed-Banking", 'web/public/build/bundle.js') then
    error('Unable to load UI. Build Renewed-Banking or download the latest release.\n   ^https://github.com/Renewed-Scripts/Renewed-Banking/releases/latest/download/Renewed-Banking.rar^0\n    If you are using a custom build of the UI, please make sure the resource name is Renewed-Banking (you may not rename the resource).')
end

local cachedAccounts = {}
local cachedPlayers = {}

CreateThread(function()
    MySQL.query('SELECT * FROM bank_accounts_new', {}, function(accounts)
        for _,v in pairs (accounts) do
            local job = v.id
            v.auth = json.decode(v.auth)
            cachedAccounts[job] = { --  cachedAccounts[#cachedAccounts+1]
                id = job,
                type = Lang:t("ui.org"),
                name = QBCore.Shared.Jobs[job] and QBCore.Shared.Jobs[job].label or QBCore.Shared.Gangs[job] and QBCore.Shared.Gangs[job].label or job,
                frozen = v.isFrozen == 1,
                amount = v.amount,
                transactions = json.decode(v.transactions),
                auth = {},
                creator = v.creator
            }
            if #v.auth >= 1 then
                for k=1, #v.auth do
                    cachedAccounts[job].auth[v.auth[k]] = true
                end
            end
        end
    end)
end)

local function getTimeElapsed(seconds)
    local retData
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours / 24)
    local weeks = math.floor(days / 7)

    if weeks ~= 0 and weeks > 1 then
        retData = Lang:t("time.weeks",{time=weeks})
    elseif weeks ~= 0 and weeks == 1 then
        retData = Lang:t("time.aweek")
    elseif days ~= 0 and days > 1 then
        retData = Lang:t("time.days",{time=days})
    elseif days ~= 0 and days == 1 then
        retData = Lang:t("time.aday")
    elseif hours ~= 0 and hours > 1 then
        retData = Lang:t("time.hours",{time=hours})
    elseif hours ~= 0 and hours == 1 then
        retData = Lang:t("time.ahour")
    elseif minutes ~= 0 and minutes > 1 then
        retData = Lang:t("time.mins",{time=minutes})
    elseif minutes ~= 0 and minutes == 1 then
        retData = Lang:t("time.amin")
    else
        retData = Lang:t("time.secs")
    end
    return retData
end

local function updatePlayerAccount(cid)
    MySQL.query('SELECT * FROM player_transactions WHERE id = @id ', {['@id'] = cid}, function(account)
        local query = '%' .. cid .. '%'
        MySQL.query("SELECT * FROM bank_accounts_new WHERE auth LIKE ? ", {query}, function(shared)
            cachedPlayers[cid] = {
                isFrozen = 0,
                transactions = #account > 0 and json.decode(account[1].transactions) or {},
                accounts = {}
            }

            if #shared >= 1 then
                for k=1, #shared do
                    cachedPlayers[cid].accounts[#cachedPlayers[cid].accounts+1] = shared[k].id
                end
            end
        end)
    end)
end

local function getBankData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local bankData = {}
    local time = os.time()
    local cid = Player.PlayerData.citizenid
    if not cachedPlayers[cid] then updatePlayerAccount(cid) end

    bankData[#bankData+1] = {
        id = cid,
        type = Lang:t("ui.personal"),
        name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
        frozen = cachedPlayers[cid].isFrozen,
        amount = Player.PlayerData.money.bank,
        cash = Player.PlayerData.money.cash,
        transactions = json.decode(json.encode(cachedPlayers[cid].transactions)),
    }

    for k=1, #bankData[1].transactions do
        bankData[1].transactions[k].time = getTimeElapsed(time-bankData[1].transactions[k].time)
    end

    if config.renewedMultiJob then
        local jobs = exports['qb-phone']:getJobs(cid)

        for k,v in pairs(jobs) do
            if cachedAccounts[k] then
                local job = json.decode(json.encode(cachedAccounts[k]))
                if job and QBCore.Shared.Jobs[k].grades[tostring(v.grade)].bankAuth then
                    for i=1, #job.transactions do
                        job.transactions[i].time = getTimeElapsed(time-job.transactions[i].time)
                    end
                    bankData[#bankData+1] = job
                end
            end
        end
    else
        local job = json.decode(json.encode(cachedAccounts[Player.PlayerData.job.name]))
        if job and QBCore.Shared.Jobs[Player.PlayerData.job.name].grades[tostring(Player.PlayerData.job.grade.level)].bankAuth then
            for k=1, #job.transactions do
                job.transactions[k].time = getTimeElapsed(time-job.transactions[k].time)
            end
            bankData[#bankData+1] = job
        end
    end

    local gang = json.decode(json.encode(cachedAccounts[Player.PlayerData.gang.name]))
    if gang and QBCore.Shared.Gangs[Player.PlayerData.gang.name].grades[tostring(Player.PlayerData.gang.grade.level)].bankAuth then
        for k=1, #gang.transactions do
            gang.transactions[k].time = getTimeElapsed(time-gang.transactions[k].time)
        end
        bankData[#bankData+1] = gang
    end

    local sharedAccounts = cachedPlayers[cid].accounts
    for k=1, #sharedAccounts do
        local sAccount = json.decode(json.encode(cachedAccounts[sharedAccounts[k]]))
        for i=1, #sAccount.transactions do
            sAccount.transactions[i].time = getTimeElapsed(time-sAccount.transactions[i].time)
        end
        bankData[#bankData+1] = sAccount
    end

    return bankData
end

QBCore.Functions.CreateCallback("renewed-banking:server:initalizeBanking", function(source, cb)
    local bankData = getBankData(source)
    cb(bankData)
end)

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
        MySQL.query("INSERT INTO bank_accounts_new (id, transactions) VALUES (:id, :transactions) ON DUPLICATE KEY UPDATE transactions = :transactions",{
            ['id'] = account,
            ['transactions'] = json.encode(cachedAccounts[account].transactions)
        })
    elseif cachedPlayers[account] then
        table.insert(cachedPlayers[account].transactions, 1, transaction)
        MySQL.query("INSERT INTO player_transactions (id, transactions) VALUES (:id, :transactions) ON DUPLICATE KEY UPDATE transactions = :transactions",{
            ['id'] = account,
            ['transactions'] = json.encode(cachedPlayers[account].transactions)
        })
    else
        print(Lang:t("logs.invalid_account",{account=account}))
    end
    return transaction
end exports("handleTransaction", handleTransaction)

local function getAccountMoney(account)
    if not cachedAccounts[account] then
        Lang:t("logs.invalid_account",{account=account})
        return false
    end
    return cachedAccounts[account].amount
end exports('getAccountMoney', getAccountMoney)

local function updateBalance(account)
    MySQL.query("UPDATE bank_accounts_new SET amount = ? WHERE id = ?",{ cachedAccounts[account].amount, account })
end

local function addAccountMoney(account, amount)
    if not cachedAccounts[account] then
        Lang:t("logs.invalid_account",{account=account})
        return false
    end
    cachedAccounts[account].amount += amount
    updateBalance(account)
    return true
end exports('addAccountMoney', addAccountMoney)

QBCore.Functions.CreateCallback("Renewed-Banking:server:deposit", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then
        QBCore.Functions.Notify(source, Lang:t("notify.invalid_amount",{type="deposit"}), 'error', 5000)
        cb(false)
        return
    end
    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    if not data.comment or data.comment == "" then data.comment = Lang:t("notify.comp_transaction",{name = name, type="deposited", amount = amount}) end
    if Player.Functions.RemoveMoney('cash', amount, data.comment) then
        if cachedAccounts[data.fromAccount] then
            addAccountMoney(data.fromAccount, amount)
        else
            Player.Functions.AddMoney('bank', amount, data.comment)
        end
        handleTransaction(data.fromAccount,Lang:t("ui.personal_acc") .. data.fromAccount, amount, data.comment, name, data.fromAccount, "deposit")
        local bankData = getBankData(source)
        cb(bankData)
    else
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, Lang:t("notify.not_enough_money"))
        cb(false)
    end
end)

local function removeAccountMoney(account, amount)
    if not cachedAccounts[account] then
        print(Lang:t("logs.invalid_account",{account=account}))
        return false
    end
    if cachedAccounts[account].amount < amount then
        print(Lang:t("logs.broke_account",{account=account, amount=amount}))
        return false
    end

    cachedAccounts[account].amount -= amount
    updateBalance(account)
    return true
end exports('removeAccountMoney', removeAccountMoney)

QBCore.Functions.CreateCallback("Renewed-Banking:server:withdraw", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then
        QBCore.Functions.Notify(source, Lang:t("notify.invalid_amount",{type="withdraw"}), 'error', 5000)
        cb(false)
        return
    end
    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    if not data.comment or data.comment == "" then data.comment = Lang:t("notify.comp_transaction",{name = name, type="withdrawed", amount = amount}) end

    local canWithdraw
    if cachedAccounts[data.fromAccount] then
        canWithdraw = removeAccountMoney(data.fromAccount, amount)
    else
        canWithdraw = Player.PlayerData.money.bank >= amount and Player.Functions.RemoveMoney('bank', amount, data.comment) or false
    end
    if canWithdraw then
        Player.Functions.AddMoney('cash', amount, data.comment)
        handleTransaction(data.fromAccount,Lang:t("ui.personal_acc") .. data.fromAccount, amount, data.comment, data.fromAccount, name, "withdraw")
        local bankData = getBankData(source)
        cb(bankData)
    else
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, Lang:t("notify.not_enough_money"))
        cb(false)
    end
end)

local function getPlayerData(source, id)
    local Player = QBCore.Functions.GetPlayer(tonumber(id))
    if not Player then Player = QBCore.Functions.GetPlayerByCitizenId(id) end
    if not Player then
        Player = QBCore.Functions.GetOfflinePlayerByCitizenId(id)
        if Player and not cachedPlayers[Player.PlayerData.citizenid] then
            local pushingP = promise.new()
            MySQL.query('SELECT * FROM player_transactions WHERE id = @id ', {['@id'] = id}, function(account)
                local resolve = account[1] and json.decode(account[1].transactions) or {}
                pushingP:resolve(resolve)
            end)
            local offlineTrans = Citizen.Await(pushingP)
            cachedPlayers[id] = {transactions = offlineTrans}
        end
    end
    if not Player then
        local msg = ("Cannot Find Account(%s)"):format(id)
        print(Lang:t("logs.invalid_account",{account=id}))
        if source then
            QBCore.Functions.Notify(source, msg, 'error', 5000)
        end
    end
    return Player
end

QBCore.Functions.CreateCallback("Renewed-Banking:server:transfer", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then
        QBCore.Functions.Notify(source, Lang:t("notify.invalid_amount",{type="transfer"}), 'error', 5000)
        cb(false)
        return
    end
    if cachedAccounts[data.fromAccount] then
        if not data.comment or data.comment == "" then data.comment = Lang:t("notify.comp_transaction",{name = data.fromAccount, type="transfered", amount = amount}) end
        if cachedAccounts[data.stateid] then
            local canTransfer = removeAccountMoney(data.fromAccount, amount)
            if canTransfer then
                addAccountMoney(data.stateid, amount)
                local title = ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount)
                local transaction = handleTransaction(data.fromAccount, title, amount, data.comment, cachedAccounts[data.fromAccount].name, cachedAccounts[data.stateid].name, "withdraw")
                handleTransaction(data.stateid, title, amount, data.comment, cachedAccounts[data.fromAccount].name, cachedAccounts[data.stateid].name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, Lang:t("notify.not_enough_money"))
                cb(false)
                return
            end
        else
            local Player2 = getPlayerData(source, data.stateid)
            if not Player2 then
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, Lang:t("notify.fail_transfer"))
                cb(false)
                return
            end
            local canTransfer = removeAccountMoney(data.fromAccount, amount)
            if canTransfer then
                Player2.Functions.AddMoney('bank', amount, data.comment)
                local name = ("%s %s"):format(Player2.PlayerData.charinfo.firstname, Player2.PlayerData.charinfo.lastname)
                local transaction = handleTransaction(data.fromAccount, ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount), amount, data.comment, cachedAccounts[data.fromAccount].name, name, "withdraw")
                handleTransaction(data.stateid, ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount), amount, data.comment, cachedAccounts[data.fromAccount].name, name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, Lang:t("notify.not_enough_money"))
                cb(false)
                return
            end
        end
    else
        local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
        if not data.comment or data.comment == "" then data.comment = Lang:t("notify.comp_transaction",{name = data.fromAccount, type="transfered", amount = amount}) end
        if cachedAccounts[data.stateid] then
            if Player.PlayerData.money.bank >= amount and Player.Functions.RemoveMoney('bank', amount, data.comment) then
                addAccountMoney(data.stateid, amount)
                local transaction = handleTransaction(data.fromAccount, Lang:t("ui.personal_acc") .. data.fromAccount, amount, data.comment, name, cachedAccounts[data.stateid].name, "withdraw")
                handleTransaction(data.stateid, Lang:t("ui.personal_acc") .. data.fromAccount, amount, data.comment, name, cachedAccounts[data.stateid].name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, Lang:t("notify.not_enough_money"))
                cb(false)
                return
            end
        else
            local Player2 = getPlayerData(source, data.stateid)
            if not Player2 then
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, Lang:t("notify.fail_transfer"))
                cb(false)
                return
            end

            if Player.PlayerData.money.bank >= amount and Player.Functions.RemoveMoney('bank', amount, data.comment) then
                Player2.Functions.AddMoney('bank', amount, data.comment)
                local name2 = ("%s %s"):format(Player2.PlayerData.charinfo.firstname, Player2.PlayerData.charinfo.lastname)
                local transaction = handleTransaction(data.fromAccount, Lang:t("ui.personal_acc") .. data.fromAccount, amount, data.comment, name, name2, "withdraw")
                handleTransaction(data.stateid, Lang:t("ui.personal_acc") .. data.fromAccount, amount, data.comment, name, name2, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, Lang:t("notify.not_enough_money"))
                cb(false)
                return
            end
        end
    end
    local bankData = getBankData(source)
    cb(bankData)
end)

RegisterNetEvent('Renewed-Banking:server:createNewAccount', function(accountid)
    local Player = QBCore.Functions.GetPlayer(source)
    if cachedAccounts[accountid] then QBCore.Functions.Notify(source, Lang:t("notify.account_taken"), "error") return end
    cachedAccounts[accountid] = {
        id = accountid,
        type = Lang:t("ui.org"),
        name = accountid,
        frozen = 0,
        amount = 0,
        transactions = {},
        auth = { [Player.PlayerData.citizenid] = true },
        creator = Player.PlayerData.citizenid

    }
    cachedPlayers[Player.PlayerData.citizenid].accounts[#cachedPlayers[Player.PlayerData.citizenid].accounts+1] = accountid
    MySQL.query("INSERT INTO bank_accounts_new (id, amount, transactions, auth, isFrozen, creator) VALUES (:id, :amount, :transactions, :auth, :isFrozen, :creator) ",{
        ['id'] = accountid,
        ['amount'] = cachedAccounts[accountid].amount,
        ['transactions'] = json.encode(cachedAccounts[accountid].transactions),
        ['auth'] = json.encode({Player.PlayerData.citizenid}),
        ['isFrozen'] = cachedAccounts[accountid].frozen,
        ['creator'] = Player.PlayerData.citizenid
    })
end)

RegisterNetEvent("Renewed-Banking:server:getPlayerAccounts", function()
    local Player = QBCore.Functions.GetPlayer(source)
    local accounts = cachedPlayers[Player.PlayerData.citizenid].accounts
    local data = {}
    if #accounts >= 1 then
        for k=1, #accounts do
            if cachedAccounts[accounts[k]].creator == Player.PlayerData.citizenid then
                data[#data+1] = accounts[k]
            end
        end
    end
    TriggerClientEvent("Renewed-Banking:client:accountsMenu", source, data)
end)

RegisterNetEvent("Renewed-Banking:server:viewMemberManagement", function(data)
    local Player = QBCore.Functions.GetPlayer(source)

    local account = data.account
    local retData = {
        account = account,
        members = {}
    }

    for k,_ in pairs(cachedAccounts[account].auth) do
        local Player2 = getPlayerData(source, k)
        if Player.PlayerData.citizenid ~= Player2.PlayerData.citizenid then
            local charInfo = Player2.PlayerData.charinfo
            retData.members[k] = ("%s %s"):format(charInfo.firstname, charInfo.lastname)
        end
    end

    TriggerClientEvent("Renewed-Banking:client:viewMemberManagement", Player.PlayerData.source, retData)
end)

RegisterNetEvent('Renewed-Banking:server:addAccountMember', function(account, member)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player.PlayerData.citizenid ~= cachedAccounts[account].creator then print(Lang:t("logs.illegal_action", {name=GetPlayerName(source)})) return end
    local Player2 = getPlayerData(source, member)
    if not Player2 then return end

    local targetCID = Player2.PlayerData.citizenid
    if not Player2.Offline and cachedPlayers[targetCID] then
        cachedPlayers[targetCID].accounts[#cachedPlayers[targetCID].accounts+1] = account
    end

    local auth = {}
    for k in pairs(cachedAccounts[account].auth) do auth[#auth+1] = k end
    auth[#auth+1] = targetCID
    cachedAccounts[account].auth[targetCID] = true
    MySQL.update('UPDATE bank_accounts_new SET auth = ? WHERE id = ?',{json.encode(auth), account})
end)

RegisterNetEvent('Renewed-Banking:server:removeAccountMember', function(data)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.citizenid ~= cachedAccounts[data.account].creator then print(Lang:t("logs.illegal_action", {name=GetPlayerName(source)})) return end
    local Player2 = getPlayerData(source, data.cid)
    if not Player2 then return end

    local targetCID = Player2.PlayerData.citizenid
    local tmp = {}
    for k in pairs(cachedAccounts[data.account].auth) do
        if targetCID ~= k then
            tmp[#tmp+1] = k
        end
    end

    if not Player2.Offline and cachedPlayers[targetCID] then
        local newAccount = {}
        if #cachedPlayers[targetCID].accounts >= 1 then
            for k=1, #cachedPlayers[targetCID].accounts do
                if cachedPlayers[targetCID].accounts[k] ~= data.account then
                    newAccount[#newAccount+1] = cachedPlayers[targetCID].accounts[k]
                end
            end
        end
        cachedPlayers[targetCID].accounts = newAccount
    end
    cachedAccounts[data.account].auth[targetCID] = nil
    MySQL.update('UPDATE bank_accounts_new SET auth = ? WHERE id = ?',{json.encode(tmp), data.account})
end)

local split = QBCore.Shared.SplitStr
local function updateAccountName(account, newName, src)
    if not split then split = QBCore.Shared.SplitStr end
    if not account or not newName then return false end
    if not cachedAccounts[account] then
        local getTranslation = Lang:t("logs.invalid_account",{account=account})
        print(getTranslation)
        if src then QBCore.Functions.Notify(src, split(getTranslation, '0')[2], 'error', 5000) end
        return false
    end
    if cachedAccounts[newName] then
        local getTranslation = Lang:t("logs.existing_account",{account=account})
        print(getTranslation)
        if src then QBCore.Functions.Notify(src, split(getTranslation, '0')[2], 'error', 5000) end
        return false
    end
    if src then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.PlayerData.citizenid ~= cachedAccounts[account].creator then
            local getTranslation = Lang:t("logs.illegal_action", {name=GetPlayerName(src)})
            print(getTranslation)
            QBCore.Functions.Notify(src, split(getTranslation, '0')[2], 'error', 5000)
            return false
        end
    end

    cachedAccounts[newName] = json.decode(json.encode(cachedAccounts[account]))
    cachedAccounts[newName].id = newName
    cachedAccounts[newName].name = newName
    cachedAccounts[account] = nil

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player2 = QBCore.Functions.GetPlayer(v)
        if Player2 then
            local cid = Player2.PlayerData.citizenid
            if #cachedPlayers[cid].accounts >= 1 then
                for k=1, #cachedPlayers[cid].accounts do
                    if cachedPlayers[cid].accounts[k] == account then
                        table.remove(cachedPlayers[cid].accounts, k)
                        cachedPlayers[cid].accounts[#cachedPlayers[cid].accounts+1] = newName
                    end
                end
            end
        end
    end

    MySQL.update('UPDATE bank_accounts_new SET id = ? WHERE id = ?',{newName, account})
    return true
end

RegisterNetEvent('Renewed-Banking:server:changeAccountName', function(account, newName)
    updateAccountName(account, newName, source)
end) exports("changeAccountName", updateAccountName)-- Should only use this on very secure backends to avoid anyone using this as this is a server side ONLY export --

local function addAccountMember(account, member)
    if not account or not member then return end

    if not cachedAccounts[account] then print(Lang:t("logs.invalid_account",{account=account})) return end

    local Player2 = getPlayerData(false, member)
    if not Player2 then return end

    local targetCID = Player2.PlayerData.citizenid
    if not Player2.Offline and cachedPlayers[targetCID] then
        cachedPlayers[targetCID].accounts[#cachedPlayers[targetCID].accounts+1] = account
    end

    local auth = {}
    for k, _ in pairs(cachedAccounts[account].auth) do auth[#auth+1] = k end
    auth[#auth+1] = targetCID
    cachedAccounts[account].auth[targetCID] = true
    MySQL.update('UPDATE bank_accounts_new SET auth = ? WHERE id = ?',{json.encode(auth), account})

end exports("addAccountMember", addAccountMember)

local function removeAccountMember(account, member)
    local Player2 = getPlayerData(false, member)

    if not Player2 then return end
    if not cachedAccounts[account] then print(Lang:t("logs.invalid_account",{account=account})) return end

    local targetCID = Player2.PlayerData.citizenid

    local tmp = {}
    for k in pairs(cachedAccounts[account].auth) do
        if targetCID ~= k then
            tmp[#tmp+1] = k
        end
    end

    if not Player2.Offline and cachedPlayers[targetCID] then
        local newAccount = {}
        if #cachedPlayers[targetCID].accounts >= 1 then
            for k=1, #cachedPlayers[targetCID].accounts do
                if cachedPlayers[targetCID].accounts[k] ~= account then
                    newAccount[#newAccount+1] = cachedPlayers[targetCID].accounts[k]
                end
            end
        end
        cachedPlayers[targetCID].accounts = newAccount
    end

    cachedAccounts[account].auth[targetCID] = nil

    MySQL.update('UPDATE bank_accounts_new SET auth = ? WHERE id = ?',{json.encode(tmp), account})
end exports("removeAccountMember", removeAccountMember)

exports("getAccountTransactions", function(account)
    if cachedAccounts[account] then
        return cachedAccounts[account].transactions
    elseif cachedPlayers[account] then
        return cachedPlayers[account].transactions
    end
    print(Lang:t("logs.invalid_account",{account=account}))
    return false
end)

QBCore.Commands.Add('givecash', Lang:t('menu.givecash'), {{name = 'id', help = 'Player ID'}, {name = 'amount', help = 'Amount'}}, true, function(source, args)
    local src = source
    local id = tonumber(args[1])
    local amount = math.ceil(tonumber(args[2]))
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not id or not amount then QBCore.Functions.Notify(src, Lang:t('menu.givecash'), 'error', 5000) return end

    local iPlayer = QBCore.Functions.GetPlayer(id)
    if not iPlayer then QBCore.Functions.Notify(src, Lang:t('notify.unknown_player', {id=id}), 'error', 5000) return end

    if Player.PlayerData.metadata["isdead"] then QBCore.Functions.Notify(src, Lang:t('notify.dead'), 'error', 5000) return end
    local distance = Player.PlayerData.metadata["inlaststand"] and 3.0 or 10.0
    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(id))) > distance then QBCore.Functions.Notify(src, Lang:t('notify.too_far_away'), 'error', 5000) return end
    if amount < 0 then QBCore.Functions.Notify(src, Lang:t('notify.invalid_amount', {type="give"}), 'error', 5000) return end

    if Player.Functions.RemoveMoney('cash', amount) then
        if iPlayer.Functions.AddMoney('cash', amount) then
            local nameA = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
            local nameB = ("%s %s"):format(iPlayer.PlayerData.charinfo.firstname, iPlayer.PlayerData.charinfo.lastname)
            QBCore.Functions.Notify(src, Lang:t('notify.give_cash',{id = nameB, cash = tostring(amount)}), 'success', 5000)
            QBCore.Functions.Notify(id, Lang:t('notify.received_cash',{id = nameA, cash = tostring(amount)}), 'success', 5000)
        else -- Return player cash
            Player.Functions.AddMoney('cash', amount)
        end
    else
        QBCore.Functions.Notify(id, Lang:t('notify.not_enough_money'), 'error', 5000)
    end
end)