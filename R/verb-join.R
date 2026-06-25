#' @name joins
#' @title Join two `JSON` tables.
#' @description Mutating joins (`left_join`, `right_join`, `inner_join`,
#'   `full_join`) combine columns from `x` and `y`, matching rows by key
#'   columns. Filtering joins (`semi_join`, `anti_join`) keep columns from
#'   `x`, using `y` only to determine which rows to keep.
#' @param x A `tbl_lazy_json` object (the left table).
#' @param y A `tbl_lazy_json` object (the right table). Must share the same
#'   browser `session` as `x`.
#' @param by A character vector of columns to join by. Use a named vector
#'   (e.g. `c("a" = "b")`) to match columns with different names in `x` and
#'   `y`. If `NULL` (the default), a natural join is performed using all
#'   columns common to both tables.
#' @param ... Unused. Provided for consistency with the generics.
#' @return A `tbl_lazy_json` object with the join appended as a compute step.
NULL

#' @rdname joins
#' @importFrom dplyr left_join
#' @export
left_join.tbl_lazy_json <- function(x, y, by = NULL, ...) {
  join_impl(x, y, by, type = "left")
}

#' @rdname joins
#' @importFrom dplyr right_join
#' @export
right_join.tbl_lazy_json <- function(x, y, by = NULL, ...) {
  join_impl(x, y, by, type = "right")
}

#' @rdname joins
#' @importFrom dplyr inner_join
#' @export
inner_join.tbl_lazy_json <- function(x, y, by = NULL, ...) {
  join_impl(x, y, by, type = "inner")
}

#' @rdname joins
#' @importFrom dplyr full_join
#' @export
full_join.tbl_lazy_json <- function(x, y, by = NULL, ...) {
  join_impl(x, y, by, type = "full")
}

#' @rdname joins
#' @importFrom dplyr semi_join
#' @export
semi_join.tbl_lazy_json <- function(x, y, by = NULL, ...) {
  join_impl(x, y, by, type = "semi")
}

#' @rdname joins
#' @importFrom dplyr anti_join
#' @export
anti_join.tbl_lazy_json <- function(x, y, by = NULL, ...) {
  join_impl(x, y, by, type = "anti")
}

join_impl <- function(x, y, by, type) {
  if (!inherits(y, "tbl_lazy_json")) {
    cli::cli_abort("{.arg y} must be a {.cls tbl_lazy_json} object.")
  }
  x$compute_steps <- add_join(x, y, by, type)
  x$state_id <- generate_id()
  x
}

add_join <- function(x, y, by, type) {
  join_step <- compute_step(
    verb = "join",
    type = type,
    by = process_by(by),
    y_steps = y$compute_steps
  )
  append(x$compute_steps, list(join_step))
}

# Normalise the `by` argument into a list with `x` and `y` key columns.
# - NULL              -> natural join (empty keys; resolved in the browser)
# - c("id")           -> x = "id",  y = "id"
# - c("a" = "b")      -> x = "a",   y = "b"
# - c("id", "a" = "b")-> x = c("id", "a"), y = c("id", "b")
process_by <- function(by) {
  if (is.null(by)) {
    return(list(x = character(0), y = character(0)))
  }
  nms <- names(by)
  if (is.null(nms)) {
    return(list(x = unname(by), y = unname(by)))
  }
  x_cols <- ifelse(nms == "", unname(by), nms)
  y_cols <- unname(by)
  list(x = x_cols, y = y_cols)
}
