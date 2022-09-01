<script lang="ts">
    import { accounts, activeAccount, popupDetails } from "../../store/stores";
    import { formatMoney } from "../../utils/misc";
    export let account:any;

    function handleAccountClick(id: any) {
        activeAccount.update(() => id);
    };

    function handleButton(id:string, type:string) {
        let account = $accounts.find((accountItem: any) => id === accountItem.id);
        popupDetails.update(() => ({ actionType: type, account }));
    }

</script>

<section class="account" on:click={()=>handleAccountClick(account.id)}>
    <h4>
        {account.type} Account / {account.id}
    </h4>
    <h5>
        {account.type} Account <br />
        <span>{account.name}</span>
    </h5>

    <div class="price">
        <strong>{formatMoney(account.amount)}</strong> <br />
        <span>Available Balance</span>
    </div>

    <div class="btns-group">
        {#if !account.isFrozen}
            <button class="btn btn-green" on:click={() => handleButton(account.id, "deposit")}>Deposit</button>
            <button class="btn btn-orange" on:click={() => handleButton(account.id, "withdraw")}>Withdraw</button>
            <button class="btn btn-grey" on:click={() => handleButton(account.id, "transfer")}>Transfer</button>
        {:else}
            Account Status: Frozen
        {/if}
    </div>
</section>

<style>
    .account {
        background-color: var(--clr-primary);
        padding: 0.6rem;
        border: 3px solid #777;
        border-radius: 3px;
        cursor: pointer;
    }
    .account:not(:last-child) {
        margin-bottom: 1.5rem;
    }

    h4 {
        font-size: 1.5rem;
        margin-bottom: 0.5rem;
    }
    h5 {
        font-size: 1.2rem;
    }
    h5 span {
        margin-top: 0.3rem;
    }

    .price {
        text-align: right;
        margin-bottom: 1rem;
    }
    .price strong {
        font-size: 1.6rem;
    }

    .btns-group {
        display: flex;
        justify-content: space-between;
    }
</style>
