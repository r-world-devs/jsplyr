# Copy a local or remote data frame to the browser

Copy a local or remote data frame to the browser

## Usage

``` r
# S3 method for class 'ShinySession'
copy_to(dest, df, ...)
```

## Arguments

- dest:

  A shiny `session` object.

- df:

  A local `data.frame` or a name of the JSON data in the browser.

- ...:

  Unused. Provided for consistency with generic.

## Value

Invisibly, a `tbl_lazy_json` object referencing the data now registered
in the browser, ready to be piped into the data manipulation verbs.
Called primarily for the side effect of sending the data to the client.
