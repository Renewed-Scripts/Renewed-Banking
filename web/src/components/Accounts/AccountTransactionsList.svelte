<script lang="ts">
    import { accounts, activeAccount, translations } from "../../store/stores";
    import AccountTransactionItem from "./AccountTransactionItem.svelte";

    $: account = $accounts.find((accountItem: any) => $activeAccount === accountItem.id);
</script>

<section class="transactions-container">
    <h3 class="heading">
        <span>{$translations.transactions}</span>

        <div>
            <img src="./img/bank.png" alt="bang icon" />
            <span>{$translations.bank_name}</span>
        </div>
    </h3>

    <section class="scroller">
        {#if account}
            {#each account.transactions as transaction (transaction.trans_id)}
                <AccountTransactionItem {transaction}/>
            {/each}
        {:else}
            {$translations.select_account}
        {/if}
    </section>
</section>

<style>
    .transactions-container {
        flex: 1 1 75%;
        transform: translateY(-0.6rem);
    }

    h3 {
        display: flex;
        justify-content: space-between;
    }

    h3 div {
        display: flex;
        align-items: center;
    }
    h3 img {
        width: 3rem;
        margin-right: 1rem;
    }

    /* ------------------------- */
</style>
