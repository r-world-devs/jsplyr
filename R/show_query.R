#' @name show_query
#' @title Present computation steps.
#' @param x A `tbl_lazy_json` object.
#' @param ... Filtering expressions.
#' @importFrom dplyr show_query
#' @export
show_query.tbl_lazy_json <- function(x, ...) {
  cli::cat_line(cli::style_bold("<Compute steps>"))
  purrr::walk(x$compute_steps, function(compute_step) {
    params <- paste0(as.character(compute_step$params), collapse = ", ")
    cli::cat_line(glue::glue("[{compute_step$verb}], <{params}>"))
  })
  invisible(x)
}
