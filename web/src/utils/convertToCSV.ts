export const convertToCSV = (objArray: any[]) => {
    const fields = Object.keys(objArray[0]);
    const replacer = function (key: any, value: any) {
      return value === null ? "" : value;
    };
    let csv: any[] | string = objArray.map(function (row) {
      return fields
        .map(function (fieldName) {
          return JSON.stringify(row[fieldName], replacer);
        })
        .join(",");
    });
    csv.unshift(fields.join(",")); // add header column
  
    csv = csv.join("\r\n");
  
    return csv;
};