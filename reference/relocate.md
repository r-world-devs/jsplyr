# Change column order of `JSON` data.

Change column order of `JSON` data.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
relocate(.data, ..., .before = NULL, .after = NULL)
```

## Arguments

- .data:

  A `tbl_lazy_json` object.

- ...:

  Columns to move. Bare names and character strings are accepted.

- .before, .after:

  Destination of the columns selected by `...`. Supply a single column
  (bare name or string) to place the moved columns before or after it.
  With neither, the selected columns move to the front.

## Value

A `tbl_lazy_json` object with the column reordering appended as a lazy
compute step, applied in the browser when the pipeline is evaluated.

## Details

Reordering happens in the browser by rebuilding each row's keys in the
new order. Columns not named in `...` keep their relative order.

## Examples

``` r
if (interactive()) {
  tbl(session, "mtcars") |> relocate(gear, carb)
  tbl(session, "mtcars") |> relocate(mpg, .after = cyl)
}
```
