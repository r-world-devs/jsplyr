// group_by stores grouping columns for use by summarise
let groupByColumns = [];

function groupByJSON(columns) {
  if (Array.isArray(columns)) {
    groupByColumns = columns;
  } else {
    groupByColumns = [columns];
  }
}
