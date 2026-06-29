#' @title Link JS code.
#' @description Include the `jsplyr` JavaScript code in a Shiny app. To be put
#'   in the `UI` part of the app.
#' @return An `htmlDependency` object.
#' @name include_jsplyr
#' @export
include_jsplyr <- function() {
  htmltools::htmlDependency(
    name = "jsplyr",
    version = utils::packageVersion("jsplyr"),
    package = "jsplyr",
    src = "www",
    script = c(
      "copy_to.js",
      "distinct.js",
      "example_data.js",
      "filter.js",
      "group_by.js",
      "join.js",
      "mutate.js",
      "select.js",
      "summarise.js",
      "arrange.js",
      "rename.js",
      "relocate.js",
      "pull.js",
      "slice.js",
      "compute.js"
    )
  )
}
