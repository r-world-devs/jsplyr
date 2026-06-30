# Rename columns of `JSON` data.

Rename columns of `JSON` data.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
rename(.data, ...)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Use `new_name = old_name` to rename columns. Both bare names and
  character strings are accepted (e.g. `rename(mpg_new = mpg)` or
  `rename("mpg_new" = "mpg")`). Column order is preserved.

## Examples

``` r
if (FALSE) { # \dontrun{
tbl(session, "mtcars") |>
  rename(miles_per_gallon = mpg, cylinders = cyl)
} # }
```
