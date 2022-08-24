<script lang="ts">
    import VisibilityProvider from "./providers/VisibilityProvider.svelte";
    import { debugData } from "./utils/debugData";
    import AccountsContainer from "./components/AccountsContainer.svelte";
    import Popup from "./components/Popup/Popup.svelte";
    import { popupDetails } from "./store/stores";

    debugData([
        {
            action: "setVisible",
            data: true,
        },
    ]);
</script>

<VisibilityProvider>
    <AccountsContainer />
    {#if $popupDetails.actionType !== ""}
        <Popup />
    {/if}
</VisibilityProvider>
