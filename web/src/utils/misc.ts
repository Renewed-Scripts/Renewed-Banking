import { currency } from "../store/stores";

export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

let activeCurrency: string;

currency.subscribe((value: string) => {
    activeCurrency = value;
});

export function formatMoney(number: number) {
    return number.toLocaleString('en-US', { style: 'currency', currency: activeCurrency });
}