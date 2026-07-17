# Compute `JSON` data in the browser.

Compute `JSON` data in the browser.

## Usage

``` r
# S3 method for class 'tbl_lazy_json'
compute(x, ...)
```

## Arguments

- x:

  A `tbl_lazy_json` object.

- ...:

  Unused. Provided for consistency with generic.

## Value

A `tbl_lazy_json` object with a pending computation attached. It carries
a `.promise` field holding a
[`promises::promise()`](https://rstudio.github.io/promises/reference/promise.html)
that resolves when the browser posts back the computed `JSON`. The
accumulated compute steps are reset so the object can be extended or
collected further.
