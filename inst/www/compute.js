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
    if (item.verb === "ungroup") {
      ungroupJSON(item.params.columns);
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
    if (item.verb === "arrange") {
      jsonFrame = arrangeJSON(jsonFrame, item.params.keys);
    }
    if (item.verb === "rename") {
      jsonFrame = renameJSON(jsonFrame, item.params.pairs);
    }
    if (item.verb === "slice") {
      jsonFrame = sliceJSON(jsonFrame, item.params.type, item.params.opts);
    }
    if (item.verb === "relocate") {
      jsonFrame = relocateJSON(
        jsonFrame,
        item.params.columns,
        item.params.before,
        item.params.after
      );
    }
    if (item.verb === "pull") {
      jsonFrame = pullJSON(jsonFrame, item.params.by, item.params.value);
    }
  });
  return jsonFrame;
}

function computeLazyJSON(params) {
  // Scope grouping state to this top-level compute so it cannot leak from a
  // previous pipeline. The reset lives here, not in runComputeSteps, so the
  // recursive call for a join's right-hand side does not clobber the outer
  // pipeline's grouping.
  groupByColumns = [];
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