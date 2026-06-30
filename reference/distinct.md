# Keep distinct records of `JSON` data.

Keep distinct records of `JSON` data.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
distinct(.data, ..., .keep_all = FALSE)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Column names to determine uniqueness. If empty, all columns are used.

- .keep_all:

  If `TRUE`, keep all columns in the output. When `FALSE` (the default)
  and columns are supplied in `...`, only those columns are returned,
  matching
  [`dplyr::distinct()`](https://dplyr.tidyverse.org/reference/distinct.html).
