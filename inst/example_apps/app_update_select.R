pkgload::load_all()

# Demonstrates setting a selectInput's selected value from a number computed in
# the browser with jsplyr.
#
# collect() returns a promise (the result is fetched asynchronously from the
# browser). Reactive *outputs* resolve promises for you, but
# shiny::updateSelectInput() is a side effect, not an output — it cannot take a
# promise as `selected`. See vignette("collect-with-promises").
#
# In every case the updateSelectInput() call lives outside the jsplyr pipeline.
# The two tabs show two ways to get the computed value out to a separate
# observer that performs the update:
#
#   * reactiveVal:   an observer writes the resolved value into a reactiveVal;
#                    another observer reacts to it and updates the input.
#   * eventReactive: the collected promise is returned by an eventReactive;
#                    an observe() resolves it and updates the input.
#
# Both selects have fixed choices (all distinct ages). Pressing the button
# computes max(age) via summarise() and sets it as the selected value.

# Fixed choices: every distinct age in the example data.
age_choices <- sort(unique(c(
  25, 30, 35, 40, 28, 45, 32, 38, 50, 22, 28, 31, 37, 42
)))

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr — set a selectInput value from computed data"),
  shiny::tabsetPanel(
    # ── reactiveVal + observer ────────────────────────────────────────
    shiny::tabPanel(
      "reactiveVal",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::selectInput(
            inputId = "age_rv",
            label = "Age",
            choices = age_choices
          ),
          shiny::actionButton(
            inputId = "update_rv",
            label = "Select oldest"
          )
        ),
        shiny::mainPanel(
          shiny::p(
            "An observer resolves the collect() promise and writes max(age) ",
            "into a reactiveVal. A separate observer reacts to that value ",
            "and calls updateSelectInput()."
          ),
          shiny::verbatimTextOutput("selected_age_rv")
        )
      )
    ),
    # ── eventReactive + observe ───────────────────────────────────────
    shiny::tabPanel(
      "eventReactive",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::selectInput(
            inputId = "age_er",
            label = "Age",
            choices = age_choices
          ),
          shiny::actionButton(
            inputId = "update_er",
            label = "Select oldest"
          )
        ),
        shiny::mainPanel(
          shiny::p(
            "An eventReactive() gated on the button returns the collect() ",
            "promise. A separate observe() resolves it and calls ",
            "updateSelectInput()."
          ),
          shiny::verbatimTextOutput("selected_age_er")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  json_tbl <- shiny::reactive({
    dplyr::copy_to(session, "example_json")
  })

  # ── reactiveVal + observer ──────────────────────────────────────────
  # Holds the value computed in the browser. The pipeline only writes here.
  oldest_age <- shiny::reactiveVal(NULL)

  shiny::observeEvent(input$update_rv, {
    # Compute max(age) in the browser, resolve the collect() promise with
    # %...>%, and store the value. No UI update happens in this pipeline.
    json_tbl() |>
      dplyr::summarise(max_age = max(age)) |>
      dplyr::collect() %...>% {
        oldest_age(.$max_age)
      }
  })

  # Separate observer: update the input whenever the computed value changes.
  shiny::observeEvent(oldest_age(), {
    shiny::updateSelectInput(
      session,
      inputId = "age_rv",
      selected = oldest_age()
    )
  })

  output$selected_age_rv <- shiny::renderText({
    paste("Selected age:", input$age_rv)
  })

  # ── eventReactive + observe ─────────────────────────────────────────
  # Gated on the button, this returns the collect() promise. The pipeline
  # only computes; it does not touch the UI.
  oldest_age_promise <- shiny::eventReactive(input$update_er, {
    json_tbl() |>
      dplyr::summarise("max_age = max(age)") |>
      dplyr::collect()
  })

  # Separate observer: resolve the promise and update the input.
  shiny::observe({
    oldest_age_promise() %...>% {
      shiny::updateSelectInput(
        session,
        inputId = "age_er",
        selected = .$max_age
      )
    }
  })

  output$selected_age_er <- shiny::renderText({
    paste("Selected age:", input$age_er)
  })
}

shiny::shinyApp(ui = ui, server = server)
