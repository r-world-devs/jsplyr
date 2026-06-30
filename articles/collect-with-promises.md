# Working with collect() promises in reactive contexts

`jsplyr` keeps your data in the browser, so
[`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
has to fetch it back over an asynchronous round-trip. Because of that,
**[`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
returns a [promise](https://rstudio.github.io/promises/), not a data
frame**.

Reactive *outputs* such as
[`shiny::renderTable()`](https://rdrr.io/pkg/shiny/man/renderTable.html)
or [`DT::renderDT()`](https://rdrr.io/pkg/DT/man/dataTableOutput.html)
understand promises and resolve them for you, which is why a plain
[`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
inside a render function “just works”:

``` r
output$mtcars_tb <- DT::renderDT({
  lazy_mtcars_query() |>
    dplyr::collect()
})
```

Every other reactive context —
[`reactive()`](https://rdrr.io/pkg/shiny/man/reactive.html),
[`eventReactive()`](https://rdrr.io/pkg/shiny/man/observeEvent.html),
[`observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html) and
[`observe()`](https://rdrr.io/pkg/shiny/man/observe.html) — hands you
the promise as-is. The value resolves later, so you cannot use the
result of
[`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
synchronously on the next line; treating it as a data frame directly
gives you a promise object instead of your rows. You handle it with
[`promises::then()`](https://rstudio.github.io/promises/reference/then.html)
or the re-exported `%...>%` pipe.

## Two ways to unwrap a promise

Both of these work in *any* context —
[`reactive()`](https://rdrr.io/pkg/shiny/man/reactive.html),
[`eventReactive()`](https://rdrr.io/pkg/shiny/man/observeEvent.html),
[`observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html) and
[`observe()`](https://rdrr.io/pkg/shiny/man/observe.html) alike. Pick
whichever reads better. The examples below use the `%...>%` pipe.

### `promises::then()`

`then()` registers a callback that runs once the data arrives. It
returns a new promise, so it composes:

``` r
lazy_mtcars_query() |>
  dplyr::collect() |>
  promises::then(function(df) {
    # `df` is the collected tibble
    head(df)
  })
```

### `%...>%` pipe

The `promises` package ships a “promise pipe”, `%...>%`, that pipes the
*resolved* value into the next expression. It reads just like a regular
pipe but waits for the promise to settle first. `jsplyr` re-exports it,
so you do **not** have to import `promises` yourself:

``` r
lazy_mtcars_query() |>
  dplyr::collect() %...>%
  head()
```

Use `%...!%` to handle errors from the promise chain:

``` r
lazy_mtcars_query() |>
  dplyr::collect() %...>%
  head() %...!%
  (function(err) {
    shiny::showNotification(conditionMessage(err), type = "error")
  })
```

## A practical example: updating an input from a computed value

A common task is to set the value of an input — say a `selectInput` —
from a number computed in the browser. Functions like
[`shiny::updateSelectInput()`](https://rdrr.io/pkg/shiny/man/updateSelectInput.html)
are **side effects**, not reactive outputs. They do not understand
promises, so you cannot pass
[`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)’s
result straight to `selected` — you would hand it a promise object
instead of your value. Resolve the promise first and act on the value
once it arrives.

The cleanest approach keeps the
[`updateSelectInput()`](https://rdrr.io/pkg/shiny/man/updateSelectInput.html)
call **outside** the `jsplyr` pipeline. Store the resolved value in a
`reactiveVal` and let a separate observer update the input. This
decouples “compute the value” from “update the input”:

``` r
# Holds the value computed in the browser.
oldest_age <- shiny::reactiveVal(NULL)

# Pipeline: compute max(age) and store it. No UI update here.
shiny::observeEvent(input$update, {
  lazy_data() |>
    dplyr::summarise("max_age = max(age)") |>
    dplyr::collect() %...>% {
    oldest_age(.$max_age)
  }
})

# Separate observer: update the input when the computed value changes.
shiny::observeEvent(oldest_age(), {
  shiny::updateSelectInput(
    session,
    inputId = "age",
    selected = oldest_age()
  )
})
```

The `%...>%` pipe waits for the collected value to arrive, then `.`
holds the result tibble so `.$max_age` is written into the
`reactiveVal`. The second observer reacts to that change and performs
the update.

If you prefer to keep the computation in a reactive expression instead
of an observer, return the collected promise from an
[`eventReactive()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
(gated on the button) and resolve it in a separate
[`observe()`](https://rdrr.io/pkg/shiny/man/observe.html):

``` r
# Gated on the button: returns the collect() promise. Computes only.
oldest_age <- shiny::eventReactive(input$update, {
  lazy_data() |>
    dplyr::summarise("max_age = max(age)") |>
    dplyr::collect()
})

# Separate observer: resolve the promise and update the input.
shiny::observe({
  oldest_age() %...>% {
    shiny::updateSelectInput(
      session,
      inputId = "age",
      selected = .$max_age
    )
  }
})
```

[`eventReactive()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
returns the promise as-is, so `oldest_age()` is a promise; the
[`observe()`](https://rdrr.io/pkg/shiny/man/observe.html) resolves it
with `%...>%` and updates the input. A plain
[`reactive()`](https://rdrr.io/pkg/shiny/man/reactive.html) works the
same way if you want the value recomputed whenever its dependencies
change rather than only on a button press.

See `inst/example_apps/app_update_select.R` for a complete runnable app
showing both approaches.
