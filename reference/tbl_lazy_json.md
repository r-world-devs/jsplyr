# Create a lazy JSON tbl

Create a lazy JSON tbl

## Usage

``` r
tbl_lazy_json(session, json_name, compute_steps = list())
```

## Arguments

- session:

  A shiny `session` object.

- json_name:

  A character.

- compute_steps:

  A list of compute steps to be triggered when
  [`compute()`](https://r-world-devs.github.io/jsplyr/reference/compute.md)
  is called.

## Value

An object of class `tbl_lazy_json`: a list holding the shiny `session`,
a `state_id` keying the data in the browser, and the list of
`compute_steps` to run when the pipeline is computed.
