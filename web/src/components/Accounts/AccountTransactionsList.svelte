<script lang="ts">
    import { accounts, activeAccount, translations, atm, notify} from "../../store/stores";
    import AccountTransactionItem from "./AccountTransactionItem.svelte";
    import { convertToCSV } from "../../utils/convertToCSV";
    import { setClipboard } from "../../utils/setClipboad";
    let transSearch = '';
    $: account = $accounts.find((accountItem: any) => $activeAccount === accountItem.id);

    function handleClickExportData() {
        if (account == null) console.log("No account selected");
        if (account.transactions.length === 0) {
            notify.set("No transactions to export!");
            setTimeout(() => {
                notify.set("");
            }, 3500);
            return;
        }
        const csv = convertToCSV(account.transactions);
        setClipboard(csv);
        notify.set("Data copied to clipboard!");
        setTimeout(() => {
            notify.set("");
        }, 3500);
    }
    let isAtm: boolean = false;
    atm.subscribe((usingAtm: boolean) => {
        isAtm = usingAtm;
    });
</script>

<section class="transactions-container">
    <h3 class="heading">
        <span>{$translations.transactions}</span>

        <div>
            <img src="./img/bank.png" alt="bang icon" />
            <span>{$translations.bank_name}</span>
        </div>
    </h3>

    <input type="text" class="transactions-search" placeholder={$translations.trans_search} bind:value={transSearch}>
    <section class="scroller">
        {#if account}
            {#if account.transactions.filter(item => item.message.toLowerCase().includes(transSearch.toLowerCase()) || item.trans_id.toLowerCase().includes(transSearch.toLowerCase()) || item.receiver.toLowerCase().includes(transSearch.toLowerCase())).length > 0}
                {#each account.transactions.filter(item => item.message.toLowerCase().includes(transSearch.toLowerCase()) || item.trans_id.toLowerCase().includes(transSearch.toLowerCase()) || item.receiver.toLowerCase().includes(transSearch.toLowerCase())) as transaction (transaction.trans_id)}
                    <AccountTransactionItem {transaction}/>
                {/each}
            {:else}
                <h3 style="text-align: left; color: #F3F4F5; margin-top: 1rem;">{$translations.trans_not_found}</h3>
            {/if}
        {:else}
            {$translations.select_account}
        {/if}
    </section>
    {#if !isAtm}
        <div class="export-data">
            <button class="btn btn-green" style="display: flex; align-items: center; justify-content: center; gap: 1rem" on:click|preventDefault={handleClickExportData}><i class="fa-solid fa-file-export fa-fw" />
                {$translations.export_data}
            </button>
        </div>
    {/if}
</section>

<style>
    .transactions-container {
        flex: 1 1 75%;
        transform: translateY(-0.6rem);
        padding: 0.5rem;
    }

    .heading {
        display: flex;
        justify-content: space-between;
    }

    .heading div {
        display: flex;
        align-items: center;
    }

    .heading img {
        width: 3rem;
        margin-right: 1rem;
    }

    .transactions-search {
        width: 100%;
        border-radius: 5px;
        border: none;
        padding: 1.4rem;
        margin-bottom: 1rem;
        background-color: var(--clr-primary-light);
        color: #fff;
    }

    .scroller {
        height: 85%;
    }

    .export-data {
        margin-top: 1rem;
        display: flex;
        justify-content: flex-end;
    }
    /* ------------------------- */
</style>
