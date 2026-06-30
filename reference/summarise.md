# Summarise `JSON` data.

Summarise `JSON` data.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
summarise(.data, ...)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Name-value pairs of summary functions. The name gives the name of the
  column in the output. The value should be a call to a summary function
  like [`mean()`](https://rdrr.io/r/base/mean.html),
  [`sum()`](https://rdrr.io/r/base/sum.html),
  [`min()`](https://rdrr.io/r/base/Extremes.html),
  [`max()`](https://rdrr.io/r/base/Extremes.html), `n()`.

  `across()` is expanded on the R side into one summary per selected
  column. It accepts a single function (`across(c(a, b), mean)`) or a
  named list of functions
  (`across(c(a, b), list(mean = mean, sd = sd))`). Column selections
  accept `c(...)`, a bare column, a character vector, and
  `all_of()`/`any_of()`. Use `.names` with the `{.col}`/`{.fn}` glue
  placeholders to control the output column names; by default a single
  function reuses the input name and multiple functions produce
  `{.col}_{.fn}`.
