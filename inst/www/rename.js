// Rename keys on each row. `pairs` is an array of { new: ..., old: ... }.
// Column (key) order is preserved by rebuilding each row in its original order
// and swapping in the new name when a key is being renamed.
function renameJSON(dataset, pairs) {
  let renameMap = {};
  pairs.forEach(function (pair) {
    renameMap[pair.old] = pair.new;
  });

  return dataset.map(function (row) {
    let out = {};
    Object.keys(row).forEach(function (key) {
      let outKey = Object.prototype.hasOwnProperty.call(renameMap, key)
        ? renameMap[key]
        : key;
      out[outKey] = row[key];
    });
    return out;
  });
}
