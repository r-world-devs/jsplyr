# Shared helpers for the tidyselect-style column helpers
# (`across()`, `all_of()`, `any_of()`, `c()`) used across verbs.
#
# Column selection resolution and `across()` expansion live here so that
# `filter()`, `mutate()`, `summarise()` and `group_by()` share one
# implementation. `across()` is expanded entirely on the R side into the same
# step entries the existing JS verb handlers already consume, so no JavaScript
# changes are required.

# Resolve the column selection passed to across()/if_all()/if_any() or a
# group_by() argument. Supports c(a, b), a bare column, a character vector,
# and all_of()/any_of() wrappers.
resolve_select_columns <- function(selection, env) {
  if (rlang::is_call(selection, "c")) {
    return(purrr::map_chr(as.list(selection)[-1], rlang::as_string))
  }
  if (rlang::is_call(selection, c("all_of", "any_of"))) {
    inner <- as.list(selection)[-1][[1]]
    return(as.character(rlang::eval_tidy(inner, env = env)))
  }
  if (rlang::is_symbol(selection)) {
    resolved <- tryCatch(rlang::eval_tidy(selection, env = env), error = function(e) NULL)
    if (is.character(resolved)) {
      return(resolved)
    }
    return(rlang::as_string(selection))
  }
  as.character(rlang::eval_tidy(selection, env = env))
}

# Replace the lambda pronouns `.x` and `.` with an actual column symbol.
substitute_dot <- function(node, column_sym) {
  if (rlang::is_symbol(node)) {
    if (identical(node, quote(.x)) || identical(node, quote(.))) {
      return(column_sym)
    }
    return(node)
  }
  if (rlang::is_call(node)) {
    return(as.call(lapply(as.list(node), substitute_dot, column_sym = column_sym)))
  }
  node
}

# Split the arguments of an across() call into its .cols, .fns and .names
# components, honouring both positional and named forms.
across_split_args <- function(args, env) {
  named <- names(args)
  cols_expr <- NULL
  fns_expr <- NULL
  dot_names <- NULL
  positional <- list()

  for (i in seq_along(args)) {
    nm <- if (!is.null(named)) named[[i]] else ""
    if (identical(nm, ".cols")) {
      cols_expr <- args[[i]]
    } else if (identical(nm, ".fns")) {
      fns_expr <- args[[i]]
    } else if (identical(nm, ".names")) {
      dot_names <- rlang::eval_tidy(args[[i]], env = env)
    } else if (!identical(nm, "")) {
      # Ignore unsupported named arguments (e.g. .unpack) rather than treating
      # them as the function selection.
      next
    } else {
      positional[[length(positional) + 1]] <- args[[i]]
    }
  }

  if (is.null(cols_expr) && length(positional) >= 1) {
    cols_expr <- positional[[1]]
  }
  if (is.null(fns_expr) && length(positional) >= 2) {
    fns_expr <- positional[[2]]
  }

  list(cols = cols_expr, fns = fns_expr, names = dot_names)
}

# Parse the `.fns` argument into a list of {name, fn} entries. Accepts a single
# function/formula or a (possibly named) list of them. A NULL `.fns` yields an
# identity entry, matching across(cols) used as a plain selection.
across_parse_fns <- function(fns_expr) {
  if (is.null(fns_expr)) {
    return(list(list(name = NULL, fn = NULL)))
  }
  if (rlang::is_call(fns_expr, "list")) {
    items <- as.list(fns_expr)[-1]
    item_names <- names(items)
    return(purrr::map(seq_along(items), function(i) {
      nm <- if (!is.null(item_names) && nzchar(item_names[[i]])) {
        item_names[[i]]
      } else {
        as.character(i)
      }
      list(name = nm, fn = items[[i]])
    }))
  }
  list(list(name = NULL, fn = fns_expr))
}

# Build the expression text for applying a single function spec to a column.
# Formulas have their `.x`/`.` pronouns replaced by the column; bare functions
# become `fn(column)`; a NULL function is the identity (the column itself).
across_build_expr_text <- function(fn, column_sym) {
  if (is.null(fn)) {
    return(rlang::as_string(column_sym))
  }
  if (rlang::is_formula(fn)) {
    body <- rlang::f_rhs(fn)
    substituted <- substitute_dot(body, column_sym)
    return(rlang::expr_text(substituted))
  }
  paste0(rlang::expr_text(fn), "(", rlang::as_string(column_sym), ")")
}

# Resolve the output column name for one (column, function) pair. Honours an
# explicit `.names` glue string (`{.col}`/`{.fn}` placeholders); otherwise uses
# `{.col}` for a single function and `{.col}_{.fn}` for several.
across_resolve_name <- function(dot_names, col, fn_name, n_fns) {
  if (!is.null(dot_names)) {
    out <- gsub("{.col}", col, dot_names, fixed = TRUE)
    out <- gsub("{.fn}", if (is.null(fn_name)) "1" else fn_name, out, fixed = TRUE)
    return(out)
  }
  if (n_fns > 1) {
    return(paste0(col, "_", fn_name))
  }
  col
}

# Expand an across() call into a list of {name, expression} text entries, one
# per (column, function) pair. The expression strings are fed into each verb's
# existing parser so the browser receives the same step shape it already knows.
expand_across_expressions <- function(args, env) {
  parts <- across_split_args(args, env)
  columns <- resolve_select_columns(parts$cols, env)
  fns <- across_parse_fns(parts$fns)
  n_fns <- length(fns)

  out <- list()
  for (col in columns) {
    column_sym <- rlang::sym(col)
    for (fn in fns) {
      expression <- across_build_expr_text(fn$fn, column_sym)
      name <- across_resolve_name(parts$names, col, fn$name, n_fns)
      out[[length(out) + 1]] <- list(name = name, expression = expression)
    }
  }
  out
}
