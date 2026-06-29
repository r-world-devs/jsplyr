#' @name rename
#' @title Rename columns of `JSON` data.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Use `new_name = old_name` to rename columns. Both bare names and
#'   character strings are accepted (e.g. `rename(mpg_new = mpg)` or
#'   `rename("mpg_new" = "mpg")`). Column order is preserved.
#' @examples
#' \dontrun{
#' tbl(session, "mtcars") |>
#'   rename(miles_per_gallon = mpg, cylinders = cyl)
#' }
#' @importFrom dplyr rename
#' @export
rename.tbl_lazy_json <- function(.data, ...) {
  pairs <- dots_to_rename_query(...)
  .data$compute_steps <- add_rename(.data, pairs)
  .data$state_id <- generate_id()
  .data
}

# Parse rename() dots into a list of {new, old} entries. Each argument must be
# named (the new name); its value is the old column name, given as a bare
# symbol or a string.
dots_to_rename_query <- function(...) {
  dots <- rlang::enquos(...)
  new_names <- names(dots)
  if (is.null(new_names) || any(!nzchar(new_names))) {
    cli::cli_abort("All `rename()` arguments must be named: {.code new = old}.")
  }
  pairs <- purrr::imap(dots, function(dot, new_name) {
    expr <- rlang::quo_get_expr(dot)
    old_name <- if (rlang::is_string(expr)) {
      expr
    } else if (rlang::is_symbol(expr)) {
      rlang::as_string(expr)
    } else {
      rlang::quo_text(dot)
    }
    list(new = new_name, old = old_name)
  })
  unname(pairs)
}

add_rename <- function(.data, pairs) {
  rename_step <- compute_step(
    verb = "rename",
    pairs = pairs
  )
  append(.data$compute_steps, list(rename_step))
}
