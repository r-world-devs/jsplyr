pkgload::load_all()

# Demonstrates handling collect() promises outside of reactive outputs.
#
# collect() returns a promise (the result is fetched asynchronously from the
# browser). Reactive *outputs* such as DT::renderDT() resolve promises for you.
# In other reactive contexts you handle the promise yourself with
# promises::then() or the re-exported %...>% pipe. See
# vignette("collect-with-promises").
#
# Each tab below shows one of these patterns against the same mtcars data.

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr — handling collect() promises"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::numericInput(
        inputId = "filter_mpg",
        label = "Minimum mpg",
        value = 20
      ),
      # The render/reactive tabs resolve their promise automatically and
      # refresh as soon as `filter_mpg` changes, so Compute is only relevant
      # on the two observeEvent tabs, which fire on a button press.
      shiny::conditionalPanel(
        condition = "input.promise_tabs == 'observe_pipe' || input.promise_tabs == 'observe_then'",
        shiny::actionButton(
          inputId = "compute",
          label = "Compute"
        )
      )
    ),
    shiny::mainPanel(
      shiny::tabsetPanel(
        id = "promise_tabs",
        # ── renderDT resolves the promise automatically ─────────────────
        shiny::tabPanel(
          "renderDT (auto)",
          shiny::p(
            "Reactive outputs resolve the promise for you; ",
            "collect() can be the last call in the pipe."
          ),
          DT::DTOutput("auto_table")
        ),
        # ── reactive() returns a (chained) promise ──────────────────────
        shiny::tabPanel(
          "reactive() + %...>%",
          shiny::p(
            "A reactive returns the promise. Here it is chained with ",
            "%...>% head(10) and still returns a promise, which the ",
            "render output below resolves."
          ),
          DT::DTOutput("reactive_table")
        ),
        # ── observeEvent() with %...>% ──────────────────────────────────
        shiny::tabPanel(
          "observeEvent + %...>%",
          value = "observe_pipe",
          shiny::p(
            "Press Compute. The observer resolves the promise with the ",
            "%...>% pipe and pushes the row count into a reactiveVal."
          ),
          shiny::verbatimTextOutput("observe_pipe_text")
        ),
        # ── observeEvent() with promises::then() ────────────────────────
        shiny::tabPanel(
          "observeEvent + then()",
          value = "observe_then",
          shiny::p(
            "Press Compute. The observer resolves the promise with ",
            "promises::then() and renders the collected rows."
          ),
          DT::DTOutput("observe_then_table")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  lazy_mtcars_query <- shiny::reactive({
    dplyr::copy_to(dest = session, df = mtcars) |>
      dplyr::filter(mpg >= input$filter_mpg) |>
      dplyr::select("mpg", "cyl", "hp", "wt")
  })

  # ── renderDT resolves the promise automatically ─────────────────────
  output$auto_table <- DT::renderDT({
    lazy_mtcars_query() |>
      dplyr::collect()
  })

  # ── reactive() returns a chained promise; render resolves it ─────────
  # `collect() %...>% head(10)` returns a promise, so the reactive returns
  # a promise too. The render output then resolves it.
  collected_summary <- shiny::reactive({
    lazy_mtcars_query() |>
      dplyr::collect() %...>%
      head(10)
  })

  output$reactive_table <- DT::renderDT({
    collected_summary()
  })

  # ── observeEvent() with the %...>% pipe ─────────────────────────────
  row_count <- shiny::reactiveVal("Press Compute to collect.")

  shiny::observeEvent(input$compute, {
    lazy_mtcars_query() |>
      dplyr::collect() %...>% {
        # `.` is the collected tibble
        row_count(paste(nrow(.), "rows collected"))
      }
  })

  output$observe_pipe_text <- shiny::renderText({
    row_count()
  })

  # ── observeEvent() with promises::then() ────────────────────────────
  collected_rows <- shiny::reactiveVal(NULL)

  shiny::observeEvent(input$compute, {
    lazy_mtcars_query() |>
      dplyr::collect() |>
      promises::then(function(df) {
        collected_rows(df)
        shiny::showNotification(paste(nrow(df), "rows collected"))
      })
  })

  output$observe_then_table <- DT::renderDT({
    collected_rows()
  })
}

shiny::shinyApp(ui = ui, server = server)
