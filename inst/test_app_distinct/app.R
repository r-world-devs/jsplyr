pkgload::load_all()

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr distinct test app"),
  shiny::actionButton("run_by_city", "Distinct by city"),
  shiny::actionButton("run_all", "Distinct all"),
  shiny::textOutput("result_by_city"),
  shiny::textOutput("result_all")
)

server <- function(input, output, session) {

  distinct_by_city <- shiny::reactive({
    dplyr::copy_to(session, "example_json") |>
      dplyr::distinct(city) |>
      dplyr::compute()
  })

  distinct_all <- shiny::reactive({
    dplyr::copy_to(session, "example_json") |>
      dplyr::distinct() |>
      dplyr::compute()
  })

  shiny::observeEvent(input$run_by_city, {
    distinct_by_city()
  })

  shiny::observeEvent(input$run_all, {
    distinct_all()
  })

  output$result_by_city <- shiny::renderText({
    distinct_by_city() |>
      dplyr::collect(raw = TRUE)
  })

  output$result_all <- shiny::renderText({
    distinct_all() |>
      dplyr::collect(raw = TRUE)
  })
}

shiny::shinyApp(ui = ui, server = server)
