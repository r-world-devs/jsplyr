# Extract a single column from `JSON` data as a vector.

Like
[`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md),
`pull()` retrieves data asynchronously from the browser, so it returns a
[`promises::promise()`](https://rstudio.github.io/promises/reference/promise.html)
that resolves to a vector rather than returning the vector directly.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
pull(.data, var = -1, name = NULL, ...)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- var:

  The column to extract. A bare name, a string, or a position. Positive
  positions count from the left; negative positions count from the right
  (e.g. `-1` is the last column), matching
  [`dplyr::pull()`](https://dplyr.tidyverse.org/reference/pull.html).

- name:

  Ignored. Accepted for consistency with the generic; named vectors are
  not produced for `tbl_lazy_json`.

- ...:

  Unused. Provided for consistency with the generic.

## Value

A promise resolving to a vector with the column's values.

## Examples

``` r
if (FALSE) { # \dontrun{
tbl(session, "mtcars") |>
  pull(mpg) %...>% print()
} # }
```
