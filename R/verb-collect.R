#' @title Retrieve `JSON` data from the browser.
#' @name collect
#' @param x  A `tbl_lazy_json` object.
#' @param raw A logical, if `TRUE` returns `JSON` as character.
#' @param ... Unused. Provided for consistency with generic.
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
