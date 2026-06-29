#' @name slice
#' @title Select rows of `JSON` data by position.
#' @description The `slice()` family picks rows by position or by ordering on a
#'   column. When the data has been grouped with [group_by()], slicing is
#'   applied within each group.
#' @param .data A `tbl_lazy_json` object.
#' @param ... For `slice()`, integer row positions to keep (1-based). Negative
#'   positions drop rows. For `slice_min()`/`slice_max()`, the bare column to
#'   order by.
#' @param n Number of rows to keep. Used by `slice_head()`, `slice_tail()`,
#'   `slice_min()`, and `slice_max()`. Defaults to 1 where applicable.
#' @param prop Proportion of rows to keep (0-1), an alternative to `n` for
#'   `slice_head()`/`slice_tail()`/`slice_min()`/`slice_max()`.
#' @details All slicing is evaluated in the browser. `slice_min()`/`slice_max()`
#'   order rows by the given column (ascending for min, descending for max) and
#'   keep the first `n` (or `prop`).
#' @examples
#' \dontrun{
#' tbl(session, "mtcars") |> slice(1, 3, 5)
#' tbl(session, "mtcars") |> slice_head(n = 5)
#' tbl(session, "mtcars") |> group_by(cyl) |> slice_max(mpg, n = 2)
#' }
#' @importFrom dplyr slice
#' @export
slice.tbl_lazy_json <- function(.data, ...) {
  positions <- unlist(rlang::list2(...), use.names = FALSE)
  positions <- as.integer(positions)
  .data$compute_steps <- add_slice(
    .data,
    type = "slice",
    opts = list(positions = as.list(positions))
  )
  .data$state_id <- generate_id()
  .data
}

#' @rdname slice
#' @importFrom dplyr slice_head
#' @export
slice_head.tbl_lazy_json <- function(.data, ..., n, prop) {
  .data$compute_steps <- add_slice(
    .data,
    type = "slice_head",
    opts = slice_np_params(n, prop)
  )
  .data$state_id <- generate_id()
  .data
}

#' @rdname slice
#' @importFrom dplyr slice_tail
#' @export
slice_tail.tbl_lazy_json <- function(.data, ..., n, prop) {
  .data$compute_steps <- add_slice(
    .data,
    type = "slice_tail",
    opts = slice_np_params(n, prop)
  )
  .data$state_id <- generate_id()
  .data
}

#' @rdname slice
#' @importFrom dplyr slice_min
#' @export
slice_min.tbl_lazy_json <- function(.data, ..., n, prop) {
  column <- slice_order_column(...)
  opts <- c(list(column = column), slice_np_params(n, prop))
  .data$compute_steps <- add_slice(.data, type = "slice_min", opts = opts)
  .data$state_id <- generate_id()
  .data
}

#' @rdname slice
#' @importFrom dplyr slice_max
#' @export
slice_max.tbl_lazy_json <- function(.data, ..., n, prop) {
  column <- slice_order_column(...)
  opts <- c(list(column = column), slice_np_params(n, prop))
  .data$compute_steps <- add_slice(.data, type = "slice_max", opts = opts)
  .data$state_id <- generate_id()
  .data
}

# Resolve the n/prop arguments into a normalised list carrying exactly one of
# them. Defaults to n = 1 when neither is supplied, matching dplyr.
slice_np_params <- function(n, prop) {
  has_n <- !missing(n)
  has_prop <- !missing(prop)
  if (has_n && has_prop) {
    cli::cli_abort("Supply only one of {.arg n} and {.arg prop}.")
  }
  if (has_prop) {
    return(list(prop = prop))
  }
  if (has_n) {
    return(list(n = n))
  }
  list(n = 1L)
}

# Extract the single ordering column for slice_min()/slice_max() from the dots.
slice_order_column <- function(...) {
  dots <- rlang::enquos(...)
  if (length(dots) < 1) {
    cli::cli_abort("`slice_min()`/`slice_max()` require an ordering column.")
  }
  expr <- rlang::quo_get_expr(dots[[1]])
  if (rlang::is_string(expr)) {
    return(expr)
  }
  if (rlang::is_symbol(expr)) {
    return(rlang::as_string(expr))
  }
  rlang::quo_text(dots[[1]])
}

add_slice <- function(.data, type, opts) {
  slice_step <- compute_step(
    verb = "slice",
    type = type,
    opts = opts
  )
  append(.data$compute_steps, list(slice_step))
}
