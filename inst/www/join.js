// Join two JSON frames. `by` is { x: [...], y: [...] } describing the key
// columns on each side. `type` is one of:
//   left, right, inner, full  (mutating joins)
//   semi, anti                (filtering joins)
function joinJSON(left, right, by, type) {
  left = left || [];
  right = right || [];

  let keys = resolveByKeys(left, right, by);
  let byX = keys.x;
  let byY = keys.y;

  switch (type) {
    case "right":
      // A right join is a left join with the tables swapped. Swap the key
      // sides too, then reorder columns so left columns come first.
      return mutatingJoin(right, left, byY, byX, "left", true);
    case "inner":
      return mutatingJoin(left, right, byX, byY, "inner", false);
    case "full":
      return fullJoin(left, right, byX, byY);
    case "semi":
      return filteringJoin(left, right, byX, byY, true);
    case "anti":
      return filteringJoin(left, right, byX, byY, false);
    case "left":
    default:
      return mutatingJoin(left, right, byX, byY, "left", false);
  }
}

// Determine join keys. When `by` is empty (natural join), use columns common
// to both frames. Otherwise normalise scalar/array inputs to arrays.
function resolveByKeys(left, right, by) {
  let byX = toArray(by ? by.x : null);
  let byY = toArray(by ? by.y : null);

  if (byX.length === 0) {
    let leftCols = left.length > 0 ? Object.keys(left[0]) : [];
    let rightCols = right.length > 0 ? Object.keys(right[0]) : [];
    let common = leftCols.filter(function (c) { return rightCols.indexOf(c) !== -1; });
    byX = common;
    byY = common;
  }

  return { x: byX, y: byY };
}

function toArray(value) {
  if (value === null || value === undefined) {
    return [];
  }
  return Array.isArray(value) ? value : [value];
}

// Build a string key for a row from the given key columns.
function makeKey(row, cols) {
  return JSON.stringify(cols.map(function (c) { return row[c]; }));
}

// Index the right frame by its key columns: key -> array of matching rows.
function indexBy(rows, cols) {
  let index = new Map();
  rows.forEach(function (row) {
    let key = makeKey(row, cols);
    if (!index.has(key)) {
      index.set(key, []);
    }
    index.get(key).push(row);
  });
  return index;
}

// Merge a left and right row into a single output row. Key columns keep the
// left value; non-key columns shared by both sides get .x / .y suffixes.
// When `swapped` is true the inputs originate from a swapped (right join)
// call, so suffixes are reported from the caller's perspective.
function mergeRows(leftRow, rightRow, byY, sharedCols, swapped) {
  let out = {};
  let suffixLeft = swapped ? ".y" : ".x";
  let suffixRight = swapped ? ".x" : ".y";

  Object.keys(leftRow).forEach(function (col) {
    if (sharedCols.indexOf(col) !== -1) {
      out[col + suffixLeft] = leftRow[col];
    } else {
      out[col] = leftRow[col];
    }
  });

  if (rightRow !== null) {
    Object.keys(rightRow).forEach(function (col) {
      if (byY.indexOf(col) !== -1) {
        return; // key columns already carried from the left row
      }
      if (sharedCols.indexOf(col) !== -1) {
        out[col + suffixRight] = rightRow[col];
      } else {
        out[col] = rightRow[col];
      }
    });
  }

  return out;
}

// Non-key columns present in both frames (these collide and need suffixes).
function sharedColumns(left, right, byY) {
  let leftCols = left.length > 0 ? Object.keys(left[0]) : [];
  let rightCols = right.length > 0 ? Object.keys(right[0]) : [];
  return leftCols.filter(function (c) {
    return rightCols.indexOf(c) !== -1 && byY.indexOf(c) === -1;
  });
}

function mutatingJoin(left, right, byX, byY, mode, swapped) {
  let index = indexBy(right, byY);
  let shared = sharedColumns(left, right, byY);
  let rightCols = right.length > 0 ? Object.keys(right[0]) : [];
  let result = [];

  left.forEach(function (leftRow) {
    let key = makeKey(leftRow, byX);
    let matches = index.get(key);

    if (matches && matches.length > 0) {
      matches.forEach(function (rightRow) {
        result.push(mergeRows(leftRow, rightRow, byY, shared, swapped));
      });
    } else if (mode === "left") {
      let merged = mergeRows(leftRow, null, byY, shared, swapped);
      rightCols.forEach(function (col) {
        if (byY.indexOf(col) !== -1) {
          return;
        }
        let outCol = shared.indexOf(col) !== -1 ? col + (swapped ? ".x" : ".y") : col;
        merged[outCol] = null;
      });
      result.push(merged);
    }
  });

  return result;
}

function fullJoin(left, right, byX, byY) {
  let result = mutatingJoin(left, right, byX, byY, "left", false);
  let shared = sharedColumns(left, right, byY);
  let leftCols = left.length > 0 ? Object.keys(left[0]) : [];
  let leftIndex = indexBy(left, byX);

  right.forEach(function (rightRow) {
    let key = makeKey(rightRow, byY);
    if (leftIndex.has(key)) {
      return; // already emitted by the left join above
    }
    // Right-only row: carry keys, fill left-only columns with null.
    let out = {};
    leftCols.forEach(function (col) {
      let outCol = shared.indexOf(col) !== -1 ? col + ".x" : col;
      out[outCol] = null;
    });
    byX.forEach(function (col, i) {
      out[col] = rightRow[byY[i]];
    });
    Object.keys(rightRow).forEach(function (col) {
      if (byY.indexOf(col) !== -1) {
        return;
      }
      let outCol = shared.indexOf(col) !== -1 ? col + ".y" : col;
      out[outCol] = rightRow[col];
    });
    result.push(out);
  });

  return result;
}

function filteringJoin(left, right, byX, byY, keepMatching) {
  let index = indexBy(right, byY);
  return left.filter(function (leftRow) {
    let key = makeKey(leftRow, byX);
    let hasMatch = index.has(key);
    return keepMatching ? hasMatch : !hasMatch;
  });
}
