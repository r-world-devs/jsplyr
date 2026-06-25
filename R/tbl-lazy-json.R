#' @importFrom dplyr tbl
#' @export
tbl.ShinySession <- function(src, from, ...) {
  tbl_lazy_json(
    session = src, 
    json_name = from, 
    compute_steps = list(
      compute_step(verb = "take", name = from)
    )
  )
}

compute_step <- function(verb, ...) {
  step <- list(
    verb = verb,
    params = list(...)
  )
  step
}

#' Create a lazy JSON tbl
#' 
#' @param session A shiny `session` object.
#' @param json_name A character.
#' @param compute_steps A list of compute steps to be
#'   triggered when `compute()` is called.
#' @export
tbl_lazy_json <- function(session, json_name, compute_steps = list()) {

  obj <- list(
    session = session,
    state_id = json_name,
    compute_steps = compute_steps
  )
  class(obj) <- "tbl_lazy_json"
  return(obj)
}

#' @export
print.tbl_lazy_json <- function(x, ...) {
  steps <- x$compute_steps

  # The first step is always `take`, recording the original JSON source name.
  source_name <- if (length(steps) > 0 && identical(steps[[1]]$verb, "take")) {
    steps[[1]]$params$name
  } else {
    x$state_id
  }

  cli::cat_line(cli::style_bold("# Source:     "), "JSON array <`", source_name, "`>")
  cli::cat_line(
    cli::style_bold("# Lazy:       "),
    "not yet computed (call ", cli::col_cyan("collect()"), " to retrieve data)"
  )

  # Drop the leading `take` step; it is represented by the source line above.
  pipeline_steps <- if (length(steps) > 0 && identical(steps[[1]]$verb, "take")) {
    steps[-1]
  } else {
    steps
  }

  if (length(pipeline_steps) > 0) {
    cli::cat_line(cli::style_bold("# Pipeline:"))
    purrr::walk(pipeline_steps, function(step) {
      cli::cat_line("#   ", format_compute_step(step))
    })
  }

  invisible(x)
}

# Render a single compute step as a dplyr-like call, e.g. "filter(mpg >= 20)".
format_compute_step <- function(step) {
  verb <- step$verb
  params <- step$params

  if (verb == "filter") {
    return(paste0("filter(", params$expression, ")"))
  }
  if (verb == "select") {
    return(paste0("select(", paste0(params$expression, collapse = ", "), ")"))
  }
  if (verb == "distinct") {
    return(paste0("distinct(", paste0(params$expression, collapse = ", "), ")"))
  }
  if (verb == "group_by") {
    return(paste0("group_by(", paste0(params$expression, collapse = ", "), ")"))
  }
  if (verb == "mutate") {
    args <- purrr::map_chr(params$expressions, function(e) {
      paste0(e$name, " = ", e$expression)
    })
    return(paste0("mutate(", paste0(args, collapse = ", "), ")"))
  }
  if (verb == "summarise") {
    args <- purrr::map_chr(params$expressions, function(e) {
      paste0(e$name, " = ", e$fn, "(", e$column, ")")
    })
    return(paste0("summarise(", paste0(args, collapse = ", "), ")"))
  }
  if (verb == "join") {
    return(paste0(params$type, "_join(", format_join_by(params$by), ")"))
  }

  # Fallback for any unrecognised verb.
  paste0(verb, "()")
}

# Render the `by` argument of a join step for printing.
format_join_by <- function(by) {
  x_cols <- by$x
  y_cols <- by$y
  if (length(x_cols) == 0) {
    return("by = <natural>")
  }
  pairs <- purrr::map2_chr(x_cols, y_cols, function(xc, yc) {
    if (identical(xc, yc)) {
      paste0("\"", xc, "\"")
    } else {
      paste0("\"", xc, "\" = \"", yc, "\"")
    }
  })
  if (length(pairs) == 1) {
    paste0("by = ", pairs)
  } else {
    paste0("by = c(", paste0(pairs, collapse = ", "), ")")
  }
}
