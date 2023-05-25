# Renewed-Banking 2.0.0
<a href='https://ko-fi.com/ushifty' target='_blank'><img height='35' style='border:0px;height:46px;' src='https://az743702.vo.msecnd.net/cdn/kofi3.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' />
 
 [Renewed Discord](https://discord.gg/P3RMrbwA8n)

# Project Description
This resource is created & maintained by uShifty#1733 and was not a fork of any of the other banking resources.
The legacy UI was heavily inspired by No Pixel 3.0
The 2.0 UI was redesigned by [qwadebot](https://github.com/qw-scripts) Edited by [uShifty](https://github.com/uShifty)


# Dependencies
* [oxmysql](https://github.com/overextended/oxmysql)
* [ox-lib](https://github.com/overextended/ox_lib)
* [ox-target](https://github.com/overextended/ox_target)
Note: Supports QBCore and ESX. You can easily add support for other frameworks by editing the Framework.lua
 
# Features
* Personal, Job, Gang, Shared Accounts
* Withdraw, Deposit, Transfer between accounts
* Optimized Resource (0.00ms Running At All Times)

# Installation

1) Insert the SQL provided

2) Integrate the exports found below in any external resource that needs them
 
## Transaction Integrations

```lua
 -- Place this export anywhere that interacts with a Players bank account. (Where it adds or removes money from bank)
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

# QBCore additional Installation Steps 
## qb-managment conversion
```lua
exports['qb-management']:GetAccount => exports['Renewed-Banking']:getAccountMoney
exports['qb-management']:AddMoney => exports['Renewed-Banking']:addAccountMoney
exports['qb-management']:RemoveMoney => exports['Renewed-Banking']:removeAccountMoney
exports['qb-management']:GetGangAccount=> exports['Renewed-Banking']:getAccountMoney
exports['qb-management']:AddGangMoney=> exports['Renewed-Banking']:addAccountMoney
exports['qb-management']:RemoveGangMoney=> exports['Renewed-Banking']:removeAccountMoney
```
## Society Bank Access
Edit your QBCore/Shared/jobs.lua and QBCore/Shared/gangs.lua and add `bankAuth = true` to the job/gang grades which have access to society funds


 ## Change Logs
<details>
 <summary>View History</summary>

 V2.0.0
 ```
 New UI Design
 ESX Support Added
 QB Dependacies switched to OX
 Massive server side optimizations
 Rework inital codebase
 Delete created accounts
 ```
 
 V1.0.5
 ```
 Fix OX integration being ATM only
 Added Renewed Phones MultiJob Support (Enable in config)
 Fix onResourceStop errors for QB target users
 Fixed a couple Account Menu bugs from 1.0.4 OX integration
 Slight client side cleanup
 Fix exploit allowing players to highjack sub accounts
 ```
 
 v1.0.4
 ```
 Add server export to get an accounts transactions.
 Add /givecash command
 Added ox lib and target support
 ```
 
 V1.0.3
 ```
 Fixes the default message when no message is provided when transferring
 Added Bank Checks for those who dont like to configure their QBCore
 Added a check to ensure player cache exists
 Fixed bug with shared accounts and entering a negative value
 ```
 
 V1.0.2
 ```
 Added Gangs To SQL
 Disabled Deposit At ATM Machines
 Fix Error "Form Submission Canceled"
 QBCore Locale System Implementation
 Implemented Translations To UI (No Need To Edit UI Anymore)
 Fix Balance & Transactions Update
 Fix Transaction Default Message
 ```

 V1.0.1
 ```
 Added Banking Blips
 ```
</details>
