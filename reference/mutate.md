# Add or modify columns in `JSON` data.

Add or modify columns in `JSON` data.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
mutate(.data, ...)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Name-value pairs of expressions. The name gives the name of the column
  in the output. The value should be an expression using existing
  columns, e.g. `new_col = col1 + col2`.

  Conditional helpers are translated to JavaScript:
  [`ifelse()`](https://rdrr.io/r/base/ifelse.html) and `if_else()`
  become ternary operators, and `case_when()` becomes a chained set of
  ternary operators. `case_when()` clauses without a `TRUE ~ ...`
  catch-all yield `null` for unmatched rows, matching `dplyr`'s `NA`
  default.

  `across()` is expanded on the R side into one column per selection. It
  accepts a single function (`across(c(a, b), round)`), a formula lambda
  (`across(c(a, b), ~ .x * 2)`), or a named list of functions
  (`across(c(a, b), list(double = ~ .x * 2))`). Column selections accept
  `c(...)`, a bare column, a character vector, and
  `all_of()`/`any_of()`. Use `.names` with the `{.col}`/`{.fn}` glue
  placeholders to control the output column names; by default a single
  function reuses the input name and multiple functions produce
  `{.col}_{.fn}`.
