# Select rows of `JSON` data by position.

The `slice()` family picks rows by position or by ordering on a column.
When the data has been grouped with
[`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md),
slicing is applied within each group.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
slice(.data, ..., .by = NULL, .preserve = FALSE)

# S3 method for class 'tbl_lazy_json'
slice_head(.data, ..., n, prop, by = NULL)

# S3 method for class 'tbl_lazy_json'
slice_tail(.data, ..., n, prop, by = NULL)

# S3 method for class 'tbl_lazy_json'
slice_min(
  .data,
  order_by,
  ...,
  n,
  prop,
  by = NULL,
  with_ties = TRUE,
  na_rm = FALSE
)

# S3 method for class 'tbl_lazy_json'
slice_max(
  .data,
  order_by,
  ...,
  n,
  prop,
  by = NULL,
  with_ties = TRUE,
  na_rm = FALSE
)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  For `slice()`, integer row positions to keep (1-based). Negative
  positions drop rows. Unused by the other variants.

- .preserve:

  Ignored. Accepted for consistency with the generic.

- n:

  Number of rows to keep. Used by `slice_head()`, `slice_tail()`,
  `slice_min()`, and `slice_max()`. Defaults to 1 where applicable.

- prop:

  Proportion of rows to keep (0-1), an alternative to `n` for
  `slice_head()`/`slice_tail()`/`slice_min()`/`slice_max()`.

- by, .by:

  Ignored. Accepted for consistency with the generics; per-call grouping
  is not applied (use
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md),
  which slicing respects).

- order_by:

  For `slice_min()`/`slice_max()`, the column to order by (bare name or
  string).

- with_ties, na_rm:

  Ignored. Accepted for consistency with the `slice_min()`/`slice_max()`
  generics.

## Details

All slicing is evaluated in the browser. `slice_min()`/`slice_max()`
order rows by the given column (ascending for min, descending for max)
and keep the first `n` (or `prop`).

## Examples

``` r
if (FALSE) { # \dontrun{
tbl(session, "mtcars") |> slice(1, 3, 5)
tbl(session, "mtcars") |> slice_head(n = 5)
tbl(session, "mtcars") |> group_by(cyl) |> slice_max(mpg, n = 2)
} # }
```
