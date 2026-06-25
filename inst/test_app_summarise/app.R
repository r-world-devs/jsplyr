pkgload::load_all()

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr summarise test app"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::selectInput(
        inputId = "group_by",
        label = "Group by",
        choices = c("city"),
        selected = "city"
      ),
      shiny::selectInput(
        inputId = "summary_fn",
        label = "Summary function",
        choices = c("mean", "sum", "min", "max", "median"),
        selected = "mean"
      ),
      shiny::actionButton("run_btn", "Apply")
    ),
    shiny::mainPanel(
      shiny::textOutput("result_json")
    )
  )
)

server <- function(input, output, session) {

  manipulated_data <- shiny::reactive({
    dplyr::copy_to(session, "example_json") |>
      dplyr::group_by(input$group_by) |>
      dplyr::summarise(
        paste0("result = ", input$summary_fn, "(age)"),
        "count = n()"
      ) |>
      dplyr::compute()
  })

  shiny::observeEvent(input$run_btn, {
    manipulated_data()
  })

  output$result_json <- shiny::renderText({
    manipulated_data() |>
      dplyr::collect(raw = TRUE)
  })
}

shiny::shinyApp(ui = ui, server = server)
