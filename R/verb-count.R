#' @name count
#' @title Count observations in `JSON` data.
#' @description `count()` groups the data by the given columns and counts the
#'   rows in each group. `tally()` counts rows for the existing grouping set by
#'   [group_by()] without adding new grouping columns. Both build on the
#'   [group_by()]/[summarise()] machinery and run in the browser.
#' @param .data,x A `tbl_lazy_json` object.
#' @param ... Columns to group by before counting (for `count()`). Accepts the
#'   same inputs as [group_by()].
#' @param name Name of the count column in the output. Defaults to `"n"`.
#' @param sort If `TRUE`, order the result by the count column descending.
#' @examples
#' \dontrun{
#' tbl(session, "mtcars") |> count(cyl)
#' tbl(session, "mtcars") |> count(cyl, sort = TRUE)
#' tbl(session, "mtcars") |> group_by(cyl) |> tally()
#' }
#' @importFrom dplyr count
#' @export
count.tbl_lazy_json <- function(.data, ..., name = "n", sort = FALSE) {
  columns <- dots_to_group_by_query(..., .env = rlang::caller_env())
  if (length(columns) > 0) {
    .data$compute_steps <- add_group_by(.data, columns)
  }
  .data <- add_count_summary(.data, name = name, sort = sort)
  .data$state_id <- generate_id()
  .data
}

#' @rdname count
#' @importFrom dplyr tally
#' @export
tally.tbl_lazy_json <- function(x, ..., name = "n", sort = FALSE) {
  x <- add_count_summary(x, name = name, sort = sort)
  x$state_id <- generate_id()
  x
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
