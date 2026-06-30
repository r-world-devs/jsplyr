#' @name relocate
#' @title Change column order of `JSON` data.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Columns to move. Bare names and character strings are accepted.
#' @param .before,.after Destination of the columns selected by `...`. Supply a
#'   single column (bare name or string) to place the moved columns before or
#'   after it. With neither, the selected columns move to the front.
#' @details Reordering happens in the browser by rebuilding each row's keys in
#'   the new order. Columns not named in `...` keep their relative order.
#' @examples
#' \dontrun{
#' tbl(session, "mtcars") |> relocate(gear, carb)
#' tbl(session, "mtcars") |> relocate(mpg, .after = cyl)
#' }
#' @importFrom dplyr relocate
#' @export
relocate.tbl_lazy_json <- function(.data, ..., .before = NULL, .after = NULL) {
  columns <- dots_to_select_query(...)
  before <- relocate_anchor(rlang::enquo(.before))
  after <- relocate_anchor(rlang::enquo(.after))

  if (!is.null(before) && !is.null(after)) {
    cli::cli_abort("Supply only one of {.arg .before} and {.arg .after}.")
  }

  .data$compute_steps <- add_relocate(.data, columns, before, after)
  .data$state_id <- generate_id()
  .data
}

# Resolve a .before/.after argument to a single column name or NULL.
relocate_anchor <- function(anchor_quo) {
  expr <- rlang::quo_get_expr(anchor_quo)
  if (rlang::quo_is_null(anchor_quo) || is.null(expr)) {
    return(NULL)
  }
  if (rlang::is_string(expr)) {
    return(expr)
  }
  if (rlang::is_symbol(expr)) {
    return(rlang::as_string(expr))
  }
  rlang::quo_text(anchor_quo)
}

add_relocate <- function(.data, columns, before, after) {
  relocate_step <- compute_step(
    verb = "relocate",
    columns = as.list(columns),
    before = before,
    after = after
  )
  append(.data$compute_steps, list(relocate_step))
}
