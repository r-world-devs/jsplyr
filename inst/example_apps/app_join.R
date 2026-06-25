pkgload::load_all()

# Two small tables whose keys deliberately mismatch on BOTH sides so that
# every join type produces a visibly different result:
#   - employees Evan and Fiona have dept_id 99, which has no matching department
#     (rows that exist only on the left).
#   - departments Finance (4) and Legal (5) have no employees
#     (rows that exist only on the right).
employees <- data.frame(
  name = c("Alice", "Bob", "Charlie", "Dana", "Evan", "Fiona"),
  dept_id = c(1L, 2L, 1L, 3L, 99L, 99L),
  stringsAsFactors = FALSE
)

departments <- data.frame(
  dept_id = c(1L, 2L, 3L, 4L, 5L),
  dept_name = c("Engineering", "Marketing", "Sales", "Finance", "Legal"),
  stringsAsFactors = FALSE
)

# Short description of what each join returns, shown next to the result.
join_descriptions <- list(
  left = paste(
    "All rows from employees, with department columns where a match exists",
    "(Evan and Fiona keep NA department)."
  ),
  right = paste(
    "All rows from departments, with employee columns where a match exists",
    "(Finance and Legal keep NA employee)."
  ),
  inner = "Only rows where the key matches in both tables.",
  full = paste(
    "All rows from both tables; unmatched rows on either side keep NA in the",
    "missing columns."
  ),
  semi = paste(
    "Employees that have a matching department. Keeps employee columns only;",
    "no rows are duplicated."
  ),
  anti = "Employees that have no matching department (Evan and Fiona)."
)

ui <- shiny::fluidPage(
  include_jsplyr(),
  shiny::titlePanel("jsplyr join examples"),
  shiny::p(
    "Pick a join type to see how", shiny::code("employees"), "and",
    shiny::code("departments"), "combine on the", shiny::code("dept_id"),
    "key. The two source tables are shown on the left; the join result is on",
    "the right."
  ),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::selectInput(
        inputId = "join_type",
        label = "Join type",
        choices = c(
          "left", "right", "inner", "full", "semi", "anti"
        ),
        selected = "left"
      ),
      shiny::h4("employees"),
      DT::DTOutput("employees_table"),
      shiny::h4("departments"),
      DT::DTOutput("departments_table")
    ),
    shiny::mainPanel(
      shiny::h4(shiny::textOutput("join_title")),
      shiny::p(shiny::textOutput("join_description")),
      DT::DTOutput("join_table")
    )
  )
)

server <- function(input, output, session) {

  # Show every row on a single page so the join result can be read at a glance.
  dt_options <- list(pageLength = 25, dom = "t")

  emp_tbl <- shiny::reactive({
    dplyr::copy_to(session, employees)
  })

  dept_tbl <- shiny::reactive({
    dplyr::copy_to(session, departments)
  })

  output$employees_table <- DT::renderDT(
    employees,
    options = dt_options,
    rownames = FALSE
  )

  output$departments_table <- DT::renderDT(
    departments,
    options = dt_options,
    rownames = FALSE
  )

  output$join_title <- shiny::renderText({
    paste0(input$join_type, "_join result")
  })

  output$join_description <- shiny::renderText({
    join_descriptions[[input$join_type]]
  })

  output$join_table <- DT::renderDT(
    {
      join_fns <- list(
        left = dplyr::left_join,
        right = dplyr::right_join,
        inner = dplyr::inner_join,
        full = dplyr::full_join,
        semi = dplyr::semi_join,
        anti = dplyr::anti_join
      )
      join_fn <- join_fns[[input$join_type]]
      join_fn(emp_tbl(), dept_tbl(), by = "dept_id") |>
        dplyr::collect()
    },
    options = dt_options,
    rownames = FALSE
  )
}

shiny::shinyApp(ui = ui, server = server)
