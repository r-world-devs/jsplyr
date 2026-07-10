#' @title Retrieve `JSON` data from the browser.
#' @name collect
#' @description Because `jsplyr` keeps your data in the browser, `collect()`
#'   fetches it back over an asynchronous round-trip and therefore returns a
#'   [promises::promise()], not a data frame.
#'
#'   Reactive *outputs* such as `shiny::renderTable()` or `DT::renderDT()`
#'   understand promises and resolve them for you, so a plain `collect()` inside
#'   a render function works as-is. Every other reactive wrapper —
#'   `shiny::reactive()`, `shiny::eventReactive()`, `shiny::observeEvent()` and
#'   `shiny::observe()` — hands you the promise as-is, so you cannot treat the
#'   result as a data frame on the next line. Unwrap it first — with
#'   [promises::then()] or the re-exported [`%...>%`][promise-pipes] pipe —
#'   before using the value.
#'
#'   See `vignette("collect-with-promises")` for a fuller discussion, including
#'   how to update inputs and other side effects from a computed value.
#' @param x  A `tbl_lazy_json` object.
#' @param raw A logical, if `TRUE` returns `JSON` as character.
#' @param ... Unused. Provided for consistency with generic.
#' @return A [promises::promise()]. When `raw = FALSE` (the default) it resolves
#'   to a [tibble::tibble] built from the computed `JSON`; when `raw = TRUE` it
#'   resolves to the raw `JSON` string. The result is fetched asynchronously
#'   from the browser, so the value is a promise rather than a data frame.
#' @examples
#' if (interactive()) {
#'   # promises::then() reads like a normal function call.
#'   shiny::observeEvent(input$compute, {
#'     tbl(session, "mtcars") |>
#'       dplyr::filter(mpg >= input$min_mpg) |>
#'       dplyr::collect() |>
#'       promises::then(function(df) print(df))
#'   })
#'
#'   # Terser alternative: the %...>% pipe passes the resolved value on.
#'   shiny::observeEvent(input$compute, {
#'     tbl(session, "mtcars") |>
#'       dplyr::filter(mpg >= input$min_mpg) |>
#'       dplyr::collect() %...>%
#'       print()
#'   })
#' }
#' @seealso `vignette("collect-with-promises")` for handling `collect()`
#'   promises in reactive contexts.
#' @importFrom dplyr collect
#' @importFrom promises then
#' @export
collect.tbl_lazy_json <- function(x, ..., raw = FALSE) {

  if (is.null(x$.promise)) {
    x <- dplyr::compute(x)
  }

  promises::then(x$.promise, onFulfilled = function(json_str) {
    if (raw) {
      return(json_str)
    }
    jsonlite::fromJSON(json_str) |>
      dplyr::as_tibble()
  })
}
