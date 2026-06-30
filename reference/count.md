# Count observations in `JSON` data.

`count()` groups the data by the given columns and counts the rows in
each group. `tally()` counts rows for the existing grouping set by
[`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md)
without adding new grouping columns. Both build on the
[`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md)/[`summarise()`](https://r-world-devs.github.io/jsplyr/reference/summarise.md)
machinery and run in the browser.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
count(x, ..., wt = NULL, sort = FALSE, name = NULL)

# S3 method for class 'tbl_lazy_json'
tally(x, wt = NULL, sort = FALSE, name = NULL)
```

## Arguments

- x:

  A `tbl_lazy_json` object.

- ...:

  Columns to group by before counting (for `count()`). Accepts the same
  inputs as
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md).

- wt:

  Not supported; weighted counts are not implemented for
  `tbl_lazy_json`. Supplying a non-`NULL` value raises an error.

- sort:

  If `TRUE`, order the result by the count column descending.

- name:

  Name of the count column in the output. `NULL` uses `"n"`.

## Examples

``` r
if (FALSE) { # \dontrun{
tbl(session, "mtcars") |> count(cyl)
tbl(session, "mtcars") |> count(cyl, sort = TRUE)
tbl(session, "mtcars") |> group_by(cyl) |> tally()
} # }
```
