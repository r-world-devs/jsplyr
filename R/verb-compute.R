#' @title Compute `JSON` data in the browser.
#' @name compute
#' @param x A `tbl_lazy_json` object.
#' @param ... Unused. Provided for consistency with generic.
#' @importFrom dplyr compute
#' @importFrom promises promise
#' @export
compute.tbl_lazy_json <- function(x, ...) {

  session <- x$session
  state_id <- x$state_id

  # Each compute() needs its own HTTP endpoint. Two collect() calls on the same
  # lazy query share a state_id, so keying the endpoint on state_id alone would
  # make the second registration clobber the first in session$downloads, and the
  # first promise would never resolve. A fresh id per call keeps them distinct.
  endpoint_id <- generate_id()

  # Create a promise that resolves when JS posts the result back.
  p <- promises::promise(function(resolve, reject) {
    # Register a one-shot HTTP endpoint scoped to this session.
    url <- session$registerDataObj(
      name = paste0("jsplyr_", endpoint_id),
      data = list(resolve = resolve),
      filterFunc = function(data, req) {
        body <- rawToChar(req$rook.input$read())
        data$resolve(body)
        shiny::httpResponse(200L, "application/json", "{\"ok\":true}")
      }
    )

    # Send compute steps + callback URL to JS.
    session$sendCustomMessage("computeLazyJSON", list(
      compute_steps = x$compute_steps,
      state_id = state_id,
      callback_url = url
    ))
  })

  x$compute_steps <- list(
    compute_step(verb = "take", name = state_id)
  )
  x$.promise <- p
  x
}
