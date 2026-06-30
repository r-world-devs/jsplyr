# Promise pipe operators

[`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
on a `tbl_lazy_json` returns a
[`promises::promise()`](https://rstudio.github.io/promises/reference/promise.html),
because the result is fetched asynchronously from the browser. These
operators from the promises package are re-exported so you can consume
that result inside
[`shiny::observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
/ [`shiny::observe()`](https://rdrr.io/pkg/shiny/man/observe.html)
without attaching promises yourself.

## Usage

``` r
lhs %...>% rhs

lhs %...!% rhs

lhs %...T>% rhs
```

## Arguments

- lhs:

  A promise (e.g. the value returned by
  [`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)).

- rhs:

  A function call or expression applied to the resolved value.

## Examples

``` r
if (FALSE) { # \dontrun{
shiny::observeEvent(input$compute, {
  lazy_data() |>
    dplyr::filter(mpg >= input$min_mpg) |>
    dplyr::collect() %...>% {
      # `.` is the collected tibble
      print(.)
    }
})
} # }
```
