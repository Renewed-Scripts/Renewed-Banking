export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export function formatMoney(number: number) {
    return number.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
}