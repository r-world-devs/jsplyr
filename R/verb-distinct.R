#' @name distinct
#' @title Keep distinct records of `JSON` data.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Column names to determine uniqueness.
#'   If empty, all columns are used.
#' @importFrom dplyr distinct
#' @export
distinct.tbl_lazy_json <- function(.data, ...) {
  columns <- dots_to_select_query(...)
  .data$compute_steps <- add_distinct(.data, columns)
  .data$state_id <- generate_id()
  .data
}

add_distinct <- function(.data, columns = character(0)) {
  distinct_step <- compute_step(
    verb = "distinct",
    expression = columns
  )
  append(.data$compute_steps, list(distinct_step))
}
