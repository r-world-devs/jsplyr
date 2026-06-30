// Reduce a JSON frame to a single column, keyed by name or position. The R
// side extracts the lone column from the returned frame as a vector.
// `by` is "name" or "index"; for "index" a 1-based position is used, with
// negative values counting from the right (-1 is the last column).
function pullJSON(dataset, by, value) {
  if (!dataset || dataset.length === 0) {
    return [];
  }

  let columns = Object.keys(dataset[0]);
  let column;

  if (by === "index") {
    let idx = value > 0 ? value - 1 : columns.length + value;
    column = columns[idx];
  } else {
    column = value;
  }

  return dataset.map(function (row) {
    let picked = {};
    picked[column] = row[column];
    return picked;
  });
}
