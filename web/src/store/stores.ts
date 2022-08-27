import { writable } from "svelte/store";

export const visibility = writable(false);
export const loading = writable(false);
export const notify = writable("");
export let activeAccount = writable(null);

export let popupDetails = writable({
    account: {},
    actionType: "",
});

export const accounts = writable<any>([
    {
        id: "a54sd6as54d6as4d6as",
        type: "Personal", // or Organization
        name: "John Doe", // or organization name
        amount: 100000, // AVAILABLE BALANCE
        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "a6s54d6sa54d65sa4d6as5",
                account: "Personal", //savings
                amount: 1500,
                trans_type: "withdraw",
                receiver: "Microsoft",
                unknown: "fgfgfgffgfgfgfgf",
                time: "0 seconds ago",
                message: "Paycheck withdrawn for support",
            },
            {
                trans_id: "65as4d6as54d65sa4dsa6",
                account: "Personal", //savings
                amount: 2700,
                trans_type: "transfer",
                receiver: "Taiga",
                unknown: "fgfgfgffgfgfgfgf",
                time: "2 months ago",
                message: "Payment sent to help for business",
            },
            {
                trans_id: "6a5s4d6as54dsa6da6",
                account: "Personal", //savings
                amount: 1200,
                trans_type: "withdraw",
                receiver: "John",
                unknown: "fgfgfgffgfgfgfgf",
                time: "1 minute ago",
                message: "Paycheck withdrawn for support",
            },

            {
                trans_id: "5as6d46as4d56as",
                account: "Personal", //savings
                amount: 1500,
                trans_type: "withdraw",
                receiver: "Microsoft",
                unknown: "fgfgfgffgfgfgfgf",
                time: "0 seconds ago",
                message: "Paycheck withdrawn for support",
            },
            {
                trans_id: "a1s3d6a8s4d3as1d",
                account: "Personal", //savings
                amount: 2700,
                trans_type: "transfer",
                receiver: "Taiga",
                unknown: "fgfgfgffgfgfgfgf",
                time: "2 months ago",
                message: "Payment sent to help for business",
            },
            {
                trans_id: "654as3d1asd53as4d31as",
                account: "Personal", //savings
                amount: 1200,
                trans_type: "withdraw",
                receiver: "John",
                unknown: "fgfgfgffgfgfgfgf",
                time: "1 minute ago",
                message: "Paycheck withdrawn for support",
            },
        ],
    },

    {
        id: "556a4sd65a4sd65sa4das6",
        type: "Organization", // or personal
        name: "MicroSoft Corp", // or organization name
        amount: 750000, // AVAILABLE BALANCE
        citizen_id: "65a4sd654asd654sa",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "6a5s4d6as54dsa6da6",
                account: "Personal", //savings
                amount: 1200,
                trans_type: "withdraw",
                receiver: "John",
                unknown: "fgfgfgffgfgfgfgf",
                time: "1 minute ago",
                message: "Paycheck withdrawn for support",
            },
        ],
    },

    {
        id: "6a4sd564sa6d4sa6d",
        type: "Personal", // or organization
        name: "John Doe", // or organization name
        amount: 100000, // AVAILABLE BALANCE
        citizen_id: "4as6a5s4d6as54d6as54",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "65a4s6d54as6d4sa",
                account: "Personal", //savings
                amount: 1500,
                trans_type: "withdraw",
                receiver: "Microsoft",
                unknown: "fgfgfgffgfgfgfgf",
                time: "0 seconds ago",
                message: "Paycheck withdrawn for support",
            },
            {
                trans_id: "654asd654sa6d45sa",
                account: "Personal", //savings
                amount: 2700,
                trans_type: "transfer",
                receiver: "Taiga",
                unknown: "fgfgfgffgfgfgfgf",
                time: "2 months ago",
                message: "Payment sent to help for business",
            },
        ],
    },

    {
        id: "65a4s6d5a4sd5sa4d6as",
        type: "Organization", // or personal
        name: "MicroSoft Corp", // or organization name
        amount: 750000, // AVAILABLE BALANCE
        citizen_id: "65a4sd654asd654sa",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "65a4sd654as6dsa",
                account: "Personal", //savings
                amount: 1200,
                trans_type: "withdraw",
                receiver: "John",
                unknown: "fgfgfgffgfgfgfgf",
                time: "1 minute ago",
                message: "Paycheck withdrawn for support",
            },
        ],
    },

    {
        id: "a65a4d6sa5dsa2d3a1s",
        type: "Personal", // or organization
        name: "John Doe", // or organization name
        amount: 100000, // AVAILABLE BALANCE
        citizen_id: "4as6a5s4d6as54d6as54",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "a6s54d65as4d3sa21",
                account: "Personal", //savings
                amount: 1500,
                trans_type: "withdraw",
                receiver: "Microsoft",
                unknown: "fgfgfgffgfgfgfgf",
                time: "0 seconds ago",
                message: "Paycheck withdrawn for support",
            },
            {
                trans_id: "as654d6as45d3a1sd3as",
                account: "Personal", //savings
                amount: 2700,
                trans_type: "transfer",
                receiver: "Taiga",
                unknown: "fgfgfgffgfgfgfgf",
                time: "2 months ago",
                message: "Payment sent to help for business",
            },
        ],
    },

    {
        id: "5a4s6d8as3d21sa3d51as",
        type: "Organization", // or personal
        name: "MicroSoft Corp", // or organization name
        amount: 750000, // AVAILABLE BALANCE
        citizen_id: "65a4sd654asd654sa",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "as4d4asd3sa3sa8d41as2d1",
                account: "Personal", //savings
                amount: 1200,
                trans_type: "withdraw",
                receiver: "John",
                unknown: "fgfgfgffgfgfgfgf",
                time: "1 minute ago",
                message: "Paycheck withdrawn for support",
            },
        ],
    },

    {
        id: "6as4d186a4d3as1d46d",
        type: "Personal", // or organization
        name: "John Doe", // or organization name
        amount: 100000, // AVAILABLE BALANCE
        citizen_id: "4as6a5s4d6as54d6as54",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "6as8d14as354dd1a8s34da3",
                account: "Personal", //savings
                amount: 1500,
                trans_type: "withdraw",
                receiver: "Microsoft",
                unknown: "fgfgfgffgfgfgfgf",
                time: "0 seconds ago",
                message: "Paycheck withdrawn for support",
            },
            {
                trans_id: "a6s84d16a5s14d6as83a45s1d3",
                account: "Personal", //savings
                amount: 2700,
                trans_type: "transfer",
                receiver: "Taiga",
                unknown: "fgfgfgffgfgfgfgf",
                time: "2 months ago",
                message: "Payment sent to help for business",
            },
        ],
    },

    {
        id: "a56s4d31sad43sad132as4d65",
        type: "Organization", // or personal
        name: "MicroSoft Corp", // or organization name
        amount: 750000, // AVAILABLE BALANCE
        citizen_id: "65a4sd654asd654sa",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "a6s54d13as8d43d1sa3d21",
                account: "Personal", //savings
                amount: 1200,
                trans_type: "withdraw",
                receiver: "John",
                unknown: "fgfgfgffgfgfgfgf",
                time: "1 minute ago",
                message: "Paycheck withdrawn for support",
            },
        ],
    },

    {
        id: "5as46d54asd32as16as4d6as",
        type: "Personal", // or organization
        name: "John Doe", // or organization name
        amount: 100000, // AVAILABLE BALANCE
        citizen_id: "4as6a5s4d6as54d6as54",

        transactions: [
            // ARRAY OF TRANSACTIONS
            {
                trans_id: "6a5s4d168d431d3sad143",
                account: "Personal", //savings
                amount: 1500,
                trans_type: "withdraw",
                receiver: "Microsoft",
                unknown: "fgfgfgffgfgfgfgf",
                time: "0 seconds ago",
                message: "Paycheck withdrawn for support",
            },
            {
                trans_id: "65a4s31ds83ad41a3ssa2d31",
                account: "Personal", //savings
                amount: 2700,
                trans_type: "transfer",
                receiver: "Taiga",
                unknown: "fgfgfgffgfgfgfgf",
                time: "2 months ago",
                message: "Payment sent to help for business",
            },
        ],
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
                time: "1 minute ago",
                message: "Paycheck withdrawn for support",
            },
        ],
    },
]);
