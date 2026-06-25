pkgload::load_all()

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr test app"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::textInput(
        inputId = "filter_expression", 
        label = "Filter Expression", 
        value = "",
        placeholder = "e.g. city == 'New York' & age >= 30"
      ),
      shiny::div(style = "margin: 15px"),
      shiny::selectInput(
        inputId = "select_expression", 
        label = "Select", 
        choices = c("age", "name", "city", "department"),
        selected = c("age", "name", "city", "department"),
        multiple = TRUE
      ),
      shiny::actionButton("run_btn", "Apply")
    ),
    shiny::mainPanel(
      shiny::h2("Original dataset"),
      shiny::textOutput("original_json"),
      shiny::h2("Steps"),
      shiny::textOutput("data_steps"),
      shiny::h2("Manipulated dataset"),
      shiny::textOutput("manipulated_json")
    )
  )
)

server <- function(input, output, session) {

  output$original_json <- shiny::renderText({
    dplyr::copy_to(session, "example_json") |>
      dplyr::compute() |>
      dplyr::collect(raw = TRUE)
  })

  manipulated_data <- shiny::reactive({
    shiny::req(input$filter_expression != "")
    dplyr::copy_to(session, "example_json") |>
        dplyr::filter(input$filter_expression) |>
        dplyr::select(input$select_expression ) |>
        dplyr::compute()
  })

  shiny::observeEvent(input$run_btn, {
    manipulated_data()
  })
  
  output$data_steps <- shiny::renderText({
    utils::capture.output(dplyr::show_query(manipulated_data()))
  })

  output$manipulated_json <- shiny::renderText({
    manipulated_data() |>
      dplyr::collect(raw = TRUE)
  })
}

shiny::shinyApp(ui = ui, server = server)
