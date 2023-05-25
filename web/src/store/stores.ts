import { writable } from "svelte/store";

export const visibility = writable(false);
export const loading = writable(false);
export const notify = writable("");
export let activeAccount = writable(null);
export const atm = writable(false);
export const currency = writable("USD");

export let popupDetails = writable({
    account: {},
    actionType: "",
});

export const accounts = writable<any>([
    {
        id: "a54sd6as54d6as4d6as",
        type: "Personal", // or Organization
        name: "John Doe", // or organization name
        cash: 100,
        amount: 100000, // AVAILABLE BALANCE
        transactions: [{"time":1672278383,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"e14c32cd-4f06-4d60-bd5f-452ff41dd0fa"},{"time":1672277783,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"f84dd608-0201-425f-9add-ed0af4f15379"},{"time":1672277183,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"b9160085-e2c0-464c-9e34-b77ab67053bd"},{"time":1672276583,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"c847b0a4-4d79-4494-b40e-4a91f452cbe8"},{"time":1672275983,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"7568565a-584a-4a0f-853d-3d9a7c8f5230"},{"time":1672275383,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"2c9ba8aa-1985-4322-aa59-b9217915e254"},{"time":1672274783,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"7d7fbc4b-00ce-4247-8a77-0ed2bf8a8550"},{"time":1672274183,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"d16b73b9-8393-4bf8-a97a-1957d629f89c"},{"time":1672273583,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"62f13136-804c-4371-a897-71885d428d13"},{"time":1672272983,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"e862df0d-f3fb-400b-a89b-0043f68e3484"},{"time":1672272383,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"a74f9c30-7064-4d0f-a0d4-9c620d39e059"},{"time":1672271783,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"cd23fd92-d0ca-4939-9ace-cd2bad7598e1"},{"time":1672271183,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"8dd20abb-416c-48b8-838e-e201c8f74d8a"},{"time":1672263382,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"f7c783e9-3400-4b62-a805-a12c45e074af"},{"time":1672262782,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"0e5384ef-9313-41b3-9e3a-e66d9a44d1ae"},{"time":1672262182,"amount":100,"trans_type":"deposit","title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"3d0d022c-618f-4319-88ab-eef8ca64a577"},{"trans_type":"deposit","amount":10,"time":1671871065,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"6ee880ed-254d-43d3-aa89-9452b449438f"},{"trans_type":"deposit","amount":10,"time":1671870465,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"b4219279-0242-4ab2-8477-5e8fead8fc4a"},{"trans_type":"deposit","amount":10,"time":1671869865,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"d2d9b117-2731-4bbc-8ae9-a80f8d611e6a"},{"trans_type":"deposit","amount":10,"time":1671869265,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"6910f6c2-04b0-4cd2-b19f-f5bda829cf41"},{"trans_type":"deposit","amount":10,"time":1671868665,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"0f360bc6-3537-4272-a428-b94218cb0ab0"},{"trans_type":"deposit","amount":10,"time":1671868065,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"59a3090a-1ef5-4a90-aef7-04e502507fe7"},{"trans_type":"deposit","amount":10,"time":1671750552,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"747df254-3c81-4a1f-ab83-1acc813664ad"},{"trans_type":"deposit","amount":10,"time":1671749951,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"8d48de68-3eec-4daa-990f-2b485a38021c"},{"trans_type":"deposit","amount":10,"time":1671749351,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"cd6c43c9-e26e-487b-955f-e10752b5537b"},{"trans_type":"deposit","amount":10,"time":1671748751,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"07b53e04-0aac-4a1f-a259-8573d01159e8"},{"trans_type":"deposit","amount":10,"time":1671748151,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"968b277d-b525-49d7-ab1b-04518bea9241"},{"trans_type":"deposit","amount":10,"time":1671747551,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"0e111914-99fc-4811-bcec-0817f0390df9"},{"trans_type":"deposit","amount":10,"time":1671746951,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"3c5a1065-a2b7-4344-9108-134fac9b3439"},{"trans_type":"deposit","amount":10,"time":1671746351,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"07eb76ad-d650-4926-a08a-e206a46759e4"},{"trans_type":"deposit","amount":10,"time":1671745751,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"c1cf2d3f-b16c-4597-b610-c96aab399d92"},{"trans_type":"deposit","amount":10,"time":1671745151,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"1a8bc46a-9e0b-4041-94c9-209fec1d8f0e"},{"trans_type":"deposit","amount":10,"time":1671744551,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"6aafe806-c046-4ac9-903b-81f959d4b40d"},{"trans_type":"deposit","amount":10,"time":1671743951,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"7c2e72ed-2149-4434-ac71-e6f4640daa15"},{"trans_type":"deposit","amount":10,"time":1671743351,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"90a8f9fa-199f-4b7b-8235-d902f4cd62c6"},{"trans_type":"deposit","amount":10,"time":1671742751,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"bdd038d2-8b9d-4800-aaf0-d65334708e71"},{"trans_type":"deposit","amount":10,"time":1671742151,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"b03da4ac-6f9f-4d99-adb7-dc4dbcd26023"},{"trans_type":"deposit","amount":10,"time":1671741551,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"39c7ce29-bad3-420a-846d-977fa04fdf37"},{"trans_type":"deposit","amount":10,"time":1671740951,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"15491bd4-bb3e-4d99-9c9b-a17c05336b90"},{"trans_type":"deposit","amount":10,"time":1671740351,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"e366ff36-7e04-44b6-8734-29d4e0e08cf3"},{"trans_type":"withdraw","amount":4000,"time":1671739924,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Tyrese Jenkins has withdrawed $4000","issuer":"1002","trans_id":"8feed0a8-ece7-4527-a693-cef8c4322b09"},{"trans_type":"withdraw","amount":100,"time":1671739915,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Tyrese Jenkins has withdrawed $100","issuer":"1002","trans_id":"2aaea67b-b982-4b57-b3f4-ed410ca57e64"},{"trans_type":"deposit","amount":10,"time":1671739751,"title":"Personal Account / 1002","receiver":"Tyrese Jenkins","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"7e0bccb7-488f-4413-9517-edd7eb93599f"},{"trans_type":"deposit","amount":125,"time":1663694290,"title":"Personal Account / 1002","receiver":"32 32","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"367a3892-2ac0-4331-882e-f589502bbe73"},{"trans_type":"deposit","amount":125,"time":1663693690,"title":"Personal Account / 1002","receiver":"32 32","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"34bbe084-c166-45b1-aaf8-fbfc96731a37"},{"trans_type":"deposit","amount":125,"time":1663693090,"title":"Personal Account / 1002","receiver":"32 32","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"a2cbf964-cd50-4394-bc7f-3d9a303f74d0"},{"trans_type":"deposit","amount":125,"time":1663692490,"title":"Personal Account / 1002","receiver":"32 32","message":"Los Santos Government Paycheck","issuer":"Government","trans_id":"7070a114-5008-4fac-a22a-4af09f7a3f19"}],
    },

    {
        id: "8a97sd64as34d67sa86453",
        type: "Organization", // or personal
        name: "MicroSoft Corp", // or organization name
        amount: 750000, // AVAILABLE BALANCE
        citizen_id: "65a4sd654asd654sa",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "a6s84d531asd4648as7d68",
                account: "Personal", //savings
                amount: 1200,
                trans_type: "withdraw",
                receiver: "John",
                unknown: "fgfgfgffgfgfgfgf",
                time: 1663692490,
                message: "Paycheck withdrawn for support",
            },
        ],
    },
]);

export const translations = writable<any>({
    "weeks": "%s weeks ago",
    "aweek": "A week ago",
    "days": "%s days ago",
    "aday": "A day ago",
    "hours": "%s hours ago",
    "ahour": "A hour ago",
    "mins": "%s minutes ago",
    "amin": "A minute ago",
    "secs": "A few seconds ago",
    "renewed_banking": "^6[^4Renewed-Banking^6]^0",
    "invalid_account": "${renewed_banking} Account not found (%s)",
    "broke_account": "${renewed_banking} Account(%s) is too broke with balance of $%s",
    "illegal_action": "${renewed_banking} %s has attempted to perform an action to an account they didnt create.",
    "existing_account": "${renewed_banking} Account %s already exsist",
    "invalid_amount": "Invalid amount to %s",
    "not_enough_money": "Account does not have enough funds!",
    "comp_transaction": "%s has %s $%s",
    "fail_transfer": "Failed to transfer to unknown account!",
    "account_taken": "Account ID is already in use",
    "unknown_player": "Player with ID '%s' could not be found.",
    "loading_failed": "Failed to load Banking Data!",
    "dead": "Action failed, you're dead ",
    "too_far_away": "Action failed, too far away",
    "give_cash": "Successfully gave $%s to ID %s",
    "received_cash": "Successfully received $%s from ID %s",
    "missing_params": "You have not provided all the required parameters!",
    "bank_name": "Los Santos Banking",
    "view_members": "View All Account Members!",
    "no_account": "Account Not Found",
    "no_account_txt": "You need to be the creator",
    "manage_members": "Manage Account Members",
    "manage_members_txt": "View Existing & Add Members",
    "edit_acc_name": "Change Account Name",
    "edit_acc_name_txt": "Transactions wont update old names",
    "remove_member_txt": "Remove Account Member!",
    "add_member": "Add Citizen To Account",
    "add_member_txt": "Be careful who youu add(Requires Citizen ID)",
    "remove_member": "Are you sure you want to remove Citizen?",
    "remove_member_txt2": "CitizenID: %s; Their is no going back.",
    "back": "Go Back",
    "view_bank": "View Bank Account",
    "manage_bank": "Manage Bank Account",
    "create_account": "Create New Account",
    "create_account_txt": "Create a new sub bank account!",
    "manage_account": "Manage Existing Accounts",
    "manage_account_txt": "View existing accounts!",
    "account_id": "Account ID (NO SPACES)",
    "change_account_name": "Change Account Name",
    "citizen_id": "Citizen/State ID",
    "add_account_member": "Add Account Member",
    "givecash": "Usage /givecash [ID] [AMOUNT]",
    "account_title": " Account / ",
    "account": " Account ",
    "amount": "Amount",
    "comment": "Comment",
    "transfer": "Business or Citizen ID",
    "cancel": "Cancel",
    "confirm": "Submit",
    "cash": "Cash: $",
    "transactions": "Transactions",
    "select_account": "Select any Account",
    "message": "Message",
    "accounts": "Accounts",
    "balance": "Available Balance",
    "frozen": "Account Status: Frozen",
    "org": "Organization",
    "personal": "Personal",
    "personal_acc": "Personal Account / ",
    "deposit_but": "Deposit",
    "withdraw_but": "Withdraw",
    "transfer_but": "Transfer",
    "open_bank": "Opening Bank",
    "open_atm": "Opening ATM",
    "canceled": "Canceled...",
    "ui_not_built": "Unable to load UI. Build Renewed-Banking or download the latest release.\n   ^https://github.com/Renewed-Scripts/Renewed-Banking/releases/latest/download/Renewed-Banking.zip^0\n    If you are using a custom build of the UI, please make sure the resource name is Renewed-Banking (you may not rename the resource).",
    "cmd_plyr_id": "Target player's server id",
    "cmd_amount": "Amount of money to give",
    "delete_account": "Delete Account",
    "delete_account_txt": "Delete Created Account",
    "err_trans_account": "${renewed_banking} Invalid Account ID provided to handleTransaction! Account=%s",
    "err_trans_title": "${renewed_banking} Invalid Title provided to handleTransaction! Title=%s",
    "err_trans_amount": "${renewed_banking} Invalid Amount provided to handleTransaction! Amount=%s",
    "err_trans_message": "${renewed_banking} Invalid Message provided to handleTransaction! Message=%s",
    "err_trans_issuer": "${renewed_banking} Invalid Issuer provided to handleTransaction! Issuer=%s",
    "err_trans_receiver": "${renewed_banking} Invalid Receiver provided to handleTransaction! Receiver=%s",
    "err_trans_type": "${renewed_banking} Invalid Type provided to handleTransaction! Type=%s",
    "err_trans_transID": "${renewed_banking} Invalid TransID provided to handleTransaction! TransID=%s",
    "trans_search": "Transaction Search (Message, TransID, Receiver)...",
    "trans_not_found": "No transactions found",
    "export_data": "Export Transaction Data",
    "account_search": "Account Search...",
    "account_not_found": "No accounts found"
});
