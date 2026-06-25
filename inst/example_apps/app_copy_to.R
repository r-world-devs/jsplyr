pkgload::load_all()

# Demonstrates copy_to with an R data.frame.
# The data is serialised to JSON and sent to the browser,
# then manipulated client-side like any other jsplyr table.

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr copy_to — R data.frame to browser"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::selectInput(
        inputId = "select_cols",
        label = "Select columns",
        choices = names(mtcars),
        selected = c("mpg", "cyl", "hp", "wt"),
        multiple = TRUE
      ),
      shiny::numericInput(
        inputId = "filter_mpg",
        label = "Minimum mpg",
        value = 0
      )
    ),
    shiny::mainPanel(
      shiny::h4("mtcars (transferred from R to browser via copy_to)"),
      DT::DTOutput("data_output")
    )
  )
)

server <- function(input, output, session) {

  lazy_mtcars <- shiny::reactive({
    dplyr::copy_to(dest = session, df = mtcars)
  })

  output$data_output <- DT::renderDT({
    lazy_mtcars() |>
      dplyr::filter(mpg >= input$filter_mpg) |>
      dplyr::select(input$select_cols) |>
      dplyr::collect()
  })
}

shiny::shinyApp(ui = ui, server = server)
