// Reorder columns. `columns` are the keys to move. `before`/`after` name the
// anchor column for placement; when both are null the moved columns go to the
// front. Columns not moved keep their relative order.
function relocateJSON(dataset, columns, before, after) {
  if (!dataset || dataset.length === 0) {
    return dataset;
  }

  let allCols = Object.keys(dataset[0]);
  let moving = columns.filter(function (c) { return allCols.indexOf(c) !== -1; });
  let remaining = allCols.filter(function (c) { return moving.indexOf(c) === -1; });

  let order;
  if (before !== null && before !== undefined) {
    order = insertAt(remaining, moving, before, "before");
  } else if (after !== null && after !== undefined) {
    order = insertAt(remaining, moving, after, "after");
  } else {
    // Default: move selected columns to the front.
    order = moving.concat(remaining);
  }

  return dataset.map(function (row) {
    let out = {};
    order.forEach(function (col) {
      out[col] = row[col];
    });
    return out;
  });
}

// Insert `moving` columns into `remaining` relative to `anchor`. `where` is
// "before" or "after". If the anchor is absent, fall back to the front.
function insertAt(remaining, moving, anchor, where) {
  let pos = remaining.indexOf(anchor);
  if (pos === -1) {
    return moving.concat(remaining);
  }
  let insertIndex = where === "after" ? pos + 1 : pos;
  return remaining
    .slice(0, insertIndex)
    .concat(moving)
    .concat(remaining.slice(insertIndex));
}
