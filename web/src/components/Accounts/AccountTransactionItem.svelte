<script lang="ts">
    export let transaction: any;
    export let account: any;
</script>

<section class="transaction">
    <h5>
        <span>
            {account.type} Account / {account.id}
            [{transaction.trans_type.toUpperCase()}]
        </span>
        <span>{transaction.trans_id}</span>
    </h5>
    <h4>
        <span class:withdraw={transaction.trans_type === "withdraw"}>
            {#if transaction.trans_type === "withdraw"}
                -
            {:else}
                &nbsp;
            {/if}
            $100
        </span>
        <span> {transaction.receiver} </span>
        <span>{transaction.time} <br /> {transaction.unknown}</span>
    </h4>

    <h6>
        Message <br />
        {transaction.message}
    </h6>
</section>

<style>
    .transaction {
        background-color: var(--clr-primary-light);
        padding: 1rem;
        border-radius: 2px;
        font-size: 1.5rem;
        font-weight: 300;
        border: 3px solid var(--clr-primary-light);
    }

    .transaction:not(:last-child) {
        margin-bottom: 1.5rem;
    }

    .transaction h5 {
        display: flex;
        justify-content: space-between;
        padding-bottom: 0.5rem;
        margin-bottom: 1rem;
        border-bottom: 3px solid #fff;
    }

    .transaction h4 {
        display: flex;
        justify-content: space-between;
        font-size: 1.2rem;
        margin-bottom: 2rem;
    }
    .transaction h4 span:first-child {
        font-size: 1.4rem;
        color: var(--clr-green);
    }
    .transaction h4 span.withdraw {
        color: var(--clr-orange);
    }
    .transaction h4 span:nth-child(2) {
        margin-right: auto;
        margin-left: 15rem;
    }
    .transaction h6 {
        color: rgb(106, 106, 106);
        padding-bottom: 0.5rem;
        border-bottom: 2px dotted;
        margin: 1rem 0 1.5rem;
    }
    .transaction h6 span {
        margin-top: 0.5rem;
    }
</style>
