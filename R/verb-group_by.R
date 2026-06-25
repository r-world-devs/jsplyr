#' @name group_by
#' @title Group `JSON` data by one or more columns.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Columns to group by. Accepts bare column names as well as the
#'   tidyselect helpers `c(...)`, `all_of()`/`any_of()`, and `across()`, which
#'   are resolved to plain column names on the R side.
#' @importFrom dplyr group_by
#' @export
group_by.tbl_lazy_json <- function(.data, ...) {
  columns <- dots_to_group_by_query(..., .env = rlang::caller_env())
  .data$compute_steps <- add_group_by(.data, columns)
  .data$state_id <- generate_id()
  .data
}

# Resolve group_by() column selections, expanding the tidyselect helpers
# all_of()/any_of()/across() and c(...) to plain column names. Falls back to the
# select-style stringification for bare column names and character inputs.
dots_to_group_by_query <- function(..., .env = rlang::caller_env()) {
  dots <- rlang::enquos(...)
  has_helper <- purrr::some(dots, function(dot) {
    expr <- rlang::quo_get_expr(dot)
    rlang::is_call(expr, c("across", "all_of", "any_of", "c"))
  })
  if (!has_helper) {
    return(dots_to_select_query(...))
  }
  columns <- purrr::map(dots, function(dot) {
    expr <- rlang::quo_get_expr(dot)
    if (rlang::is_call(expr, "across")) {
      parts <- across_split_args(as.list(expr)[-1], .env)
      return(resolve_select_columns(parts$cols, .env))
    }
    if (rlang::is_call(expr, c("all_of", "any_of", "c"))) {
      return(resolve_select_columns(expr, .env))
    }
    rlang::quo_text(dot)
  })
  unlist(columns, use.names = FALSE)
}

add_group_by <- function(.data, columns) {
  group_by_step <- compute_step(
    verb = "group_by",
    expression = columns
  )
  append(.data$compute_steps, list(group_by_step))
}
