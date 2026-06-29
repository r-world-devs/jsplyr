test_that("slice() records integer positions", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl <- dplyr::slice(tbl, 1, 3, 5)
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(step$verb, "slice")
  expect_equal(step$params$type, "slice")
  expect_equal(step$params$opts$positions, list(1L, 3L, 5L))
})

test_that("slice_head()/slice_tail() default to n = 1", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  head_step <- dplyr::slice_head(tbl)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(head_step$params$type, "slice_head")
  expect_equal(head_step$params$opts$n, 1L)

  tail_step <- dplyr::slice_tail(tbl, n = 3)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(tail_step$params$type, "slice_tail")
  expect_equal(tail_step$params$opts$n, 3)
})

test_that("slice_head() accepts prop", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  step <- dplyr::slice_head(tbl, prop = 0.5)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(step$params$opts$prop, 0.5)
  expect_null(step$params$opts$n)
})

test_that("slice_min()/slice_max() carry the ordering column", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  min_step <- dplyr::slice_min(tbl, age, n = 2)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(min_step$params$type, "slice_min")
  expect_equal(min_step$params$opts$column, "age")
  expect_equal(min_step$params$opts$n, 2)

  max_step <- dplyr::slice_max(tbl, age)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(max_step$params$type, "slice_max")
  expect_equal(max_step$params$opts$column, "age")
  expect_equal(max_step$params$opts$n, 1L)
})

test_that("slice() supplying both n and prop errors", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  expect_error(dplyr::slice_head(tbl, n = 1, prop = 0.5), "only one")
})

test_that("slice steps print as dplyr-like calls", {
  tbl <- tbl_lazy_json(
    mocked_session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )
  sliced <- dplyr::slice(tbl, 1, 2, 3)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(format_compute_step(sliced), "slice(1, 2, 3)")

  headed <- dplyr::slice_head(tbl, n = 5)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(format_compute_step(headed), "slice_head(n = 5)")

  maxed <- dplyr::slice_max(tbl, mpg, n = 2)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(format_compute_step(maxed), "slice_max(mpg, n = 2)")
})
