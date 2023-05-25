<script lang="ts">
    import { accounts, activeAccount, popupDetails, loading, translations } from "../store/stores";
    import {fetchNui} from "../utils/fetchNui"
    let amount: number = 0;
    let comment: string = "";
    let stateid: string = "";
    $: account = $accounts.find((accountItem: any) => $activeAccount === accountItem.id);

    function closePopup() {
        popupDetails.update((val: any) => ({
            ...val,
            actionType: ""
        }));
    }

    function submitInput() {
        loading.set(true);
        fetchNui($popupDetails.actionType, {fromAccount: $popupDetails.account.id, amount: amount, comment: comment, stateid: stateid}).then(retData => {
            setTimeout(() => {
                if (retData !== false){
                    accounts.set(retData);
                }
                loading.set(false);
            }, 1000);
        })
        closePopup();
    }
</script>

<section class="popup-container">
    <section class="popup-content">
        <h2> {$popupDetails.account.type}{$translations.account}/ {$popupDetails.account.id}</h2>
        <form action="#">
            <div class="form-row">
                <label for="amount">{$translations.amount}</label>
                <input bind:value={amount} type="number" name="amount" id="amount" placeholder="$" />
            </div>

            <div class="form-row">
                <label for="comment">{$translations.comment}</label>
                <input bind:value={comment} type="text" name="comment" id="comment" placeholder="//" />
            </div>

            {#if $popupDetails.actionType === "transfer"}
                <div class="form-row">
                    <label for="stateId">{$translations.transfer}</label>
                    <input bind:value={stateid} type="text" name="stateId" id="stateId" placeholder="#" />
                </div>
            {/if}

            <div class="btns-group">
                <button type="button" class="btn btn-orange" on:click={closePopup}>{$translations.cancel}</button>
                <button type="button" class="btn btn-green" on:click={() => submitInput()}>{$translations.confirm}</button>
            </div>
        </form>
    </section>
</section>

<style>
    .popup-container {
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        right: 0;
        background-color: rgba(255, 255, 255, 0.3);

        display: flex;
        align-items: center;
        justify-content: center;
    }

    .popup-content {
        max-width: 60rem;
        width: 100%;
        background-color: var(--clr-primary);
        padding: 5rem;
        border-radius: 1rem;
    }

    h2 {
        margin-bottom: 3rem;
        text-align: center;
        font-size: 2rem;
    }

    .form-row {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
        color: #F3F4F5;
        margin-bottom: 2rem;
    }
    .form-row label,
    .form-row input {
        font-size: 1.4rem;
        color: inherit;
    }

    .form-row input {
        width: 100%;
        border-radius: 5px;
        background-color: transparent;
        border: none;
        padding: 1.4rem;
        margin-bottom: 1rem;
        background-color: #2a2b33;
        color: #fff; 
    }
</style>
