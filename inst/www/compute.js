function runComputeSteps(computeSteps) {
  let jsonFrame;
  computeSteps.forEach((item) => {
    if (item.verb == "distinct") {
      jsonFrame = distinctJSON(jsonFrame, item.params.expression);
    }
    if (item.verb == "take") {
      jsonFrame = jsonData[item.params.name];
    }
    if (item.verb === "filter") {
      jsonFrame = filterJSON(jsonFrame, item.params.expression);
    }
    if (item.verb === "select") {
      jsonFrame = selectJSON(jsonFrame, item.params.expression);
    }
    if (item.verb === "group_by") {
      groupByJSON(item.params.expression);
    }
    if (item.verb === "summarise") {
      jsonFrame = summariseJSON(jsonFrame, item.params.expressions);
    }
    if (item.verb === "mutate") {
      jsonFrame = mutateJSON(jsonFrame, item.params.expressions);
    }
    if (item.verb === "join") {
      let rightFrame = runComputeSteps(item.params.y_steps);
      jsonFrame = joinJSON(jsonFrame, rightFrame, item.params.by, item.params.type);
    }
  });
  return jsonFrame;
}

function computeLazyJSON(params) {
  let jsonFrame = runComputeSteps(params.compute_steps);
  outputDataId = params.state_id;
  jsonData[outputDataId] = jsonFrame;
  let resultJSON = JSON.stringify(jsonData[outputDataId]);

  fetch(params.callback_url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: resultJSON
  });
}
Shiny.addCustomMessageHandler("computeLazyJSON", computeLazyJSON);