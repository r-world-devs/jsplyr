# Group `JSON` data by one or more columns.

Group `JSON` data by one or more columns.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
group_by(.data, ...)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Columns to group by. Accepts bare column names as well as the
  tidyselect helpers `c(...)`, `all_of()`/`any_of()`, and `across()`,
  which are resolved to plain column names on the R side.
