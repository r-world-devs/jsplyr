dots_to_select_query <- function(...) {
  parsed_dots <- tryCatch({
    as.character(...)
  }, error = function(e) {
    parsed_dots <- rlang::enquos(...) |>
      purrr::map(rlang::quo_text)
    unlist(parsed_dots) |>
      unname()    
  })
  parsed_dots
}

dots_to_filter_query <- function(.data, ..., .env = rlang::caller_env()) {
  filter_query <- tryCatch({
    as.character(...)
  }, error = function(e) {
    dots <- rlang::enquos(...)
    mask <- rlang::new_data_mask(.data[[1]])
    rendered <- purrr::map_chr(dots, function(quo) {
      render_filter_node(rlang::quo_get_expr(quo), mask, .env)
    })
    paste0(rendered, collapse = ", ")
  })
  filter_query
}

# Structural operators kept symbolic and recursed into.
filter_operators <- c(
  ">", "<", ">=", "<=", "==", "!=",
  "&", "|", "&&", "||",
  "+", "-", "*", "/", "^",
  "(", "!"
)

# dplyr helpers that need dedicated rendering rather than evaluation.
filter_special_funcs <- c("is.na", "between", "across", "if_all", "if_any")

# Walk a filter expression AST and render it as a string. Column references stay
# symbolic; everything resolvable from the data mask or `.env` (inputs, locals,
# literals) collapses to its value so the browser receives concrete operands.
render_filter_node <- function(expr, mask, env) {
  if (rlang::is_call(expr)) {
    nm <- tryCatch(rlang::call_name(expr), error = function(e) NULL)
    if (!is.null(nm) && nm %in% filter_special_funcs) {
      return(render_filter_special(nm, expr, mask, env))
    }
    if (!is.null(nm) && nm %in% filter_operators) {
      return(render_filter_operator(nm, expr, mask, env))
    }
  }

  sentinel <- structure(list(), class = "jsplyr_unresolved")
  value <- tryCatch(
    rlang::eval_tidy(expr, data = mask, env = env),
    error = function(e) sentinel
  )
  if (!inherits(value, "jsplyr_unresolved") && is.atomic(value) && length(value) == 1) {
    return(render_filter_literal(value))
  }

  if (rlang::is_symbol(expr)) {
    return(rlang::as_string(expr))
  }

  rlang::expr_text(expr)
}

render_filter_operator <- function(nm, expr, mask, env) {
  args <- as.list(expr)[-1]
  if (nm == "(") {
    return(paste0("(", render_filter_node(args[[1]], mask, env), ")"))
  }
  if (length(args) == 1) {
    return(paste0(nm, render_filter_node(args[[1]], mask, env)))
  }
  paste0(
    render_filter_node(args[[1]], mask, env), " ",
    nm, " ",
    render_filter_node(args[[2]], mask, env)
  )
}

render_filter_special <- function(nm, expr, mask, env) {
  args <- as.list(expr)[-1]
  if (nm == "is.na") {
    return(paste0("is.na(", render_filter_node(args[[1]], mask, env), ")"))
  }
  if (nm == "between") {
    return(paste0(
      "between(",
      render_filter_node(args[[1]], mask, env), ", ",
      render_filter_node(args[[2]], mask, env), ", ",
      render_filter_node(args[[3]], mask, env), ")"
    ))
  }
  # across() / if_all() / if_any(): expand the predicate over each column.
  render_filter_across(nm, args, mask, env)
}

render_filter_across <- function(nm, args, mask, env) {
  columns <- resolve_select_columns(args[[1]], env)
  predicate <- args[[2]]
  body <- if (rlang::is_formula(predicate)) {
    rlang::f_rhs(predicate)
  } else {
    predicate
  }
  combinator <- if (nm == "if_any") " | " else " & "
  parts <- purrr::map_chr(columns, function(column) {
    substituted <- substitute_dot(body, rlang::sym(column))
    render_filter_node(substituted, mask, env)
  })
  joined <- paste0(parts, collapse = combinator)
  if (length(parts) > 1) {
    paste0("(", joined, ")")
  } else {
    joined
  }
}

render_filter_literal <- function(value) {
  if (is.character(value)) {
    return(paste0("'", value, "'"))
  }
  if (is.logical(value)) {
    return(tolower(as.character(value)))
  }
  as.character(value)
}

dots_to_mutate_query <- function(...) {
  dots <- rlang::enquos(...)

  # Check if all inputs are character strings
  is_char <- tryCatch({
    args <- purrr::map(dots, rlang::eval_tidy)
    all(purrr::map_lgl(args, is.character))
  }, error = function(e) FALSE)

  if (is_char) {
    char_input <- unlist(purrr::map(dots, rlang::eval_tidy))
    return(parse_mutate_strings(unname(char_input)))
  }

  expanded <- purrr::imap(dots, function(dot, name) {
    expr <- rlang::quo_get_expr(dot)
    if (rlang::is_call(expr, "across")) {
      env <- rlang::quo_get_env(dot)
      return(expand_across_expressions(as.list(expr)[-1], env))
    }
    list(list(
      name = name,
      expression = rlang::quo_text(dot)
    ))
  })

  purrr::flatten(expanded) |> unname()
}

parse_mutate_strings <- function(strings) {
  purrr::map(strings, function(s) {
    # Match pattern: name = expression
    match <- stringr::str_match(s, "^\\s*(\\w+)\\s*=\\s*(.+)\\s*$")
    if (is.na(match[1, 1])) {
      cli::cli_abort("Cannot parse mutate expression: {s}")
    }
    list(
      name = match[1, 2],
      expression = stringr::str_trim(match[1, 3])
    )
  })
}
