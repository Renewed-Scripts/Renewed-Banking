/**
* @param eventName - The endpoint eventname to target
* @param data - Data you wish to send in the NUI Callback
* @return returnData - A promise for the data sent back by the NuiCallbacks CB argument
*/
const identity: string = atob("UmVuZXdlZC1CYW5raW5n")
export async function fetchNui<T = any>(
  eventName: string,
  data: unknown = {}
): Promise<T> {
  const options = {
    method: "post",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(data),
  };

  const resp = await fetch(`https://${identity}/${eventName}`, options);
  return await resp.json();
}
