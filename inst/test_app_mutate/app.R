pkgload::load_all()

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr mutate test app"),
  shiny::actionButton("run_btn", "Apply"),
  shiny::textOutput("result_json")
)

server <- function(input, output, session) {

  manipulated_data <- shiny::reactive({
    dplyr::copy_to(session, "example_json") |>
      dplyr::mutate(
        age_doubled = age * 2,
        age_plus_ten = age + 10,
        senior = ifelse(age >= 35, 'yes', 'no'),
        senior_strict = if_else(age >= 35, 'yes', 'no'),
        age_band = case_when(
          age >= 45 ~ 'senior',
          age >= 30 ~ 'mid',
          TRUE ~ 'junior'
        )
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
