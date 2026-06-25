function selectJSON(dataset, columns) {
  const jsonFrame = dataset.map(item => {
    let selectedItem = {};
    if (Array.isArray(columns)) {
      columns.forEach(column => {
        selectedItem[column] = item[column];
      });
    } else {
      let column = columns;
      selectedItem[column] = item[column];
    }    
    return selectedItem;
  });
  return jsonFrame;
}