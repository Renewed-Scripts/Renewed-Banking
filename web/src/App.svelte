<script lang="ts">
    import VisibilityProvider from "./providers/VisibilityProvider.svelte";
    import { debugData } from "./utils/debugData";
    import AccountsContainer from "./components/AccountsContainer.svelte";

    debugData([
        {
            action: "setVisible",
            data: true,
        },
    ]);
</script>

<VisibilityProvider>
    <AccountsContainer />
</VisibilityProvider>
