// Sort a JSON frame by one or more keys. `keys` is an array of
// { column, direction } entries; direction is "asc" or "desc". The sort is
// stable across ties, so equal-key rows keep their original relative order.
function arrangeJSON(dataset, keys) {
  let indexed = dataset.map(function (row, i) {
    return { row: row, i: i };
  });

  indexed.sort(function (a, b) {
    for (let k = 0; k < keys.length; k++) {
      let column = keys[k].column;
      let descending = keys[k].direction === "desc";
      let cmp = compareValues(a.row[column], b.row[column]);
      if (cmp !== 0) {
        return descending ? -cmp : cmp;
      }
    }
    // All keys equal: preserve original order for stability.
    return a.i - b.i;
  });

  return indexed.map(function (entry) { return entry.row; });
}

// Compare two values. null/undefined sort last (like dplyr's NA handling).
// Numbers compare numerically; everything else compares as strings.
function compareValues(x, y) {
  let xMissing = x === null || x === undefined;
  let yMissing = y === null || y === undefined;
  if (xMissing && yMissing) {
    return 0;
  }
  if (xMissing) {
    return 1;
  }
  if (yMissing) {
    return -1;
  }
  if (typeof x === "number" && typeof y === "number") {
    return x - y;
  }
  let xs = String(x);
  let ys = String(y);
  if (xs < ys) {
    return -1;
  }
  if (xs > ys) {
    return 1;
  }
  return 0;
}
