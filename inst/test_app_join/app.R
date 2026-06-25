pkgload::load_all()

employees <- data.frame(
  name = c("Alice", "Bob", "Charlie", "David"),
  dept_id = c(1L, 2L, 1L, 99L),
  stringsAsFactors = FALSE
)

departments <- data.frame(
  dept_id = c(1L, 2L, 3L),
  dept_name = c("Engineering", "Marketing", "Sales"),
  stringsAsFactors = FALSE
)

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr join test app"),
  shiny::actionButton("run_btn", "Apply"),
  shiny::textOutput("result_left"),
  shiny::textOutput("result_inner"),
  shiny::textOutput("result_full"),
  shiny::textOutput("result_semi"),
  shiny::textOutput("result_anti")
)

server <- function(input, output, session) {

  emp <- shiny::reactive(dplyr::copy_to(session, employees))
  dept <- shiny::reactive(dplyr::copy_to(session, departments))

  result_left <- shiny::reactive({
    dplyr::left_join(emp(), dept(), by = "dept_id") |>
      dplyr::compute()
  })

  result_inner <- shiny::reactive({
    dplyr::inner_join(emp(), dept(), by = "dept_id") |>
      dplyr::compute()
  })

  result_full <- shiny::reactive({
    dplyr::full_join(emp(), dept(), by = "dept_id") |>
      dplyr::compute()
  })

  result_semi <- shiny::reactive({
    dplyr::semi_join(emp(), dept(), by = "dept_id") |>
      dplyr::compute()
  })

  result_anti <- shiny::reactive({
    dplyr::anti_join(emp(), dept(), by = "dept_id") |>
      dplyr::compute()
  })

  shiny::observeEvent(input$run_btn, {
    result_left()
    result_inner()
    result_full()
    result_semi()
    result_anti()
  })

  output$result_left <- shiny::renderText({
    result_left() |> dplyr::collect(raw = TRUE)
  })
  output$result_inner <- shiny::renderText({
    result_inner() |> dplyr::collect(raw = TRUE)
  })
  output$result_full <- shiny::renderText({
    result_full() |> dplyr::collect(raw = TRUE)
  })
  output$result_semi <- shiny::renderText({
    result_semi() |> dplyr::collect(raw = TRUE)
  })
  output$result_anti <- shiny::renderText({
    result_anti() |> dplyr::collect(raw = TRUE)
  })
}

shiny::shinyApp(ui = ui, server = server)
