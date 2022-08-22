local QBCore = exports['qb-core']:GetCoreObject()
local cachedAccounts = {}
local cachedPlayers = {}

local function isWhitelisted(Organization)
    return config.whitelistedJobs[Organization] or config.whitelistedGangs[Organization]
end

CreateThread(function()
    for k,_ in pairs(QBCore.Shared.Jobs) do
        local org = isWhitelisted(k)
        if org then
            MySQL.query('SELECT * FROM bank_test where id = ?', {k}, function(accounts)
                if #accounts <1 then print(('^6[^4Renewed-Banking^6] ^0 "%s" missing from database, Please run SQL or add the job to the database!'):format(k)) return end
                for _,v in pairs (accounts) do
                    cachedAccounts[#cachedAccounts+1] = {
                        id = k,
                        type = "Organization",
                        name = org.label,
                        frozen = v.isFrozen,
                        amount = v.amount,
                        transactions = json.decode(v.transactions),
                    }
                end
                print(json.encode(cachedAccounts))
            end)
        else
            print(('^6[^4Renewed-Banking^6] ^0 "%s" Is not whitelisted, Please modify your job or gang table!'):format(k))
        end
    end
end)

QBCore.Functions.CreateCallback("renewed-banking:server:initalizeBanking", function(source, cb)
	local Player = QBCore.Functions.GetPlayer(source)
    local clonedTable = json.decode(json.encode(cachedAccounts))
    local playerData = {
        id = Player.PlayerData.citizenid,
        type = "Personal",
        name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
        frozen = false,
        amount = Player.PlayerData.money.bank,
        cash = Player.PlayerData.money.cash,
        transactions = {},
    }
    table.insert(clonedTable, 1, playerData)
    cb(clonedTable)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()

end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
	local Player = QBCore.Functions.GetPlayer(source)
end)