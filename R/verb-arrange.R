#' @name arrange
#' @title Arrange rows of `JSON` data by column values.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Columns to sort by. Wrap a column in `dplyr::desc()` to sort it
#'   in descending order. Multiple columns break ties left to right. Bare
#'   column names and character strings are both accepted.
#' @param .by_group Ignored. Accepted for consistency with the generic;
#'   grouped arrange ordering is not applied for `tbl_lazy_json`.
#' @details Sorting happens in the browser and is stable across ties, so the
#'   original row order is preserved within equal keys.
#' @examples
#' \dontrun{
#' tbl(session, "mtcars") |>
#'   arrange(cyl, desc(mpg))
#' }
#' @importFrom dplyr arrange
#' @export
arrange.tbl_lazy_json <- function(.data, ..., .by_group = FALSE) {
  keys <- dots_to_arrange_query(...)
  .data$compute_steps <- add_arrange(.data, keys)
  .data$state_id <- generate_id()
  .data
}

# Parse arrange() dots into a list of {column, direction} entries. `desc(col)`
# yields a descending key; everything else is ascending. Character inputs may
# carry a leading `-` or `desc()` wrapper too.
dots_to_arrange_query <- function(...) {
  dots <- rlang::enquos(...)
  keys <- purrr::map(dots, function(dot) {
    expr <- rlang::quo_get_expr(dot)
    if (rlang::is_call(expr, "desc")) {
      column <- rlang::as_string(as.list(expr)[[2]])
      return(list(column = column, direction = "desc"))
    }
    if (rlang::is_string(expr)) {
      return(parse_arrange_string(expr))
    }
    if (rlang::is_symbol(expr)) {
      # A symbol may be a bare column (use its name) or a variable holding a
      # column-name string, possibly wrapped in "desc(...)" (resolve and parse).
      resolved <- tryCatch(rlang::eval_tidy(dot), error = function(e) NULL)
      if (is.character(resolved) && length(resolved) == 1) {
        return(parse_arrange_string(resolved))
      }
      return(list(column = rlang::as_string(expr), direction = "asc"))
    }
    list(column = rlang::quo_text(dot), direction = "asc")
  })
  unname(keys)
}

parse_arrange_string <- function(s) {
  s <- stringr::str_trim(s)
  desc_match <- stringr::str_match(s, "^desc\\(\\s*(.+?)\\s*\\)$")
  if (!is.na(desc_match[1, 1])) {
    return(list(column = desc_match[1, 2], direction = "desc"))
  }
  if (startsWith(s, "-")) {
    return(list(column = stringr::str_trim(sub("^-", "", s)), direction = "desc"))
  }
  list(column = s, direction = "asc")
}

add_arrange <- function(.data, keys) {
  arrange_step <- compute_step(
    verb = "arrange",
    keys = keys
  )
  append(.data$compute_steps, list(arrange_step))
}
