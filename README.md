
<!-- README.md is generated from README.Rmd. Please edit that file -->

# jsplyr <img src="man/figures/logo.png" align="right" height="138" style="float:right; height:138px;" alt = "jsplyr Logo"/>

<!-- badges: start -->

<!-- badges: end -->

`jsplyr` is a JavaScript backend for
[dplyr](https://github.com/tidyverse/dplyr/). Instead of manipulating
data on the Shiny server, it pushes the work to the browser, where it
runs on JSON data client-side. This keeps data wrangling fast and
responsive even for large `data.frame`s, while letting you write the
familiar dplyr verbs you already know.

> `jsplyr` is still in early stages of development. To check which
> `dplyr` verbs are supported check the [reference]() section.

# Install

``` r
install.packages("jsplyr")
```

# Usage

First, in `UI` you need to `include_jsplyr()` (sources `Javascript`
code).

Second, in `server` part you need to call `copy_to()` to register your
JSON data for further manipulation with `jsplyr`. This works similar to
`dbplyr::copy_to()` where you pass database connection as an input. The
difference is that you do not create a specific connection as in
`dbplyr`, you just make use of shiny `session` (which represents a
connection with the web browser).

`jsplyr` takes into account two cases:

1.  Your JSON data is already defined in the browser with `JavaScript`.

<!-- -->

    var mtcars = [{"mpg":21,"cyl":6,"disp":160,"hp":110,"drat":3.9,"wt":2.62,"qsec":16.46,"vs":0,"am":1,"gear":4,"carb":4,"_row":"Mazda RX4"},{"mpg":21,"cyl":6,"disp":160,"hp":110,"drat":3.9,"wt":2.875,"qsec":17.02,"vs":0,"am":1,"gear":4,"carb":4,"_row":"Mazda RX4 Wag"},{"mpg":22.8,"cyl":4,"disp":108,"hp":93,"drat":3.85,"wt":2.32,"qsec":18.61,"vs":1,"am":1,"gear":4,"carb":1,"_row":"Datsun 710"},{"mpg":21.4,"cyl":6,"disp":258,"hp":110,"drat":3.08,"wt":3.215,"qsec":19.44,"vs":1,"am":0,"gear":3,"carb":1,"_row":"Hornet 4 Drive"},{"mpg":18.7,"cyl":8,"disp":360,"hp":175,"drat":3.15,"wt":3.44,"qsec":17.02,"vs":0,"am":0,"gear":3,"carb":2,"_row":"Hornet Sportabout"},{"mpg":18.1,"cyl":6,"disp":225,"hp":105,"drat":2.76,"wt":3.46,"qsec":20.22,"vs":1,"am":0,"gear":3,"carb":1,"_row":"Valiant"},{"mpg":14.3,"cyl":8,"disp":360,"hp":245,"drat":3.21,"wt":3.57,"qsec":15.84,"vs":0,"am":0,"gear":3,"carb":4,"_row":"Duster 360"},{"mpg":24.4,"cyl":4,"disp":146.7,"hp":62,"drat":3.69,"wt":3.19,"qsec":20,"vs":1,"am":0,"gear":4,"carb":2,"_row":"Merc 240D"},{"mpg":22.8,"cyl":4,"disp":140.8,"hp":95,"drat":3.92,"wt":3.15,"qsec":22.9,"vs":1,"am":0,"gear":4,"carb":2,"_row":"Merc 230"},{"mpg":19.2,"cyl":6,"disp":167.6,"hp":123,"drat":3.92,"wt":3.44,"qsec":18.3,"vs":1,"am":0,"gear":4,"carb":4,"_row":"Merc 280"},{"mpg":17.8,"cyl":6,"disp":167.6,"hp":123,"drat":3.92,"wt":3.44,"qsec":18.9,"vs":1,"am":0,"gear":4,"carb":4,"_row":"Merc 280C"},{"mpg":16.4,"cyl":8,"disp":275.8,"hp":180,"drat":3.07,"wt":4.07,"qsec":17.4,"vs":0,"am":0,"gear":3,"carb":3,"_row":"Merc 450SE"},{"mpg":17.3,"cyl":8,"disp":275.8,"hp":180,"drat":3.07,"wt":3.73,"qsec":17.6,"vs":0,"am":0,"gear":3,"carb":3,"_row":"Merc 450SL"},{"mpg":15.2,"cyl":8,"disp":275.8,"hp":180,"drat":3.07,"wt":3.78,"qsec":18,"vs":0,"am":0,"gear":3,"carb":3,"_row":"Merc 450SLC"},{"mpg":10.4,"cyl":8,"disp":472,"hp":205,"drat":2.93,"wt":5.25,"qsec":17.98,"vs":0,"am":0,"gear":3,"carb":4,"_row":"Cadillac Fleetwood"},{"mpg":10.4,"cyl":8,"disp":460,"hp":215,"drat":3,"wt":5.424,"qsec":17.82,"vs":0,"am":0,"gear":3,"carb":4,"_row":"Lincoln Continental"},{"mpg":14.7,"cyl":8,"disp":440,"hp":230,"drat":3.23,"wt":5.345,"qsec":17.42,"vs":0,"am":0,"gear":3,"carb":4,"_row":"Chrysler Imperial"},{"mpg":32.4,"cyl":4,"disp":78.7,"hp":66,"drat":4.08,"wt":2.2,"qsec":19.47,"vs":1,"am":1,"gear":4,"carb":1,"_row":"Fiat 128"},{"mpg":30.4,"cyl":4,"disp":75.7,"hp":52,"drat":4.93,"wt":1.615,"qsec":18.52,"vs":1,"am":1,"gear":4,"carb":2,"_row":"Honda Civic"},{"mpg":33.9,"cyl":4,"disp":71.1,"hp":65,"drat":4.22,"wt":1.835,"qsec":19.9,"vs":1,"am":1,"gear":4,"carb":1,"_row":"Toyota Corolla"},{"mpg":21.5,"cyl":4,"disp":120.1,"hp":97,"drat":3.7,"wt":2.465,"qsec":20.01,"vs":1,"am":0,"gear":3,"carb":1,"_row":"Toyota Corona"},{"mpg":15.5,"cyl":8,"disp":318,"hp":150,"drat":2.76,"wt":3.52,"qsec":16.87,"vs":0,"am":0,"gear":3,"carb":2,"_row":"Dodge Challenger"},{"mpg":15.2,"cyl":8,"disp":304,"hp":150,"drat":3.15,"wt":3.435,"qsec":17.3,"vs":0,"am":0,"gear":3,"carb":2,"_row":"AMC Javelin"},{"mpg":13.3,"cyl":8,"disp":350,"hp":245,"drat":3.73,"wt":3.84,"qsec":15.41,"vs":0,"am":0,"gear":3,"carb":4,"_row":"Camaro Z28"},{"mpg":19.2,"cyl":8,"disp":400,"hp":175,"drat":3.08,"wt":3.845,"qsec":17.05,"vs":0,"am":0,"gear":3,"carb":2,"_row":"Pontiac Firebird"},{"mpg":27.3,"cyl":4,"disp":79,"hp":66,"drat":4.08,"wt":1.935,"qsec":18.9,"vs":1,"am":1,"gear":4,"carb":1,"_row":"Fiat X1-9"},{"mpg":26,"cyl":4,"disp":120.3,"hp":91,"drat":4.43,"wt":2.14,"qsec":16.7,"vs":0,"am":1,"gear":5,"carb":2,"_row":"Porsche 914-2"},{"mpg":30.4,"cyl":4,"disp":95.1,"hp":113,"drat":3.77,"wt":1.513,"qsec":16.9,"vs":1,"am":1,"gear":5,"carb":2,"_row":"Lotus Europa"},{"mpg":15.8,"cyl":8,"disp":351,"hp":264,"drat":4.22,"wt":3.17,"qsec":14.5,"vs":0,"am":1,"gear":5,"carb":4,"_row":"Ford Pantera L"},{"mpg":19.7,"cyl":6,"disp":145,"hp":175,"drat":3.62,"wt":2.77,"qsec":15.5,"vs":0,"am":1,"gear":5,"carb":6,"_row":"Ferrari Dino"},{"mpg":15,"cyl":8,"disp":301,"hp":335,"drat":3.54,"wt":3.57,"qsec":14.6,"vs":0,"am":1,"gear":5,"carb":8,"_row":"Maserati Bora"},{"mpg":21.4,"cyl":4,"disp":121,"hp":109,"drat":4.11,"wt":2.78,"qsec":18.6,"vs":1,"am":1,"gear":4,"carb":2,"_row":"Volvo 142E"}]t

In this case you simply pass the name used in `JavaScript` to
`copy_to()`.

``` r
lazy_mtcars <- shiny::reactive({
  dplyr::copy_to(dest = session, df = "mtcars")
})
```

2.  Your data is a `data.frame` loaded in a server.

In that case you pass the `data.frame` object to the function in order
to send it to the browser.

``` r
lazy_mtcars <- shiny::reactive({
  dplyr::copy_to(dest = session, df = mtcars)
})
```

Keep in mind that `jsplyr` works in a reactive context.

Once you have copied your JSON, you can manipulate it with the supported
verbs. `jsplyr`, similar to `dbplyr`, creates a lazy representation of
your data. Calling these verbs simply registers the next computation
steps (like queries in `dbplyr`) without triggering any computation in
the browser.

``` r
lazy_mtcars_query <- shiny::reactive({
  lazy_mtcars() |>
    dplyr::filter(mpg >= input$filter_mpg) |>
    dplyr::select(input$select_columns) |>
    dplyr::distinct()
})
```

To retrieve the data from the browser back to the server you call
`collect()`. This triggers the computation in the browser and returns
the result. (There is also a `compute()` step under the hood that runs
the registered steps; you do not need to call it yourself — `collect()`
runs it for you.)

``` r
output$mtcars_tb <- shiny::renderDT({
  lazy_mtcars_query() |>
    dplyr::collect()
})
```

You will find an example application in the `inst/example_apps` folder.

## A complete example app

Putting the pieces together, here is a minimal Shiny app that copies a
`data.frame` to the browser, filters and selects it lazily based on user
input, and renders the collected result. All the data manipulation
happens in the browser.

``` r
library(shiny)
library(jsplyr)

ui <- fluidPage(
  include_jsplyr(),
  titlePanel("jsplyr example"),
  sidebarLayout(
    sidebarPanel(
      numericInput("min_mpg", "Minimum mpg", value = 20),
      selectInput(
        "columns",
        "Columns",
        choices = names(mtcars),
        selected = c("mpg", "cyl", "hp"),
        multiple = TRUE
      )
    ),
    mainPanel(
      DT::DTOutput("table")
    )
  )
)

server <- function(input, output, session) {
  lazy_mtcars <- reactive({
    dplyr::copy_to(dest = session, df = mtcars)
  })

  output$table <- DT::renderDT({
    lazy_mtcars() |>
      dplyr::filter(mpg >= input$min_mpg) |>
      dplyr::select(input$columns) |>
      dplyr::collect()
  })
}

shinyApp(ui, server)
```

## Using `collect()` outside reactive outputs

`collect()` returns a [promise](https://rstudio.github.io/promises/),
because the result is fetched asynchronously from the browser. Reactive
outputs such as `renderDT()` resolve promises for you. In other reactive
contexts — `reactive()`, `eventReactive()`, `observeEvent()` and
`observe()` — you must handle the promise yourself (with
`promises::then()` or the re-exported `%...>%` pipe). See
`vignette("collect-with-promises")` for the details.
