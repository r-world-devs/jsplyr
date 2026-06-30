// Keep distinct rows. `columns` names the columns that determine uniqueness;
// when empty, all columns are used. By default, when columns are supplied, the
// output is projected to just those columns (like dplyr). Set `keepAll` to true
// to keep all columns, returning the first row of each distinct group.
distinctJSON = function(jsonFrame, columns, keepAll) {
  const uniqueItems = new Set();
  const hasColumns = Array.isArray(columns) ? columns.length > 0 : !!columns;
  const cols = Array.isArray(columns) ? columns : (columns ? [columns] : []);

  const distinctItems = [];
  jsonFrame.forEach(item => {
    let key;
    if (hasColumns) {
      const subset = {};
      cols.forEach(col => { subset[col] = item[col]; });
      key = JSON.stringify(subset);
    } else {
      key = JSON.stringify(item);
    }
    if (uniqueItems.has(key)) {
      return;
    }
    uniqueItems.add(key);
    // Project to the selected columns unless keepAll is set or no columns were
    // given (in which case the whole row is already the unit of distinctness).
    if (hasColumns && !keepAll) {
      const projected = {};
      cols.forEach(col => { projected[col] = item[col]; });
      distinctItems.push(projected);
    } else {
      distinctItems.push(item);
    }
  });

  return distinctItems;
}
