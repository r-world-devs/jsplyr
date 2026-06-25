#' @name summarise
#' @title Summarise `JSON` data.
#' @param .data A `tbl_lazy_json` object.
#' @param ... Name-value pairs of summary functions.
#'   The name gives the name of the column in the output.
#'   The value should be a call to a summary function like
#'   `mean()`, `sum()`, `min()`, `max()`, `n()`.
#'
#'   `across()` is expanded on the R side into one summary per selected
#'   column. It accepts a single function (`across(c(a, b), mean)`) or a
#'   named list of functions (`across(c(a, b), list(mean = mean, sd = sd))`).
#'   Column selections accept `c(...)`, a bare column, a character vector, and
#'   `all_of()`/`any_of()`. Use `.names` with the `{.col}`/`{.fn}` glue
#'   placeholders to control the output column names; by default a single
#'   function reuses the input name and multiple functions produce
#'   `{.col}_{.fn}`.
#' @importFrom dplyr summarise
#' @export
summarise.tbl_lazy_json <- function(.data, ...) {
  expressions <- dots_to_summarise_query(...)
  .data$compute_steps <- add_summarise(.data, expressions)
  .data$state_id <- generate_id()
  .data
}

add_summarise <- function(.data, expressions) {
  summarise_step <- compute_step(
    verb = "summarise",
    expressions = expressions
  )
  append(.data$compute_steps, list(summarise_step))
}

dots_to_summarise_query <- function(...) {
  dots <- rlang::enquos(...)

  # Check if all inputs are character strings
  is_char <- tryCatch({
    args <- purrr::map(dots, rlang::eval_tidy)
    all(purrr::map_lgl(args, is.character))
  }, error = function(e) FALSE)

  if (is_char) {
    char_input <- unlist(purrr::map(dots, rlang::eval_tidy))
    return(parse_summarise_strings(unname(char_input)))
  }

  expanded <- purrr::imap(dots, function(dot, name) {
    expr <- rlang::quo_get_expr(dot)
    if (rlang::is_call(expr, "across")) {
      env <- rlang::quo_get_env(dot)
      across_entries <- expand_across_expressions(as.list(expr)[-1], env)
      return(purrr::map(across_entries, function(entry) {
        parsed <- parse_summary_expression(entry$expression)
        parsed$name <- entry$name
        parsed
      }))
    }
    parsed <- parse_summary_expression(rlang::quo_text(dot))
    parsed$name <- name
    list(parsed)
  })

  purrr::flatten(expanded) |> unname()
}

parse_summarise_strings <- function(strings) {
  purrr::map(strings, function(s) {
    # Match pattern: name = fn(column) or name = fn()
    match <- stringr::str_match(s, "^\\s*(\\w+)\\s*=\\s*(\\w+)\\(([^)]*)\\)\\s*$")
    if (is.na(match[1, 1])) {
      cli::cli_abort("Cannot parse summary expression: {s}")
    }
    list(
      name = match[1, 2],
      fn = match[1, 3],
      column = if (nchar(match[1, 4]) > 0) match[1, 4] else ""
    )
  })
}

parse_summary_expression <- function(expr_text) {
  # Match pattern: fn(column) or fn()
  match <- stringr::str_match(expr_text, "^(\\w+)\\(([^)]*)\\)$")
  if (is.na(match[1, 1])) {
    cli::cli_abort("Cannot parse summary expression: {expr_text}")
  }
  list(
    fn = match[1, 2],
    column = if (nchar(match[1, 3]) > 0) match[1, 3] else ""
  )
}
