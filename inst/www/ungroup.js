// Remove grouping set by group_by(). With no columns, clear all grouping.
// With columns, remove only those from the grouping set (partial ungroup).
// Accepts an array or a single string, consistent with groupByJSON.
function ungroupJSON(columns) {
  if (columns === undefined || columns === null) {
    groupByColumns = [];
    return;
  }
  let cols = Array.isArray(columns) ? columns : [columns];
  if (cols.length === 0) {
    groupByColumns = [];
    return;
  }
  groupByColumns = groupByColumns.filter(function (c) {
    return cols.indexOf(c) === -1;
  });
}
