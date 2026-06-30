# Add filter to `JSON` data.

Add filter to `JSON` data.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
filter(.data, ...)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Filtering expressions. Comparisons (`==`, `>`, `<`, etc.) combined
  with `&`/`|` are supported, as well as the `dplyr` helpers
  [`is.na()`](https://rdrr.io/r/base/NA.html), `between()`, and
  `across()`/`if_all()`/`if_any()`. `across()`/`if_all()` and `if_any()`
  expand the predicate over the selected columns, combining them with
  `&` and `|` respectively. Column selections accept `c(...)`, a bare
  column, a character vector, and `all_of()`/`any_of()`. Values
  referenced from `input` or the calling environment are resolved on the
  R side; column references are evaluated in the browser.
