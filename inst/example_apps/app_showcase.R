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
    ),
    # ── Arrange ───────────────────────────────────────────────────────
    shiny::tabPanel(
      "Arrange",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::selectInput(
            inputId = "arrange_col",
            label = "Sort by",
            choices = c("name", "age", "city", "department"),
            selected = "age"
          ),
          shiny::radioButtons(
            inputId = "arrange_dir",
            label = "Direction",
            choices = c("Ascending" = "asc", "Descending" = "desc"),
            selected = "asc"
          )
        ),
        shiny::mainPanel(
          DT::DTOutput("arrange_table")
        )
      )
    ),
    # ── Slice ─────────────────────────────────────────────────────────
    shiny::tabPanel(
      "Slice",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::selectInput(
            inputId = "slice_type",
            label = "Slice variant",
            choices = c(
              "slice_head" = "head",
              "slice_tail" = "tail",
              "slice_min" = "min",
              "slice_max" = "max"
            ),
            selected = "head"
          ),
          shiny::numericInput(
            inputId = "slice_n",
            label = "Number of rows (n)",
            value = 5,
            min = 1
          ),
          shiny::selectInput(
            inputId = "slice_col",
            label = "Order by (min/max only)",
            choices = c("age"),
            selected = "age"
          )
        ),
        shiny::mainPanel(
          DT::DTOutput("slice_table")
        )
      )
    ),
    # ── Count ─────────────────────────────────────────────────────────
    shiny::tabPanel(
      "Count",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::selectInput(
            inputId = "count_col",
            label = "Count by",
            choices = c("city", "department"),
            selected = "department"
          ),
          shiny::checkboxInput(
            inputId = "count_sort",
            label = "Sort by count (descending)",
            value = TRUE
          )
        ),
        shiny::mainPanel(
          DT::DTOutput("count_table")
        )
      )
    ),
    # ── Rename & Relocate ─────────────────────────────────────────────
    shiny::tabPanel(
      "Rename & Relocate",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::textInput(
            inputId = "rename_new",
            label = "Rename 'name' to",
            value = "employee"
          ),
          shiny::selectInput(
            inputId = "relocate_col",
            label = "Move column to front",
            choices = c("name", "age", "city", "department"),
            selected = "department"
          )
        ),
        shiny::mainPanel(
          DT::DTOutput("rename_relocate_table")
        )
      )
    ),
    # ── Pull ──────────────────────────────────────────────────────────
    shiny::tabPanel(
      "Pull",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::selectInput(
            inputId = "pull_col",
            label = "Pull column as a vector",
            choices = c("name", "age", "city", "department"),
            selected = "name"
          )
        ),
        shiny::mainPanel(
          shiny::verbatimTextOutput("pull_output")
        )
      )
    ),
    # ── Ungroup ───────────────────────────────────────────────────────
    shiny::tabPanel(
      "Ungroup",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::checkboxInput(
            inputId = "ungroup_apply",
            label = "Call ungroup() before slicing",
            value = FALSE
          ),
          shiny::helpText(
            "Pipeline: group_by(city) |> slice_max(age, n = 1).",
            "Grouped, slice_max() keeps the oldest person per city.",
            "After ungroup() it keeps a single oldest person overall."
          )
        ),
        shiny::mainPanel(
          DT::DTOutput("ungroup_table")
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

  # ── Arrange ──────────────────────────────────────────────────────────
  # arrange() accepts a string key, including a "desc(col)" wrapper for
  # descending order, so we build the sort key from the selected direction.
  output$arrange_table <- DT::renderDT(
    {
      sort_key <- if (input$arrange_dir == "desc") {
        paste0("desc(", input$arrange_col, ")")
      } else {
        input$arrange_col
      }
      json_tbl() |>
        dplyr::arrange(sort_key) |>
        dplyr::collect()
    },
    options = dt_options
  )

  # ── Slice ────────────────────────────────────────────────────────────
  output$slice_table <- DT::renderDT(
    {
      tbl <- json_tbl()
      n <- input$slice_n
      result <- switch(
        input$slice_type,
        head = dplyr::slice_head(tbl, n = n),
        tail = dplyr::slice_tail(tbl, n = n),
        min = dplyr::slice_min(tbl, input$slice_col, n = n),
        max = dplyr::slice_max(tbl, input$slice_col, n = n)
      )
      dplyr::collect(result)
    },
    options = dt_options
  )

  # ── Count ────────────────────────────────────────────────────────────
  output$count_table <- DT::renderDT(
    {
      json_tbl() |>
        dplyr::count(input$count_col, sort = input$count_sort) |>
        dplyr::collect()
    },
    options = dt_options
  )

  # ── Rename & Relocate ────────────────────────────────────────────────
  # The new name is dynamic, so build the `new = old` pair with setNames and
  # pass it through do.call. relocate() then moves the chosen column to front.
  output$rename_relocate_table <- DT::renderDT(
    {
      rename_args <- c(
        list(json_tbl()),
        stats::setNames(list("name"), input$rename_new)
      )
      do.call(dplyr::rename, rename_args) |>
        dplyr::relocate(input$relocate_col) |>
        dplyr::collect()
    },
    options = dt_options
  )

  # ── Pull ─────────────────────────────────────────────────────────────
  # pull() returns a promise resolving to a vector (like collect()), so we
  # format the resolved values for display.
  output$pull_output <- shiny::renderPrint({
    json_tbl() |>
      dplyr::pull(input$pull_col) |>
      promises::then(function(values) print(values))
  })

  # ── Ungroup ──────────────────────────────────────────────────────────
  # slice_max() retains grouping (like dplyr), so a grouped pipeline yields one
  # row per group. Inserting ungroup() clears the grouping, so the same
  # slice_max() returns a single row overall — making ungroup()'s effect visible.
  output$ungroup_table <- DT::renderDT(
    {
      tbl <- json_tbl() |>
        dplyr::group_by("city")
      if (isTRUE(input$ungroup_apply)) {
        tbl <- dplyr::ungroup(tbl)
      }
      tbl |>
        dplyr::slice_max("age", n = 1) |>
        dplyr::collect()
    },
    options = dt_options
  )
}

shiny::shinyApp(ui = ui, server = server)
