# Changelog

## jsplyr 0.1.0

Initial CRAN release.

### Core interface:

- Added a `dplyr` interface for manipulating data in JavaScript with
  `tbl()`, `copy_to()`,
  [`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md),
  [`compute()`](https://r-world-devs.github.io/jsplyr/reference/compute.md),
  and
  [`show_query()`](https://r-world-devs.github.io/jsplyr/reference/show_query.md).
- Added a promise-based
  [`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
  decoupled from `shiny`’s reactive input system.
  [`compute()`](https://r-world-devs.github.io/jsplyr/reference/compute.md)
  uses `session$registerDataObj()` to create a session-scoped HTTP
  callback; the JS side `POST`s the result to it, resolving a promise.
  [`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
  does not require a reactive context.
- Embedded
  [`compute()`](https://r-world-devs.github.io/jsplyr/reference/compute.md)
  within
  [`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
  so it runs automatically when not called earlier in the pipeline.
- Re-exported the promise pipe operators `%...>%`, `%...!%`, and
  `%...T>%` from `promises`, so
  [`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
  results can be consumed in reactive contexts without attaching
  `promises`.

### Verbs:

- Added the
  [`filter()`](https://r-world-devs.github.io/jsplyr/reference/filter.md)
  verb to subset rows by predicate expressions, evaluated client-side.
  Comparisons (`==`, `>`, `<`, etc.) combined with `&`/`|` are
  supported. Values referenced from `input` or the calling environment
  are resolved on the R side; column references are evaluated in the
  browser.
- Added the
  [`select()`](https://r-world-devs.github.io/jsplyr/reference/select.md)
  verb to choose columns by name.
- Added the
  [`distinct()`](https://r-world-devs.github.io/jsplyr/reference/distinct.md)
  verb to keep unique rows. When columns are supplied in `...` only
  those determine uniqueness and the first row per unique combination is
  kept; with no columns all columns are used. Supports `.keep_all` to
  retain all columns in the output.
- Added the
  [`mutate()`](https://r-world-devs.github.io/jsplyr/reference/mutate.md)
  verb for adding or modifying columns using expressions. Supports both
  non-standard evaluation and character string inputs.
- Added [`ifelse()`](https://rdrr.io/r/base/ifelse.html) support in
  [`mutate()`](https://r-world-devs.github.io/jsplyr/reference/mutate.md)
  expressions, translated to JavaScript ternary operators. Nested
  [`ifelse()`](https://rdrr.io/r/base/ifelse.html) calls are supported.
- Added `if_else()` as an alias for
  [`ifelse()`](https://rdrr.io/r/base/ifelse.html) in
  [`mutate()`](https://r-world-devs.github.io/jsplyr/reference/mutate.md)
  expressions; both translate to JavaScript ternary operators.
- Added `case_when()` support in
  [`mutate()`](https://r-world-devs.github.io/jsplyr/reference/mutate.md)
  expressions, translated to chained JavaScript ternary operators.
  Clauses without a `TRUE ~ ...` catch-all yield `null` for unmatched
  rows, matching `dplyr`’s `NA` default.
- Added
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md)
  and
  [`summarise()`](https://r-world-devs.github.io/jsplyr/reference/summarise.md)
  verbs with support for [`mean()`](https://rdrr.io/r/base/mean.html),
  [`sum()`](https://rdrr.io/r/base/sum.html),
  [`min()`](https://rdrr.io/r/base/Extremes.html),
  [`max()`](https://rdrr.io/r/base/Extremes.html), `n()`,
  [`sd()`](https://rdrr.io/r/stats/sd.html), and
  [`median()`](https://rdrr.io/r/stats/median.html) aggregation
  functions.
- Added join verbs `left_join()`, `right_join()`, `inner_join()`,
  `full_join()`, `semi_join()`, and `anti_join()`. Joining two
  `tbl_lazy_json` tables is performed in the browser. Supports `by` as a
  natural join (default), a shared key, or a named vector for differing
  key names. Colliding non-key columns get `.x`/`.y` suffixes.
- Added [`is.na()`](https://rdrr.io/r/base/NA.html), `between()`, and
  `across()`/`if_all()`/`if_any()` support in
  [`filter()`](https://r-world-devs.github.io/jsplyr/reference/filter.md)
  expressions. [`is.na()`](https://rdrr.io/r/base/NA.html) and
  `between()` are translated to JavaScript on the browser side, while
  `across()`/`if_all()`/`if_any()` are expanded over the selected
  columns (combined with `&` for `across()`/`if_all()` and `|` for
  `if_any()`). Column selections accept `c(...)`, a bare column, a
  character vector, and `all_of()`/`any_of()`.
- Added `across()` support to
  [`mutate()`](https://r-world-devs.github.io/jsplyr/reference/mutate.md)
  and
  [`summarise()`](https://r-world-devs.github.io/jsplyr/reference/summarise.md),
  and `all_of()`/`any_of()`/`across()` column resolution to
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md).
  `across()` is expanded on the R side over the selected columns and
  accepts a single function, a formula lambda (`~ .x * 2`), or a named
  list of functions, with optional `.names` glue (`{.col}`/`{.fn}`).
  `if_any()`/`if_all()` remain
  [`filter()`](https://r-world-devs.github.io/jsplyr/reference/filter.md)-only.
- Added
  [`ungroup()`](https://r-world-devs.github.io/jsplyr/reference/ungroup.md)
  to remove grouping set by
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md).
  With no arguments all grouping is dropped; supplying column names
  removes only those columns from the grouping set (partial ungroup),
  matching
  [`dplyr::ungroup()`](https://dplyr.tidyverse.org/reference/group_by.html).
- Added
  [`arrange()`](https://r-world-devs.github.io/jsplyr/reference/arrange.md)
  to sort rows client-side by one or more columns. Wrap a column in
  `desc()` for descending order; multiple keys break ties left to right
  and the sort is stable. `NA`/`null` values sort last.
- Added
  [`rename()`](https://r-world-devs.github.io/jsplyr/reference/rename.md)
  to rename columns with `new = old` pairs, preserving column order.
- Added the
  [`slice()`](https://r-world-devs.github.io/jsplyr/reference/slice.md)
  family:
  [`slice()`](https://r-world-devs.github.io/jsplyr/reference/slice.md)
  (integer positions, negative positions drop rows),
  `slice_head()`/`slice_tail()` (first/last `n` or `prop`), and
  `slice_min()`/`slice_max()` (rows with the smallest/largest values of
  a column). Slicing is group-aware when the data is grouped with
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md).
- Added
  [`pull()`](https://r-world-devs.github.io/jsplyr/reference/pull.md) to
  extract a single column as a vector. Like
  [`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md),
  it returns a
  [`promises::promise()`](https://rstudio.github.io/promises/reference/promise.html)
  resolving to the vector. Supports selection by name and by position,
  including negative indices counting from the last column.
- Added
  [`count()`](https://r-world-devs.github.io/jsplyr/reference/count.md)
  and `tally()`.
  [`count()`](https://r-world-devs.github.io/jsplyr/reference/count.md)
  groups by the given columns and counts rows per group; `tally()`
  counts within an existing
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md).
  Both honour the `name` (default `"n"`) and `sort` arguments and reuse
  the
  [`group_by()`](https://r-world-devs.github.io/jsplyr/reference/group_by.md)/[`summarise()`](https://r-world-devs.github.io/jsplyr/reference/summarise.md)
  machinery.
- Added
  [`relocate()`](https://r-world-devs.github.io/jsplyr/reference/relocate.md)
  to reorder columns using `.before`/`.after` placement, defaulting to
  moving the selected columns to the front.
- Added a [`print()`](https://rdrr.io/r/base/print.html) method for
  `tbl_lazy_json` that shows the JSON source, a lazy (not-yet-computed)
  status, and the pending pipeline rendered as `dplyr`-like calls.
  Mirrors `dbplyr`’s lazy `tbl` print, without retrieving data from the
  browser.

### Documentation:

- Added a
  [`vignette("collect-with-promises")`](https://r-world-devs.github.io/jsplyr/articles/collect-with-promises.md)
  covering how to handle
  [`collect()`](https://r-world-devs.github.io/jsplyr/reference/collect.md)
  promises inside
  [`reactive()`](https://rdrr.io/pkg/shiny/man/reactive.html),
  [`eventReactive()`](https://rdrr.io/pkg/shiny/man/observeEvent.html),
  [`observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
  and [`observe()`](https://rdrr.io/pkg/shiny/man/observe.html).
- Added example apps under `inst/example_apps/` showcasing `jsplyr`
  usage, including `app_showcase.R` and `app_update_select.R`.

### CI/CD:

- Added GitHub Actions workflows for linting
  ([`lintr::lint_package()`](https://lintr.r-lib.org/reference/lint.html)),
  a standalone `testthat` run for fast PR feedback, test coverage
  reporting via `covr` with Codecov upload, and a version-bump check
  that fails PRs which do not bump the `DESCRIPTION` `Version`.
- Added a `pkgdown` workflow that builds the documentation site and
  deploys it to GitHub Pages.
- Added R-CMD-check, Lint, Codecov, and CRAN downloads badges to the
  README.
