# Retrieve `JSON` data from the browser.

Retrieve `JSON` data from the browser.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
collect(x, ..., raw = FALSE)
```

## Arguments

- x:

  A `tbl_lazy_json` object.

- ...:

  Unused. Provided for consistency with generic.

- raw:

  A logical, if `TRUE` returns `JSON` as character.

## Value

A
[`promises::promise()`](https://rstudio.github.io/promises/reference/promise.html).
When `raw = FALSE` (the default) it resolves to a
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
built from the computed `JSON`; when `raw = TRUE` it resolves to the raw
`JSON` string. The result is fetched asynchronously from the browser, so
the value is a promise rather than a data frame.
