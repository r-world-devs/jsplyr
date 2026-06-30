# Remove grouping from `JSON` data.

Drops grouping previously set with
[`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md).
With no arguments all grouping is removed; supplying column names
removes only those columns from the grouping set (partial ungroup),
matching
[`dplyr::ungroup()`](https://dplyr.tidyverse.org/reference/group_by.html).

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
ungroup(x, ...)
```

## Arguments

- x:

  A `tbl_lazy_json` object.

- ...:

  Columns to remove from the grouping. Accepts the same inputs as
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md)
  (bare names, strings, and the tidyselect helpers `c(...)`,
  `all_of()`/`any_of()`, `across()`). If empty, all grouping is removed.

## Details

Grouping is tracked as browser-side state consumed by group-aware verbs
such as
[`summarise()`](https://r-world-devs.github.io/jsplyr/reference/summarise.md)
and the
[`slice()`](https://r-world-devs.github.io/jsplyr/reference/slice.md)
family. `ungroup()` appends a step that clears or trims that state at
compute time.

## Examples

``` r
if (FALSE) { # \dontrun{
tbl(session, "mtcars") |>
  group_by(cyl) |>
  ungroup()
} # }
```
