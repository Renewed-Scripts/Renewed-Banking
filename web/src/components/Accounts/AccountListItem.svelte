<script lang="ts">
    import { accounts, activeAccount, popupDetails, atm, translations } from "../../store/stores";
    import { formatMoney } from "../../utils/misc";
    export let account:any;

    function handleAccountClick(id: any) {
        activeAccount.update(() => id);
    };

    let isAtm: boolean;
    function handleButton(id:string, type:string) {
        let account = $accounts.find((accountItem: any) => id === accountItem.id);
        popupDetails.update(() => ({ actionType: type, account }));
    }

    atm.subscribe((usingAtm: boolean) => {
        isAtm = usingAtm;
    });
</script>

<section class="account" on:click={()=>handleAccountClick(account.id)}>
    <h4>
        {account.type}{$translations.account}/ {account.id}
    </h4>
    <h5>
        {account.type}{$translations.account}<br />
        <span>{account.name}</span>
    </h5>

    <div class="price">
        <strong>{formatMoney(account.amount)}</strong> <br />
        <span>{$translations.balance}</span>
    </div>

    <div class="btns-group">
        {#if !account.isFrozen}
            {#if !isAtm}
                <button class="btn btn-green" on:click={() => handleButton(account.id, "deposit")}>{$translations.deposit_but}</button>
            {/if}
            <button class="btn btn-orange" on:click={() => handleButton(account.id, "withdraw")}>{$translations.withdraw_but}</button>
            <button class="btn btn-grey" on:click={() => handleButton(account.id, "transfer")}>{$translations.transfer_but}</button>
        {:else}
            {$translations.frozen}
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
