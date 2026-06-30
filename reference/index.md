# Package index

## Attach `jsplyr` dependency

- [`include_jsplyr()`](https://r-world-devs.github.io/jsplyr/reference/include_jsplyr.md)
  : Link JS code.

## dplyr verbs

### Initialize and retrieve

- [`copy_to(`*`<ShinySession>`*`)`](https://r-world-devs.github.io/jsplyr/reference/copy_to.ShinySession.md)
  : Copy a local or remote data frame to the browser

- [`tbl_lazy_json()`](https://r-world-devs.github.io/jsplyr/reference/tbl_lazy_json.md)
  : Create a lazy JSON tbl

- [`compute(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/compute.md)
  :

  Compute `JSON` data in the browser.

- [`collect(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
  :

  Retrieve `JSON` data from the browser.

- [`pull(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/pull.md)
  :

  Extract a single column from `JSON` data as a vector.

- [`show_query(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/show_query.md)
  : Present computation steps.

### Affect rows

- [`distinct(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/distinct.md)
  :

  Keep distinct records of `JSON` data.

- [`filter(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/filter.md)
  :

  Add filter to `JSON` data.

- [`arrange(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/arrange.md)
  :

  Arrange rows of `JSON` data by column values.

- [`slice(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/slice.md)
  [`slice_head(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/slice.md)
  [`slice_tail(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/slice.md)
  [`slice_min(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/slice.md)
  [`slice_max(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/slice.md)
  :

  Select rows of `JSON` data by position.

### Affect columns

- [`mutate(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/mutate.md)
  :

  Add or modify columns in `JSON` data.

- [`select(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/select.md)
  :

  Select columns from `JSON` data.

- [`rename(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/rename.md)
  :

  Rename columns of `JSON` data.

- [`relocate(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/relocate.md)
  :

  Change column order of `JSON` data.

### Join tables

- [`left_join(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/joins.md)
  [`right_join(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/joins.md)
  [`inner_join(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/joins.md)
  [`full_join(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/joins.md)
  [`semi_join(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/joins.md)
  [`anti_join(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/joins.md)
  :

  Join two `JSON` tables.

### Group and summarise

- [`group_by(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/group_by.md)
  :

  Group `JSON` data by one or more columns.

- [`ungroup(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/ungroup.md)
  :

  Remove grouping from `JSON` data.

- [`summarise(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/summarise.md)
  :

  Summarise `JSON` data.

- [`count(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/count.md)
  [`tally(`*`<tbl_lazy_json>`*`)`](https://r-world-devs.github.io/jsplyr/reference/count.md)
  :

  Count observations in `JSON` data.
