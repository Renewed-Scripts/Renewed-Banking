import { onMount, onDestroy } from "svelte";

export function useNuiEvent<T = unknown>(
  action: string,
  handler: (data: T) => void
) {
  const eventListener = (event: any) => {
    event.data.action === action && handler(event.data);
  };
  onMount(() => window.addEventListener("message", eventListener));
  onDestroy(() => window.removeEventListener("message", eventListener));
}
