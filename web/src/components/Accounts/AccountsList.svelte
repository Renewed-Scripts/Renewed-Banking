<script lang="ts">
    import { accounts } from "../../store/stores";
    import AccountListItem from "./AccountListItem.svelte";
</script>

<aside>
    <h3 class="heading">Accounts</h3>

    <section class="scroller">
        {#each $accounts as account (account.id)}
            <AccountListItem {account} />
        {/each}
    </section>
</aside>

<style>
    aside {
        flex: 0 0 25%;
    }
</style>
