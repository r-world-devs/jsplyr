#' @name filter
#' @title Add filter to `JSON` data.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Filtering expressions. Comparisons (`==`, `>`, `<`, etc.) combined
#'   with `&`/`|` are supported, as well as the `dplyr` helpers `is.na()`,
#'   `between()`, and `across()`/`if_all()`/`if_any()`. `across()`/`if_all()` and
#'   `if_any()` expand the predicate over the selected columns, combining them
#'   with `&` and `|` respectively. Column selections accept `c(...)`, a bare
#'   column, a character vector, and `all_of()`/`any_of()`. Values referenced
#'   from `input` or the calling environment are resolved on the R side; column
#'   references are evaluated in the browser.
#' @importFrom dplyr filter
#' @export
filter.tbl_lazy_json <- function(.data, ...) {  
  compute_step <- dots_to_filter_query(.data, ..., .env = rlang::caller_env())
  .data$compute_steps <- add_filter(.data, compute_step)
  .data$state_id <- generate_id()
  .data
}

add_filter <- function(.data, filter_expression) {
  filter_step <- compute_step(
    verb = "filter",
    expression = filter_expression
  )  
  append(.data$compute_steps, list(filter_step))
}
