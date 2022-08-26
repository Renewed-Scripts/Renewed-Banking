<script>
    import { accounts, activeAccount, popupDetails, loading } from "../store/stores";
    import {fetchNui} from "../utils/fetchNui"
    let amount = 0;
    let comment = "";
    let stateid = "";
    $: account = $accounts.find((accountItem) => $activeAccount === accountItem.id);

    function closePopup() {
        popupDetails.update((val) => ({
            ...val,
            actionType: "",
        }));
    }

    function submitInput() {
        loading.set(true)
        fetchNui($popupDetails.actionType, {fromAccount: $popupDetails.account.id, amount: amount, comment: comment, stateid: stateid}).then(retData => {
            setTimeout(() => {
                accounts.set(retData)
                loading.set(false)
            }, 3500);
        })
        closePopup()
    }
</script>

<section class="popup-container">
    <section class="popup-content">
        <h2> {$popupDetails.account.type} Account / {$popupDetails.account.id}</h2>
        <form action="#">
            <div class="form-row">
                <label for="amount">Amount</label>
                <input bind:value={amount} type="number" name="amount" id="amount" placeholder="$" />
            </div>

            <div class="form-row">
                <label for="comment">Comment</label>
                <input bind:value={comment} type="text" name="comment" id="comment" placeholder="//" />
            </div>

            {#if $popupDetails.actionType === "transfer"}
                <div class="form-row">
                    <label for="stateId">Business or Citizen ID</label>
                    <input bind:value={stateid} type="text" name="stateId" id="stateId" placeholder="#" />
                </div>
            {/if}

            <div class="btns-group">
                <button class="btn btn-orange" on:click={closePopup}>Cancel</button>
                <button class="btn btn-green" on:click={() => submitInput()}>{$popupDetails.actionType}</button>
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
        max-width: 50rem;
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
        color: var(--clr-grey);
        margin-bottom: 2rem;
    }
    .form-row label,
    .form-row input {
        font-size: 1.4rem;
        color: inherit;
    }

    .form-row input {
        padding: 0.8rem 0;
        background-color: transparent;
        border: none;
        border-bottom: 1px solid;
    }
</style>
