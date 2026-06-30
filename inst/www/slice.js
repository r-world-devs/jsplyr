// Select rows by position. `type` selects the slice variant; `opts` carries
// its parameters (positions, n/prop, ordering column). When a group_by() is in
// effect, slicing is applied within each group and the groups are concatenated.
function sliceJSON(dataset, type, opts) {
  if (groupByColumns.length > 0) {
    let groups = groupData(dataset, groupByColumns);
    let out = [];
    groups.forEach(function (group) {
      out = out.concat(sliceRows(group.rows, type, opts));
    });
    return out;
  }
  return sliceRows(dataset, type, opts);
}

// Apply a slice variant to a flat array of rows.
function sliceRows(rows, type, opts) {
  switch (type) {
    case "slice":
      return sliceByPosition(rows, opts.positions);
    case "slice_head":
      return rows.slice(0, sliceCount(rows.length, opts));
    case "slice_tail":
      return rows.slice(rows.length - sliceCount(rows.length, opts));
    case "slice_min":
      return sliceExtreme(rows, opts, "asc");
    case "slice_max":
      return sliceExtreme(rows, opts, "desc");
    default:
      console.warn("Unknown slice type: " + type);
      return rows;
  }
}

// Resolve how many rows to keep from n or prop. prop is rounded down, like
// dplyr's default. Always keeps at least the available rows as an upper bound.
function sliceCount(total, opts) {
  if (opts.prop !== undefined && opts.prop !== null) {
    return Math.max(0, Math.floor(total * opts.prop));
  }
  let n = opts.n !== undefined && opts.n !== null ? opts.n : 1;
  return Math.min(Math.max(0, n), total);
}

// slice(): keep rows at the given 1-based positions. Negative positions drop
// the corresponding rows. Positive and negative cannot be mixed (matching
// dplyr), but we tolerate either form independently.
function sliceByPosition(rows, positions) {
  let hasNegative = positions.some(function (p) { return p < 0; });
  if (hasNegative) {
    let drop = {};
    positions.forEach(function (p) { drop[(-p) - 1] = true; });
    return rows.filter(function (row, i) { return !drop[i]; });
  }
  let out = [];
  positions.forEach(function (p) {
    let idx = p - 1;
    if (idx >= 0 && idx < rows.length) {
      out.push(rows[idx]);
    }
  });
  return out;
}

// slice_min()/slice_max(): order by a column and keep the first n/prop rows.
function sliceExtreme(rows, opts, direction) {
  let column = opts.column;
  let keys = [{ column: column, direction: direction }];
  let ordered = arrangeJSON(rows, keys);
  return ordered.slice(0, sliceCount(rows.length, opts));
}
