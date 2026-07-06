#' Promise pipe operators
#'
#' `collect()` on a `tbl_lazy_json` returns a [promises::promise()], because the
#' result is fetched asynchronously from the browser. These operators from the
#' \pkg{promises} package are re-exported so you can consume that result inside
#' `shiny::observeEvent()` / `shiny::observe()` without attaching \pkg{promises}
#' yourself.
#'
#' @param lhs A promise (e.g. the value returned by `collect()`).
#' @param rhs A function call or expression applied to the resolved value.
#' @return A [promises::promise()]. `%...>%` resolves with the value of `rhs`
#'   applied to the fulfilled value; `%...!%` handles a rejected promise; and
#'   `%...T>%` (tee) applies `rhs` for its side effects and resolves with the
#'   original fulfilled value. See [promises::pipes].
#' @name promise-pipes
#' @keywords internal
#' @examples
#' if (interactive()) {
#'   shiny::observeEvent(input$compute, {
#'     lazy_data() |>
#'       dplyr::filter(mpg >= input$min_mpg) |>
#'       dplyr::collect() %...>% {
#'         # `.` is the collected tibble
#'         print(.)
#'       }
#'   })
#' }
NULL

#' @importFrom promises %...>%
#' @name %...>%
#' @rdname promise-pipes
#' @export
promises::`%...>%`

#' @importFrom promises %...!%
#' @name %...!%
#' @rdname promise-pipes
#' @export
promises::`%...!%`

#' @importFrom promises %...T>%
#' @name %...T>%
#' @rdname promise-pipes
#' @export
promises::`%...T>%`
