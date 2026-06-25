pkgload::load_all()

# Benchmark: dplyr (server-side) vs jsplyr (client-side).
# Two tabs: filter + select, and group_by + summarise.

# ── Generate benchmark datasets ──────────────────────────────────────
set.seed(42)
n <- 10000

filter_df <- data.frame(
  id = seq_len(n),
  category = sample(LETTERS[1:10], n, replace = TRUE),
  region = sample(c("North", "South", "East", "West"), n, replace = TRUE),
  score = round(rnorm(n, mean = 50, sd = 15), 2),
  revenue = round(runif(n, 100, 10000), 2),
  cost = round(runif(n, 50, 5000), 2),
  quantity = sample(1:500, n, replace = TRUE),
  stringsAsFactors = FALSE
)

summarise_df <- data.frame(
  id = seq_len(n),
  group_a = sample(LETTERS[1:5], n, replace = TRUE),
  group_b = sample(c("x", "y", "z"), n, replace = TRUE),
  value_1 = round(rnorm(n, mean = 100, sd = 25), 2),
  value_2 = round(runif(n, 0, 1000), 2),
  stringsAsFactors = FALSE
)

filter_json <- jsonlite::toJSON(filter_df, dataframe = "rows")
summarise_json <- jsonlite::toJSON(summarise_df, dataframe = "rows")

# ── UI ────────────────────────────────────────────────────────────────
ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::tags$head(
    shiny::tags$script(
      shiny::HTML(paste0(
        "var filter_bench_data = ", filter_json, ";\n",
        "var summarise_bench_data = ", summarise_json, ";"
      ))
    ),
    shiny::tags$style(shiny::HTML("
      .timing-box {
        padding: 12px; margin: 8px 0; border-radius: 6px;
        font-size: 16px; font-weight: bold;
      }
      .timing-dplyr  { background: #fce4ec; color: #b71c1c; }
      .timing-jsplyr { background: #e8f5e9; color: #1b5e20; }
      .timing-speedup { background: #e3f2fd; color: #0d47a1; }
    "))
  ),
  shiny::titlePanel("Benchmark: dplyr vs jsplyr"),
  shiny::p(
    "Compares server-side dplyr against client-side jsplyr on",
    shiny::strong(format(n, big.mark = ",")),
    "rows."
  ),
  shiny::hr(),
  shiny::tabsetPanel(
    # ── Filter + Select tab ────────────────────────────────────────────
    shiny::tabPanel(
      "Filter & Select",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          width = 3,
          shiny::numericInput(
            "fs_filter_score", "Score >=",
            value = 50, min = 0, max = 100, step = 5
          ),
          shiny::selectInput(
            "fs_select_cols", "Select columns",
            choices = c("id", "category", "region", "score",
                        "revenue", "cost", "quantity"),
            selected = c("category", "region", "score", "revenue"),
            multiple = TRUE
          ),
          shiny::numericInput(
            "fs_n_iter", "dplyr iterations",
            value = 100, min = 10, max = 1000, step = 10
          ),
          shiny::actionButton("fs_run_btn", "Run benchmark",
                              class = "btn-primary btn-block")
        ),
        shiny::mainPanel(
          width = 9,
          shiny::fluidRow(
            shiny::column(
              6,
              shiny::h4("dplyr (server-side)"),
              shiny::uiOutput("fs_dplyr_timing"),
              DT::DTOutput("fs_dplyr_result")
            ),
            shiny::column(
              6,
              shiny::h4("jsplyr (client-side)"),
              shiny::uiOutput("fs_jsplyr_timing"),
              DT::DTOutput("fs_jsplyr_result")
            )
          ),
          shiny::hr(),
          shiny::uiOutput("fs_speedup_box"),
          shiny::hr(),
          shiny::uiOutput("fs_row_counts")
        )
      )
    ),
    # ── Group By + Summarise tab ───────────────────────────────────────
    shiny::tabPanel(
      "Group By & Summarise",
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          width = 3,
          shiny::selectInput(
            "gs_group_col", "Group by",
            choices = c("group_a", "group_b"),
            selected = "group_a"
          ),
          shiny::selectInput(
            "gs_agg_fn", "Aggregation",
            choices = c("mean", "sum", "min", "max", "median", "sd"),
            selected = "mean"
          ),
          shiny::selectInput(
            "gs_value_col", "Value column",
            choices = c("value_1", "value_2"),
            selected = "value_1"
          ),
          shiny::numericInput(
            "gs_n_iter", "dplyr iterations",
            value = 100, min = 10, max = 1000, step = 10
          ),
          shiny::actionButton("gs_run_btn", "Run benchmark",
                              class = "btn-primary btn-block")
        ),
        shiny::mainPanel(
          width = 9,
          shiny::fluidRow(
            shiny::column(
              6,
              shiny::h4("dplyr (server-side)"),
              shiny::uiOutput("gs_dplyr_timing"),
              DT::DTOutput("gs_dplyr_result")
            ),
            shiny::column(
              6,
              shiny::h4("jsplyr (client-side)"),
              shiny::uiOutput("gs_jsplyr_timing"),
              DT::DTOutput("gs_jsplyr_result")
            )
          ),
          shiny::hr(),
          shiny::uiOutput("gs_speedup_box")
        )
      )
    )
  )
)

# ── Server ────────────────────────────────────────────────────────────
server <- function(input, output, session) {

  # ── Filter + Select ────────────────────────────────────────────────

  fs_dplyr_bench <- shiny::eventReactive(input$fs_run_btn, {
    threshold <- input$fs_filter_score
    cols <- input$fs_select_cols
    n_iter <- input$fs_n_iter

    elapsed <- system.time({
      for (i in seq_len(n_iter)) {
        res <- filter_df |>
          dplyr::filter(score >= threshold) |>
          dplyr::select(dplyr::all_of(cols))
      }
    })[["elapsed"]]

    list(
      result = res,
      total_ms = round(elapsed * 1000, 1),
      per_iter_ms = round(elapsed * 1000 / n_iter, 2)
    )
  })

  output$fs_dplyr_timing <- shiny::renderUI({
    bench <- fs_dplyr_bench()
    shiny::div(
      class = "timing-box timing-dplyr",
      sprintf(
        "Total: %s ms | Per call: %s ms (%d iterations)",
        bench$total_ms, bench$per_iter_ms, input$fs_n_iter
      )
    )
  })

  output$fs_dplyr_result <- DT::renderDT({
    fs_dplyr_bench()$result
  }, options = list(pageLength = 5, dom = "tip"))

  fs_lazy_json <- shiny::reactive({
    dplyr::copy_to(session, "filter_bench_data")
  })

  fs_jsplyr_query <- shiny::eventReactive(input$fs_run_btn, {
    fs_lazy_json() |>
      dplyr::filter(score >= input$fs_filter_score) |>
      dplyr::select(input$fs_select_cols) |>
      dplyr::compute()
  })

  output$fs_jsplyr_timing <- shiny::renderUI({
    shiny::req(fs_jsplyr_query())
    shiny::div(
      class = "timing-box timing-jsplyr",
      "Runs in the browser \u2014 zero R server time for filter + select"
    )
  })

  output$fs_jsplyr_result <- DT::renderDT({
    fs_jsplyr_query() |>
      dplyr::collect()
  }, options = list(pageLength = 5, dom = "tip"))

  output$fs_speedup_box <- shiny::renderUI({
    bench <- fs_dplyr_bench()
    shiny::div(
      class = "timing-box timing-speedup",
      shiny::HTML(paste0(
        "With jsplyr the filter + select runs entirely in the browser. ",
        "The R server spent <b>", bench$total_ms, " ms</b> ",
        "doing ", input$fs_n_iter, " dplyr calls ",
        "(<b>", bench$per_iter_ms, " ms</b> each). ",
        "jsplyr avoids this cost by offloading the work to JavaScript."
      ))
    )
  })

  output$fs_row_counts <- shiny::renderUI({
    bench <- fs_dplyr_bench()
    shiny::p(
      sprintf(
        "Original: %s rows | After filter: %s rows | Columns selected: %d",
        format(n, big.mark = ","),
        format(nrow(bench$result), big.mark = ","),
        ncol(bench$result)
      )
    )
  })

  # ── Group By + Summarise ───────────────────────────────────────────

  gs_dplyr_bench <- shiny::eventReactive(input$gs_run_btn, {
    grp <- input$gs_group_col
    fn_name <- input$gs_agg_fn
    val <- input$gs_value_col
    n_iter <- input$gs_n_iter

    agg_fn <- switch(fn_name,
      mean   = mean,
      sum    = sum,
      min    = min,
      max    = max,
      median = median,
      sd     = sd
    )

    elapsed <- system.time({
      for (i in seq_len(n_iter)) {
        res <- summarise_df |>
          dplyr::group_by(dplyr::across(dplyr::all_of(grp))) |>
          dplyr::summarise(
            result = agg_fn(.data[[val]]),
            count  = dplyr::n(),
            .groups = "drop"
          )
      }
    })[["elapsed"]]

    list(
      result = res,
      total_ms = round(elapsed * 1000, 1),
      per_iter_ms = round(elapsed * 1000 / n_iter, 2)
    )
  })

  output$gs_dplyr_timing <- shiny::renderUI({
    bench <- gs_dplyr_bench()
    shiny::div(
      class = "timing-box timing-dplyr",
      sprintf(
        "Total: %s ms | Per call: %s ms (%d iterations)",
        bench$total_ms, bench$per_iter_ms, input$gs_n_iter
      )
    )
  })

  output$gs_dplyr_result <- DT::renderDT({
    gs_dplyr_bench()$result
  }, options = list(pageLength = 10, dom = "t"))

  gs_lazy_json <- shiny::reactive({
    dplyr::copy_to(session, "summarise_bench_data")
  })

  gs_jsplyr_query <- shiny::eventReactive(input$gs_run_btn, {
    gs_lazy_json() |>
      dplyr::group_by(input$gs_group_col) |>
      dplyr::summarise(
        paste0("result = ", input$gs_agg_fn, "(", input$gs_value_col, ")"),
        "count = n()"
      ) |>
      dplyr::compute()
  })

  output$gs_jsplyr_timing <- shiny::renderUI({
    shiny::req(gs_jsplyr_query())
    shiny::div(
      class = "timing-box timing-jsplyr",
      "Runs in the browser \u2014 zero R server time for the aggregation step"
    )
  })

  output$gs_jsplyr_result <- DT::renderDT({
    gs_jsplyr_query() |>
      dplyr::collect()
  }, options = list(pageLength = 10, dom = "t"))

  output$gs_speedup_box <- shiny::renderUI({
    bench <- gs_dplyr_bench()
    shiny::div(
      class = "timing-box timing-speedup",
      shiny::HTML(paste0(
        "With jsplyr the aggregation runs entirely in the browser. ",
        "The R server spent <b>", bench$total_ms, " ms</b> ",
        "doing ", input$gs_n_iter, " dplyr calls ",
        "(<b>", bench$per_iter_ms, " ms</b> each). ",
        "jsplyr avoids this cost by offloading the work to JavaScript."
      ))
    )
  })
}

shiny::shinyApp(ui = ui, server = server)
