import { writable } from "svelte/store";

export const visibility = writable(false);
export const loading = writable(false);
export const notify = writable("");
export let activeAccount = writable(null);

export let popupDetails = writable({
    account: {},
    actionType: "",
});

export const accounts = writable<any>([]);
