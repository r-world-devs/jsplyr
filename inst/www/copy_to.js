const jsonData = {};

function copyJSONToBrowser(params) {
  let jsonReceivedData = params.jsonData;
  let dataId = params.state_id;
  jsonData[dataId] = jsonReceivedData;
}
Shiny.addCustomMessageHandler("copyJSONToBrowser", copyJSONToBrowser);

// This function is needed only when JSON is already
// loaded in the browser and there is no need to
// copy it from R.
function copyJSONInBrowser(params) {
  let jsonName = params.jsonName;
  let dataId = params.state_id;
  jsonData[dataId] = eval(jsonName);
}
Shiny.addCustomMessageHandler("copyJSONInBrowser", copyJSONInBrowser);
