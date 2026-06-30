# Arrange rows of `JSON` data by column values.

Arrange rows of `JSON` data by column values.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
arrange(.data, ..., .by_group = FALSE)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Columns to sort by. Wrap a column in
  [`dplyr::desc()`](https://dplyr.tidyverse.org/reference/desc.html) to
  sort it in descending order. Multiple columns break ties left to
  right. Bare column names and character strings are both accepted.

- .by_group:

  Ignored. Accepted for consistency with the generic; grouped arrange
  ordering is not applied for `tbl_lazy_json`.

## Details

Sorting happens in the browser and is stable across ties, so the
original row order is preserved within equal keys.

## Examples

``` r
if (FALSE) { # \dontrun{
tbl(session, "mtcars") |>
  arrange(cyl, desc(mpg))
} # }
```
