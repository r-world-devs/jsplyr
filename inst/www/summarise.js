function summariseJSON(dataset, expressions) {
  let groups;

  if (groupByColumns.length > 0) {
    groups = groupData(dataset, groupByColumns);
  } else {
    // No grouping: treat entire dataset as one group
    groups = [{ key: {}, rows: dataset }];
  }

  const result = groups.map(function(group) {
    let row = Object.assign({}, group.key);
    expressions.forEach(function(expr) {
      row[expr.name] = applyAggregation(group.rows, expr.fn, expr.column);
    });
    return row;
  });

  // Reset grouping after summarise (matches dplyr behavior)
  groupByColumns = [];

  return result;
}

function groupData(dataset, columns) {
  const groupMap = new Map();

  dataset.forEach(function(item) {
    const keyObj = {};
    columns.forEach(function(col) {
      keyObj[col] = item[col];
    });
    const keyStr = JSON.stringify(keyObj);

    if (!groupMap.has(keyStr)) {
      groupMap.set(keyStr, { key: keyObj, rows: [] });
    }
    groupMap.get(keyStr).rows.push(item);
  });

  return Array.from(groupMap.values());
}

function applyAggregation(rows, fn, column) {
  const values = column ? rows.map(function(r) { return r[column]; }) : [];

  switch (fn) {
    case "mean":
      return values.reduce(function(a, b) { return a + b; }, 0) / values.length;
    case "sum":
      return values.reduce(function(a, b) { return a + b; }, 0);
    case "min":
      return Math.min.apply(null, values);
    case "max":
      return Math.max.apply(null, values);
    case "n":
      return rows.length;
    case "sd":
      var mean = values.reduce(function(a, b) { return a + b; }, 0) / values.length;
      var variance = values.reduce(function(a, b) { return a + Math.pow(b - mean, 2); }, 0) / (values.length - 1);
      return Math.sqrt(variance);
    case "median":
      var sorted = values.slice().sort(function(a, b) { return a - b; });
      var mid = Math.floor(sorted.length / 2);
      return sorted.length % 2 !== 0 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
    default:
      console.warn("Unknown aggregation function: " + fn);
      return null;
  }
}
