#' @name count
#' @title Count observations in `JSON` data.
#' @description `count()` groups the data by the given columns and counts the
#'   rows in each group. `tally()` counts rows for the existing grouping set by
#'   [group_by()] without adding new grouping columns. Both build on the
#'   [group_by()]/[summarise()] machinery and run in the browser.
#' @param x A `tbl_lazy_json` object.
#' @param ... Columns to group by before counting (for `count()`). Accepts the
#'   same inputs as [group_by()].
#' @param wt Not supported; weighted counts are not implemented for
#'   `tbl_lazy_json`. Supplying a non-`NULL` value raises an error.
#' @param sort If `TRUE`, order the result by the count column descending.
#' @param name Name of the count column in the output. `NULL` uses `"n"`.
#' @examples
#' \dontrun{
#' tbl(session, "mtcars") |> count(cyl)
#' tbl(session, "mtcars") |> count(cyl, sort = TRUE)
#' tbl(session, "mtcars") |> group_by(cyl) |> tally()
#' }
#' @importFrom dplyr count
#' @export
count.tbl_lazy_json <- function(x, ..., wt = NULL, sort = FALSE, name = NULL) {
  check_count_wt(wt)
  columns <- dots_to_group_by_query(..., .env = rlang::caller_env())
  if (length(columns) > 0) {
    x$compute_steps <- add_group_by(x, columns)
  }
  x <- add_count_summary(x, name = if (is.null(name)) "n" else name, sort = sort)
  x$state_id <- generate_id()
  x
}

#' @rdname count
#' @importFrom dplyr tally
#' @export
tally.tbl_lazy_json <- function(x, wt = NULL, sort = FALSE, name = NULL) {
  check_count_wt(wt)
  x <- add_count_summary(x, name = if (is.null(name)) "n" else name, sort = sort)
  x$state_id <- generate_id()
  x
}

# Weighted counts (the `wt` argument) are not implemented in the browser.
check_count_wt <- function(wt) {
  if (!is.null(wt)) {
    cli::cli_abort("The {.arg wt} argument is not supported for {.cls tbl_lazy_json}.")
  }
}

# Append the count summarise step (and optional descending sort) shared by
# count() and tally(). Reuses the existing summarise/arrange JS handlers.
add_count_summary <- function(.data, name, sort) {
  .data$compute_steps <- add_summarise(
    .data,
    list(list(name = name, fn = "n", column = ""))
  )
  if (isTRUE(sort)) {
    .data$compute_steps <- add_arrange(
      .data,
      list(list(column = name, direction = "desc"))
    )
  }
  .data
}
