# jsplyr 0.1.0

Initial CRAN release.

## Core interface:
* Added a `dplyr` interface for manipulating data in JavaScript with `tbl()`, `copy_to()`, `collect()`, `compute()`, and `show_query()`.
* Added a promise-based `collect()` decoupled from `shiny`'s reactive input system. `compute()` uses `session$registerDataObj()` to create a session-scoped HTTP callback; the JS side `POST`s the result to it, resolving a promise. `collect()` does not require a reactive context.
* Embedded `compute()` within `collect()` so it runs automatically when not called earlier in the pipeline.
* Re-exported the promise pipe operators `%...>%`, `%...!%`, and `%...T>%` from `promises`, so `collect()` results can be consumed in reactive contexts without attaching `promises`.

## Verbs:
* Added `filter()`, `select()`, and `distinct()` verbs.
* Added the `mutate()` verb for adding or modifying columns using expressions. Supports both non-standard evaluation and character string inputs.
* Added `ifelse()` support in `mutate()` expressions, translated to JavaScript ternary operators. Nested `ifelse()` calls are supported.
* Added `if_else()` as an alias for `ifelse()` in `mutate()` expressions; both translate to JavaScript ternary operators.
* Added `case_when()` support in `mutate()` expressions, translated to chained JavaScript ternary operators. Clauses without a `TRUE ~ ...` catch-all yield `null` for unmatched rows, matching `dplyr`'s `NA` default.
* Added `group_by()` and `summarise()` verbs with support for `mean()`, `sum()`, `min()`, `max()`, `n()`, `sd()`, and `median()` aggregation functions.
* Added join verbs `left_join()`, `right_join()`, `inner_join()`, `full_join()`, `semi_join()`, and `anti_join()`. Joining two `tbl_lazy_json` tables is performed in the browser. Supports `by` as a natural join (default), a shared key, or a named vector for differing key names. Colliding non-key columns get `.x`/`.y` suffixes.
* Added `is.na()`, `between()`, and `across()`/`if_all()`/`if_any()` support in `filter()` expressions. `is.na()` and `between()` are translated to JavaScript on the browser side, while `across()`/`if_all()`/`if_any()` are expanded over the selected columns (combined with `&` for `across()`/`if_all()` and `|` for `if_any()`). Column selections accept `c(...)`, a bare column, a character vector, and `all_of()`/`any_of()`.
* Added `across()` support to `mutate()` and `summarise()`, and `all_of()`/`any_of()`/`across()` column resolution to `group_by()`. `across()` is expanded on the R side over the selected columns and accepts a single function, a formula lambda (`~ .x * 2`), or a named list of functions, with optional `.names` glue (`{.col}`/`{.fn}`). `if_any()`/`if_all()` remain `filter()`-only.
* Added column-name support to `distinct()` for determining uniqueness. When columns are specified, only the first row per unique combination is kept. When no columns are given, all columns are used.
* Added a `print()` method for `tbl_lazy_json` that shows the JSON source, a lazy (not-yet-computed) status, and the pending pipeline rendered as `dplyr`-like calls. Mirrors `dbplyr`'s lazy `tbl` print, without retrieving data from the browser.

## Documentation:
* Added a `vignette("collect-with-promises")` covering how to handle `collect()` promises inside `reactive()`, `eventReactive()`, `observeEvent()` and `observe()`.

## CI/CD:
* Added GitHub Actions workflows for linting (`lintr::lint_package()`), a standalone `testthat` run for fast PR feedback, test coverage reporting via `covr` with Codecov upload, and a version-bump check that fails PRs which do not bump the `DESCRIPTION` `Version`.
* Added R-CMD-check, Lint, Codecov, and CRAN downloads badges to the README.
