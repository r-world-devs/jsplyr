#' Copy a local or remote data frame to the browser
#' @param dest A shiny `session` object.
#' @param df A local `data.frame` or a name of the
#'   JSON data in the browser.
#' @param ... Unused. Provided for consistency with generic.
#' @return Invisibly, a `tbl_lazy_json` object referencing the data now
#'   registered in the browser, ready to be piped into the data manipulation
#'   verbs. Called primarily for the side effect of sending the data to the
#'   client.
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
