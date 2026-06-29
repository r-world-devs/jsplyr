#' @name pull
#' @title Extract a single column from `JSON` data as a vector.
#' @description Like [collect()], `pull()` retrieves data asynchronously from
#'   the browser, so it returns a [promises::promise()] that resolves to a
#'   vector rather than returning the vector directly.
#' @param .data A `tbl_lazy_json` object.
#' @param var The column to extract. A bare name, a string, or a position.
#'   Positive positions count from the left; negative positions count from the
#'   right (e.g. `-1` is the last column), matching [dplyr::pull()].
#' @param ... Unused. Provided for consistency with the generic.
#' @return A promise resolving to a vector with the column's values.
#' @examples
#' \dontrun{
#' tbl(session, "mtcars") |>
#'   pull(mpg) %...>% print()
#' }
#' @importFrom dplyr pull
#' @importFrom promises then
#' @export
pull.tbl_lazy_json <- function(.data, var = -1, ...) {
  var_expr <- rlang::enquo(var)
  spec <- pull_var_spec(var_expr)

  .data$compute_steps <- add_pull(.data, spec)
  .data$state_id <- generate_id()

  computed <- dplyr::compute(.data)

  promises::then(computed$.promise, onFulfilled = function(json_str) {
    parsed <- jsonlite::fromJSON(json_str)
    df <- dplyr::as_tibble(parsed)
    if (ncol(df) == 0) {
      return(logical(0))
    }
    df[[1]]
  })
}

# Resolve the pull `var` argument into a {by, value} spec: either a column name
# (by = "name") or a 1-based/negative position (by = "index").
pull_var_spec <- function(var_expr) {
  expr <- rlang::quo_get_expr(var_expr)
  if (rlang::is_symbol(expr)) {
    return(list(by = "name", value = rlang::as_string(expr)))
  }
  value <- rlang::eval_tidy(var_expr)
  if (is.character(value)) {
    return(list(by = "name", value = value))
  }
  if (is.numeric(value)) {
    return(list(by = "index", value = as.integer(value)))
  }
  list(by = "name", value = rlang::quo_text(var_expr))
}

add_pull <- function(.data, spec) {
  pull_step <- compute_step(
    verb = "pull",
    by = spec$by,
    value = spec$value
  )
  append(.data$compute_steps, list(pull_step))
}
