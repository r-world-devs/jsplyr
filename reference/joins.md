# Join two `JSON` tables.

Mutating joins (`left_join`, `right_join`, `inner_join`, `full_join`)
combine columns from `x` and `y`, matching rows by key columns.
Filtering joins (`semi_join`, `anti_join`) keep columns from `x`, using
`y` only to determine which rows to keep.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
left_join(x, y, by = NULL, ...)

# S3 method for class 'tbl_lazy_json'
right_join(x, y, by = NULL, ...)

# S3 method for class 'tbl_lazy_json'
inner_join(x, y, by = NULL, ...)

# S3 method for class 'tbl_lazy_json'
full_join(x, y, by = NULL, ...)

# S3 method for class 'tbl_lazy_json'
semi_join(x, y, by = NULL, ...)

# S3 method for class 'tbl_lazy_json'
anti_join(x, y, by = NULL, ...)
```

## Arguments

- x:

  A `tbl_lazy_json` object (the left table).

- y:

  A `tbl_lazy_json` object (the right table). Must share the same
  browser `session` as `x`.

- by:

  A character vector of columns to join by. Use a named vector (e.g.
  `c("a" = "b")`) to match columns with different names in `x` and `y`.
  If `NULL` (the default), a natural join is performed using all columns
  common to both tables.

- ...:

  Unused. Provided for consistency with the generics.

## Value

A `tbl_lazy_json` object with the join appended as a compute step.
