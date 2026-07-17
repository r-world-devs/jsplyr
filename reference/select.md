# Select columns from `JSON` data.

Select columns from `JSON` data.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
select(.data, ...)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Column names.

## Value

A `tbl_lazy_json` object with the column selection appended as a lazy
compute step, applied in the browser when the pipeline is evaluated.
