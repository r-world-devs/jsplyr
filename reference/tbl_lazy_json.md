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
