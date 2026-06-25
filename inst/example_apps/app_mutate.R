pkgload::load_all()

# Demonstrates mutate() on a jsplyr table, including the conditional helpers
# ifelse(), if_else() and case_when() that are translated to JavaScript.
#
# Each mutate expression lives in its own text window. Users can add a window
# with "New expression" or remove one with its "Delete" button, then click
# "Apply" to splice the expressions into mutate() and recompute in the browser.

default_expressions <- c(
  "age_doubled = age * 2",
  "senior = ifelse(age >= 35, 'yes', 'no')",
  "age_band = case_when(age >= 45 ~ 'senior', age >= 30 ~ 'mid', TRUE ~ 'junior')"
)

# Build the UI for a single expression window: a text box plus a Delete button.
expression_window <- function(id, value = "") {
  shiny::div(
    id = paste0("window_", id),
    class = "well",
    style = "margin-bottom: 10px;",
    shiny::textAreaInput(
      inputId = paste0("expr_", id),
      label = NULL,
      value = value,
      rows = 2,
      width = "100%",
      placeholder = "name = expression"
    ),
    shiny::actionButton(
      inputId = paste0("delete_", id),
      label = "Delete",
      class = "btn-danger btn-sm"
    )
  )
}

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr mutate — write your own expressions"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::helpText(
        "Each window holds one mutate expression as ",
        shiny::code("name = expression"), ". Existing columns: ",
        shiny::code("name"), ", ", shiny::code("age"), ", ",
        shiny::code("city"), ", ", shiny::code("department"), "."
      ),
      shiny::helpText(
        "Conditional helpers ", shiny::code("ifelse()"), ", ",
        shiny::code("if_else()"), " and ", shiny::code("case_when()"),
        " are supported."
      ),
      shiny::div(id = "expression_windows"),
      shiny::actionButton("new_expr", "New expression", class = "btn-success"),
      shiny::actionButton("apply", "Apply", class = "btn-primary"),
      shiny::tags$hr(),
      shiny::strong("Errors:"),
      shiny::verbatimTextOutput("error_msg")
    ),
    shiny::mainPanel(
      DT::DTOutput("mutate_table")
    )
  )
)

server <- function(input, output, session) {

  json_tbl <- shiny::reactive({
    dplyr::copy_to(session, "example_json")
  })

  # Track the ids of the currently rendered expression windows, in order.
  window_ids <- shiny::reactiveVal(character(0))
  next_id <- shiny::reactiveVal(0L)

  add_window <- function(value = "") {
    id <- next_id() + 1L
    next_id(id)
    id <- as.character(id)

    shiny::insertUI(
      selector = "#expression_windows",
      where = "beforeEnd",
      ui = expression_window(id, value)
    )
    window_ids(c(window_ids(), id))

    # Each window gets a Delete observer that removes its UI and drops its id.
    shiny::observeEvent(input[[paste0("delete_", id)]], {
      shiny::removeUI(selector = paste0("#window_", id))
      window_ids(setdiff(window_ids(), id))
    }, once = TRUE, ignoreInit = TRUE)
  }

  # Seed the app with the default expressions on startup.
  shiny::observeEvent(TRUE, {
    for (expr in default_expressions) {
      add_window(expr)
    }
  }, once = TRUE)

  shiny::observeEvent(input$new_expr, {
    add_window()
  })

  error_text <- shiny::reactiveVal("")

  applied_expressions <- shiny::eventReactive(input$apply, {
    ids <- window_ids()
    lines <- vapply(ids, function(id) {
      value <- input[[paste0("expr_", id)]]
      if (is.null(value)) "" else value
    }, character(1))
    trimws(lines[nzchar(trimws(lines))])
  }, ignoreNULL = FALSE)

  result <- shiny::reactive({
    lines <- applied_expressions()
    error_text("")

    if (length(lines) == 0) {
      return(json_tbl() |> dplyr::collect())
    }

    tryCatch(
      json_tbl() |>
        dplyr::mutate(!!!lines) |>
        dplyr::collect(),
      error = function(e) {
        error_text(conditionMessage(e))
        NULL
      }
    )
  })

  output$error_msg <- shiny::renderText(error_text())

  output$mutate_table <- DT::renderDT(
    {
      res <- result()
      shiny::req(res)
      res
    },
    options = list(pageLength = 50)
  )
}

shiny::shinyApp(ui = ui, server = server)
