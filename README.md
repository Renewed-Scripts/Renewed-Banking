# Renewed-Banking

# Project Description
NoPixel Inspired Banking System Recreated In Svelte.

# Dependencies
* [oxmysql](https://github.com/overextended/oxmysql)
* [qb-core](https://github.com/qbcore-framework)
* [qb-target](https://github.com/qbcore-framework/qb-target)

# Installation

1) Insert the SQL provided

2) Edit your QBCore/Shared/jobs.lua and add `bankAuth = true` to the job grades which have access to society funds

## Transaction Integrations

```lua
exports['Renewed-Banking']:handleTransaction(account, title, amount, message, issuer, receiver, type, transID)
 ---@param account<string> - job name or citizenid
 ---@param title<string> - Title of transaction example `Personal Account / ${Player.PlayerData.citizenid}`
 ---@param amount<number> - Amount of money being transacted
 ---@param message<string> - Description of transaction
 ---@param issuer<string> - Name of Business or Character issuing the bill
 ---@param receiver<string> - Name of Business or Character receiving the bill
 ---@param type<string> - deposit | withdraw
 ---@param transID<string> - (optional) Force a specific transaction ID instead of generating one.

---@return transaction<table> {
  ---@param trans_id<string> - Transaction ID for the created transaction
  ---@param amount<number> - Amount of money being transacted
  ---@param trans_type<string> - deposit | withdraw
  ---@param receiver<string> - Name of Business or Character receiving the bill
  ---@param message<string> - Description of transaction
  ---@param issuer<string> - Name of Business or Character issuing the bill
  ---@param time<number> - Epoch timestamp of transaction
---}


exports['Renewed-Banking']:getAccountMoney(account)
 ---@param account<string> - Job Name | Custom Account Name

---@return amount<number> - Amount of money account has or false

exports['Renewed-Banking']:addAccountMoney(account, amount)
 ---@param account<string> - Job Name | Custom Account Name
  ---@param amount<number> - Amount of money being transacted

---@return complete<boolean> - true | false

exports['Renewed-Banking']:removeAccountMoney(account, amount)
 ---@param account<string> - Job Name | Custom Account Name
  ---@param amount<number> - Amount of money being transacted

---@return complete<boolean> - true | false
```
