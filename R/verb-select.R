#' @name select
#' @title Select columns from `JSON` data.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Column names.
#' @return A `tbl_lazy_json` object with the column selection appended as a lazy
#'   compute step, applied in the browser when the pipeline is evaluated.
#' @importFrom dplyr select
#' @export
select.tbl_lazy_json <- function(.data, ...) {
  compute_step <- dots_to_select_query(...)
  .data$compute_steps <- add_select(.data, compute_step)
  .data$state_id <- generate_id()  
  .data
}

add_select <- function(.data, columns) {
  select_step <- compute_step(
    verb = "select",
    expression = columns
  )
  append(.data$compute_steps, list(select_step))
}
