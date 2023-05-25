// yoinked from https://github.com/overextended/ox_lib/blob/master/web/src/utils/setClipboard.ts
export const setClipboard = (value: string) => {
    const clipElem = document.createElement('input');
    clipElem.value = value;
    document.body.appendChild(clipElem);
    clipElem.select();
    document.execCommand('copy');
    document.body.removeChild(clipElem);
};