pkgload::load_all()

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr showcase"),
  shiny::tabsetPanel(
    # ── Filter + Select ──────────────────────────────────────────────
    shiny::tabPanel(
      "Filter & Select",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::numericInput(
            inputId = "filter_age",
            label = "Minimum age",
            value = 0
          ),
          shiny::selectInput(
            inputId = "select_columns",
            label = "Select columns",
            choices = c("name", "age", "city", "department"),
            selected = c("name", "age", "city", "department"),
            multiple = TRUE
          )
        ),
        shiny::mainPanel(
          DT::DTOutput("filter_select_table")
        )
      )
    ),
    # ── Distinct ──────────────────────────────────────────────────────
    shiny::tabPanel(
      "Distinct",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::selectInput(
            inputId = "distinct_columns",
            label = "Distinct by columns",
            choices = c("name", "age", "city", "department"),
            selected = "city",
            multiple = TRUE
          )
        ),
        shiny::mainPanel(
          shiny::textOutput("distinct_row_count"),
          DT::DTOutput("distinct_table")
        )
      )
    ),
    # ── Group By + Summarise ──────────────────────────────────────────
    shiny::tabPanel(
      "Group By & Summarise",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::selectInput(
            inputId = "group_by_col",
            label = "Group by",
            choices = c("city", "department"),
            selected = "city"
          ),
          shiny::selectInput(
            inputId = "summary_fn",
            label = "Summary function",
            choices = c("mean", "sum", "min", "max", "median"),
            selected = "mean"
          )
        ),
        shiny::mainPanel(
          DT::DTOutput("summarise_table")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Show every row on a single page so verb results can be compared at a glance
  # instead of being split across paginated 10-row pages.
  dt_options <- list(pageLength = 50)

  json_tbl <- shiny::reactive({
    dplyr::copy_to(session, "example_json")
  })

  # ── Filter + Select ──────────────────────────────────────────────────
  output$filter_select_table <- DT::renderDT(
    {
      json_tbl() |>
        dplyr::filter(age >= input$filter_age) |>
        dplyr::select(input$select_columns) |>
        dplyr::collect()
    },
    options = dt_options
  )

  # ── Distinct ─────────────────────────────────────────────────────────
  distinct_result <- shiny::reactive({
    json_tbl() |>
      dplyr::distinct(input$distinct_columns) |>
      dplyr::collect()
  })

  output$distinct_row_count <- shiny::renderText({
    distinct_result() |>
      promises::then(function(df) paste0(nrow(df), " distinct rows"))
  })

  output$distinct_table <- DT::renderDT(
    {
      distinct_result()
    },
    options = dt_options
  )

  # ── Group By + Summarise ─────────────────────────────────────────────
  output$summarise_table <- DT::renderDT(
    {
      json_tbl() |>
        dplyr::group_by(input$group_by_col) |>
        dplyr::summarise(
          paste0("result = ", input$summary_fn, "(age)"),
          "count = n()"
        ) |>
        dplyr::collect()
    },
    options = dt_options
  )
}

shiny::shinyApp(ui = ui, server = server)
