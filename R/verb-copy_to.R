#' Copy a local or remote data frame to the browser
#' @param dest A shiny `session` object.
#' @param df A local `data.frame` or a name of the
#'   JSON data in the browser.
#' @param ... Unused. Provided for consistency with generic.
#' @importFrom dplyr copy_to
#' @export
copy_to.ShinySession <- function(dest, df, ...) {
  
  if (is.data.frame(df)) {
    json_data <- jsonlite::toJSON(df)
    json_name <- deparse(substitute(df))

    dest$sendCustomMessage(
      "copyJSONToBrowser", 
      list(
        jsonData = json_data,
        state_id = json_name
      )
    )
    out <- tbl(dest, from = json_name)
  }

  if (is.character(df)) {
    dest$sendCustomMessage(
      "copyJSONInBrowser", 
      list(
        jsonName = df,
        state_id = df
      )
    )
    out <- tbl(dest, from = df)
  }  

  invisible(out)
}
