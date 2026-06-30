#' @name ungroup
#' @title Remove grouping from `JSON` data.
#' @description Drops grouping previously set with [group_by()]. With no
#'   arguments all grouping is removed; supplying column names removes only those
#'   columns from the grouping set (partial ungroup), matching [dplyr::ungroup()].
#' @param x A `tbl_lazy_json` object.
#' @param ... Columns to remove from the grouping. Accepts the same inputs as
#'   [group_by()] (bare names, strings, and the tidyselect helpers `c(...)`,
#'   `all_of()`/`any_of()`, `across()`). If empty, all grouping is removed.
#' @details Grouping is tracked as browser-side state consumed by group-aware
#'   verbs such as [summarise()] and the [slice()] family. `ungroup()` appends a
#'   step that clears or trims that state at compute time.
#' @examples
#' \dontrun{
#' tbl(session, "mtcars") |>
#'   group_by(cyl) |>
#'   ungroup()
#' }
#' @importFrom dplyr ungroup
#' @export
ungroup.tbl_lazy_json <- function(x, ...) {
  columns <- dots_to_group_by_query(..., .env = rlang::caller_env())
  x$compute_steps <- add_ungroup(x, columns)
  x$state_id <- generate_id()
  x
}

add_ungroup <- function(.data, columns = character(0)) {
  ungroup_step <- compute_step(
    verb = "ungroup",
    columns = as.list(columns)
  )
  append(.data$compute_steps, list(ungroup_step))
}
