local QBCore = exports['qb-core']:GetCoreObject()
local cachedAccounts = {}
local cachedPlayers = {}
local cachedOffline = {}

CreateThread(function()
    MySQL.query('SELECT * FROM bank_accounts_new', {}, function(accounts)
        for _,v in pairs (accounts) do
            local job = v.id
            v.auth = json.decode(v.auth)
            cachedAccounts[job] = { --  cachedAccounts[#cachedAccounts+1]
                id = job,
                type = "Organization",
                name = QBCore.Shared.Jobs[job] and QBCore.Shared.Jobs[job].label or job,
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

     -- Before
    local org = json.decode(json.encode(cachedAccounts[Player.PlayerData.job.name]))
    if org and QBCore.Shared.Jobs[Player.PlayerData.job.name].grades[tostring(Player.PlayerData.job.grade.level)].bankAuth then
        for k=1, #org.transactions do
            org.transactions[k].time = getTimeElapsed(time-org.transactions[k].time)
        end
        bankData[#bankData+1] = org
    end

    local sharedAccounts = cachedPlayers[Player.PlayerData.citizenid].accounts
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
        MySQL.query("INSERT INTO bank_accounts_new (id, amount, transactions) VALUES (:id, :amount, :transactions) ON DUPLICATE KEY UPDATE amount = :amount, transactions = :transactions",{
            ['id'] = account,
            ['amount'] = cachedAccounts[account].amount,
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

local function getAccountMoney(account)
    if not cachedAccounts[account] then
        print(("^6[^4Renewed-Banking^6] ^0 Account not found (%s)"):format(account))
        return false
    end
    return cachedAccounts[account].amount
end exports('getAccountMoney', getAccountMoney)

local function addAccountMoney(account, amount)
    if not cachedAccounts[account] then
        print(("^6[^4Renewed-Banking^6] ^0 Account not found (%s)"):format(account))
        return false
    end
    cachedAccounts[account].amount += amount
    return cachedAccounts[account].amount
end exports('addAccountMoney', addAccountMoney)

QBCore.Functions.CreateCallback("Renewed-Banking:server:deposit", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not data then print("^6[^4Renewed-Banking^6] ^0 No Data Recieved From Client "..GetPlayerName(source)) end
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then QBCore.Functions.Notify(source, 'Invalid amount to deposit', 'error', 5000) end
    if not data.comment or data.comment == "" then data.comment = ("%s %s has deposited $%s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, amount) end
    if Player.Functions.RemoveMoney('cash', amount, data.comment) then
        if cachedAccounts[data.fromAccount] then
            addAccountMoney(data.fromAccount, amount)
        else
            Player.Functions.AddMoney('bank', amount, data.comment)
        end
        local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
        handleTransaction(data.fromAccount,"Personal Account / " .. data.fromAccount, amount, data.comment, name, data.fromAccount, "deposit")
        local bankData = getBankData(source)
        cb(bankData)
    else
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Account does not have enough money!")
        cb(false)
    end
end)

local function removeAccountMoney(account, amount)
    if not cachedAccounts[account] then
        print(("^6[^4Renewed-Banking^6] ^0 Account not found (%s)"):format(account))
        return false
    end
    if cachedAccounts[account].amount < amount then
        print(("^6[^4Renewed-Banking^6] ^0 Account(%s) is too broke with balance of $%s"):format(account, amount))
        return false
    end

    cachedAccounts[account].amount -= amount
    return true
end exports('removeAccountMoney', removeAccountMoney)

QBCore.Functions.CreateCallback("Renewed-Banking:server:withdraw", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not data then print("^6[^4Renewed-Banking^6] ^0 No Data Recieved From Client "..GetPlayerName(source)) end
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then QBCore.Functions.Notify(source, 'Invalid amount to withdraw', 'error', 5000) end
    if not data.comment or data.comment == "" then data.comment = ("%s %s has withdrawed $%s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, amount) end

    local canWithdraw = false
    if cachedAccounts[data.fromAccount] then
        canWithdraw = removeAccountMoney(data.fromAccount, amount)
    else
        canWithdraw = Player.Functions.RemoveMoney('bank', amount, data.comment)
    end
    if canWithdraw then
        Player.Functions.AddMoney('cash', amount, data.comment)
        local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
        handleTransaction(data.fromAccount,"Personal Account / " .. data.fromAccount, amount, data.comment, data.fromAccount, name, "withdraw")
        local bankData = getBankData(source)
        cb(bankData)
    else
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, "Account does not have enough money!")
        cb(false)
    end
end)

local function getPlayerData(source, id)
    local Player = QBCore.Functions.GetPlayer(tonumber(id))
    if not Player then Player = QBCore.Functions.GetPlayerByCitizenId(id) end
    if not Player then
        Player = QBCore.Functions.GetOfflinePlayerByCitizenId(id)
        if Player and not cachedPlayers[Player.PlayerData.citizenid] then
            local offlineTrans = {}
            local pushingP = promise.new()
            MySQL.query('SELECT * FROM player_transactions WHERE id = @id ', {['@id'] = cid}, function(account)
                pushingP:resolve(json.decode(account[1].transactions))
            end)
            offlineTrans = Citizen.Await(pushingP)
            cachedPlayers[cid] = {transactions = offlineTrans}
        end
    end
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
            local canTransfer = removeAccountMoney(data.fromAccount, amount)
            if canTransfer then
                addAccountMoney(data.stateid, amount)
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
            local canTransfer = removeAccountMoney(data.fromAccount, amount)
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
                addAccountMoney(data.stateid, amount)
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

RegisterNetEvent('Renewed-Banking:server:createNewAccount', function(accountid)
    local Player = QBCore.Functions.GetPlayer(source)
    if cachedAccounts[accountid] then QBCore.Functions.Notify(source, "Account ID is already in use", "error") return end
    cachedAccounts[accountid] = {
        id = accountid,
        type = "Organization",
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

    local table = {{
        isMenuHeader = true,
        header = "Los Santos Banking"
    }}
    local accounts = cachedPlayers[Player.PlayerData.citizenid].accounts
    if #accounts >= 1 then
        for k=1, #accounts do
            if cachedAccounts[accounts[k]].creator == Player.PlayerData.citizenid then
                table[#table+1] = {
                    header = accounts[k],
                    txt = "View All Account Members!",
                    params = {
                        isServer =true,
                        event = 'Renewed-Banking:server:viewAccountMenu',
                        args = {
                            account = accounts[k],
                        }
                    }
                }
            end
        end
    end
    if #table == 1 then
        table[#table+1] = {
            header = "Account Not Found",
            txt = "You need to be the creator",
            isMenuHeader = true
        }
    end
    TriggerClientEvent("qb-menu:client:openMenu", source, table)
end)

RegisterNetEvent("Renewed-Banking:server:viewAccountMenu", function(data)
    local Player = QBCore.Functions.GetPlayer(source)

    local table = {{
        isMenuHeader = true,
        header = "Los Santos Banking"
    }}
    local account = data.account
    for k,_ in pairs(cachedAccounts[account].auth) do
        local Player2 = getPlayerData(source, k)
        local charInfo = Player2.PlayerData.charinfo
        if Player.PlayerData.citizenid ~= Player2.PlayerData.citizenid then
            table[#table+1] = {
                header = ("%s %s"):format(charInfo.firstname, charInfo.lastname),
                txt = "Remove Account Member!",
                params = {
                    isServer =true,
                    event = 'Renewed-Banking:server:removeMemberConfirmation',
                    args = {
                        account = account,
                        cid = k,
                    }
                }
            }
        end
    end
    table[#table+1] = {
        header = "Add Citizen To Account",
        txt = "Be careful who youu add(Requires Citizen ID)",
        params = {
            event = 'Renewed-Banking:client:addAccountMember',
            args = {
                account = account
            }
        }
    }
    TriggerClientEvent("qb-menu:client:openMenu", source, table)
end)

RegisterNetEvent('Renewed-Banking:server:addAccountMember', function(account, member)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player.PlayerData.citizenid ~= cachedAccounts[account].creator then print(("^6[^4Renewed-Banking^6] ^0 %s has attempted to add someone to an account they didnt create."):format(GetPlayerName(source))) return end
    local Player2 = getPlayerData(source, member)
    if not Player2 then print(("^6[^4Renewed-Banking^6] ^0 Player with ID '%s' could not be found."):format(member)) return end

    local targetCID = Player2.PlayerData.citizenid
    if not Player2.Offline and cachedPlayers[targetCID] then
        cachedPlayers[targetCID].accounts[#cachedPlayers[targetCID].accounts+1] = account
    end

    local auth = {}
    for k,v in pairs(cachedAccounts[account].auth) do auth[#auth+1] = k end
    auth[#auth+1] = targetCID
    cachedAccounts[account].auth[targetCID] = true
    MySQL.update('UPDATE bank_accounts_new SET auth = ? WHERE id = ?',{json.encode(auth), account})
end)

RegisterNetEvent('Renewed-Banking:server:removeMemberConfirmation', function(data)
    local Player = QBCore.Functions.GetPlayer(source)
    local table = {
        {
            isMenuHeader = true,
            header = "Los Santos Banking"
        },
        {
            header = 'Go Back',
            icon = "fa-solid fa-angle-left",
            params = {
                isServer =true,
                event = "Renewed-Banking:server:viewAccountMenu",
                args = data
            }
        },
        {
            header = ("Are you sure you want to Citizen?"),
            txt = ("CitizenID: %s; Their is no going back."):format(data.cid),
            params = {
                isServer =true,
                event = 'Renewed-Banking:server:removeAccountMember',
                args = data
            }
        }
    }

    TriggerClientEvent("qb-menu:client:openMenu", source, table)

end)

RegisterNetEvent('Renewed-Banking:server:removeAccountMember', function(data)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.citizenid ~= cachedAccounts[data.account].creator then print(("^6[^4Renewed-Banking^6] ^0 %s has attempted to add someone to an account they didnt create."):format(GetPlayerName(source))) return end
    local Player2 = getPlayerData(source, data.cid)
    if not Player2 then print(("^6[^4Renewed-Banking^6] ^0 Player with ID '%s' could not be found."):format(data.cid)) return end

    local targetCID = Player2.PlayerData.citizenid
    local tmp = {}
    if not Player2.Offline and cachedPlayers[targetCID] then
        for k in pairs(cachedAccounts[data.account].auth) do
            if targetCID ~= k then
                tmp[#tmp+1] = k
            end
        end
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
