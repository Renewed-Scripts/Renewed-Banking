<script lang="ts">
  import { fetchNui } from '../utils/fetchNui';
  import { onMount } from 'svelte';
  import { visibility, accounts, activeAccount, loading } from '../store/stores';
  import { useNuiEvent } from '../utils/useNuiEvent';
  let isVisible: boolean;

  visibility.subscribe(visible => {
    isVisible = visible;
  });

  useNuiEvent<any>('setVisible', data => {
    accounts.set(data.accounts);
    activeAccount.update(() => data.accounts[0].id)
    visibility.set(data.status);
    loading.set(data.loading)
  })

  useNuiEvent<any>('setLoading', data => {
    loading.set(data.status);
  })

  onMount(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (isVisible && ['Escape'].includes(e.code)) {
        fetchNui('closeInterface');
        visibility.set(false);
      }
    };

    window.addEventListener('keydown', keyHandler);
    return () => window.removeEventListener('keydown', keyHandler);
  });
</script>

{#if isVisible}
  <slot />
{/if}
