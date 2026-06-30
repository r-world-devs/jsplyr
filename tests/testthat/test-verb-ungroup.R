test_that("ungroup() with no args records an empty columns list", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl <- dplyr::ungroup(tbl)
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(step$verb, "ungroup")
  expect_equal(step$params$columns, list())
})

test_that("ungroup() records named columns for partial ungroup", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  bare_step <- dplyr::ungroup(tbl, cyl)$compute_steps |>
    (\(s) s[[length(s)]])()
  expect_equal(bare_step$params$columns, list("cyl"))

  string_step <- dplyr::ungroup(tbl, "cyl")$compute_steps |>
    (\(s) s[[length(s)]])()
  expect_equal(string_step$params$columns, list("cyl"))

  multi_step <- dplyr::ungroup(tbl, cyl, gear)$compute_steps |>
    (\(s) s[[length(s)]])()
  expect_equal(multi_step$params$columns, list("cyl", "gear"))
})

test_that("group_by() |> ungroup() produces the expected step sequence", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl <- tbl |>
    dplyr::group_by(cyl) |>
    dplyr::ungroup()
  verbs <- purrr::map_chr(tbl$compute_steps, "verb")
  expect_equal(verbs, c("group_by", "ungroup"))
})

test_that("ungroup steps print as dplyr-like calls", {
  tbl <- tbl_lazy_json(
    mocked_session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )
  full <- dplyr::ungroup(tbl)$compute_steps |>
    (\(s) s[[length(s)]])()
  expect_equal(format_compute_step(full), "ungroup()")

  partial <- dplyr::ungroup(tbl, cyl, gear)$compute_steps |>
    (\(s) s[[length(s)]])()
  expect_equal(format_compute_step(partial), "ungroup(cyl, gear)")
})
