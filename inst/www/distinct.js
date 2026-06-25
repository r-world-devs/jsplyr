distinctJSON = function(jsonFrame, columns) {
  const uniqueItems = new Set();
  const hasColumns = Array.isArray(columns) ? columns.length > 0 : !!columns;

  const distinctItems = jsonFrame.filter(item => {
    let key;
    if (hasColumns) {
      const cols = Array.isArray(columns) ? columns : [columns];
      const subset = {};
      cols.forEach(col => { subset[col] = item[col]; });
      key = JSON.stringify(subset);
    } else {
      key = JSON.stringify(item);
    }
    if (uniqueItems.has(key)) {
      return false;
    } else {
      uniqueItems.add(key);
      return true;
    }
  });

  return distinctItems;
}
