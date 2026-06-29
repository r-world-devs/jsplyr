#' @name distinct
#' @title Keep distinct records of `JSON` data.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Column names to determine uniqueness.
#'   If empty, all columns are used.
#' @param .keep_all If `TRUE`, keep all columns in the output. When `FALSE`
#'   (the default) and columns are supplied in `...`, only those columns are
#'   returned, matching [dplyr::distinct()].
#' @importFrom dplyr distinct
#' @export
distinct.tbl_lazy_json <- function(.data, ..., .keep_all = FALSE) {
  columns <- dots_to_select_query(...)
  .data$compute_steps <- add_distinct(.data, columns, .keep_all)
  .data$state_id <- generate_id()
  .data
}

add_distinct <- function(.data, columns = character(0), keep_all = FALSE) {
  distinct_step <- compute_step(
    verb = "distinct",
    expression = columns,
    keep_all = keep_all
  )
  append(.data$compute_steps, list(distinct_step))
}
