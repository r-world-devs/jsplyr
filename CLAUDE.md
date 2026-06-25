# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is jsplyr?

jsplyr is a Shiny package that moves data manipulation from the R server to the browser. It implements dplyr's lazy evaluation pattern (like dbplyr) but instead of generating SQL, it generates JavaScript operations that execute client-side on JSON data.

**The analogy**: dbplyr is to databases as jsplyr is to the browser.

## Development Commands

```bash
# Run all tests
devtools::test()

# Run a single test file (regex matches after stripping test- prefix and .R extension)
devtools::test(filter = "dots_to_query")
devtools::test(filter = "tbl-lazy-json")

# Load package for interactive use
pkgload::load_all()

# Generate docs (roxygen2 → man/, NAMESPACE)
devtools::document()

# Full R CMD check
devtools::check()

# Lint
lintr::lint_package()
```

Interactive Shiny test apps (shinytest2) are skipped in non-interactive sessions. Run them manually with `devtools::test(filter = "inst-apps")` in an interactive R session.

## Architecture

### Data Flow

```
R Server                          Browser (JavaScript)
────────                          ────────────────────
copy_to(session, df)  ──msg──►   jsonData[state_id] = [...]
     │
filter/select/mutate  (lazy: just appends to compute_steps list)
     │
compute()             ──msg──►   computeLazyJSON() executes steps sequentially
     │                              │
     │  ◄──HTTP POST──────────────  result JSON
     │
  promise resolves
     │
collect()  →  tibble
```

### Key Design Decisions

- **Lazy evaluation**: dplyr verbs (filter, select, etc.) don't execute — they append `compute_step()` entries to a list on `tbl_lazy_json`. Execution happens only on `compute()`.
- **Promise-based collect**: `compute()` creates a one-shot HTTP endpoint via `session$registerDataObj()`, sends steps to JS, and returns a promise. JS POSTs results back, resolving the promise. `collect()` extracts the value from this promise.
- **Expression translation**: R expressions are parsed into JavaScript strings. Column references get `item.` prefixed (e.g., `age > 30` → `item.age > 30`). `ifelse()` calls are translated to ternary operators.
- **State tracking**: Each `tbl_lazy_json` has a `state_id` (random 30-char string) used to key data in the browser's global `jsonData` object.

### R-side Structure

- `tbl-lazy-json.R` — Core `tbl_lazy_json` S3 class: holds `session`, `state_id`, `compute_steps`, and `.promise`
- `dots_to_query.R` — Expression parsing: converts R expressions (quosures) to JS-compatible strings for filter/select/mutate/summarise
- `verb-*.R` — Each dplyr verb implementation appends a compute step
- `verb-compute.R` — Sends accumulated steps to JS via `session$sendCustomMessage`, registers HTTP callback
- `verb-collect.R` — Resolves the promise from compute, converts JSON to tibble

### JS-side Structure (`inst/www/`)

- `compute.js` — Orchestrator: iterates compute steps, dispatches to verb handlers, POSTs result back
- `filter.js`, `select.js`, `distinct.js`, `mutate.js`, `group_by.js`, `summarise.js` — Individual verb implementations
- `copy_to.js` — Stores data in global `jsonData` object (from R dataframe or existing JS variable)

### Two Data Sources

1. **R dataframe** → serialized to JSON via jsonlite, sent to browser via Shiny message
2. **Existing JS variable** → referenced by name (zero-copy), just registered in `jsonData`

## Linting

Uses lintr with 120-char line length, 45-char object names, `inst/` excluded. See `.lintr`.

## Testing

- testthat 3 edition with snapshot tests
- `tests/testthat/setup.R` creates a `MockShinySession` for unit testing without a browser
- Expression parsing (`dots_to_query`) and lazy step accumulation are tested in R
- Full Shiny app integration tests via shinytest2 in `inst/test_app*/`
