test_that("relocate() records columns and default placement", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl <- dplyr::relocate(tbl, gear, carb)
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(step$verb, "relocate")
  expect_equal(step$params$columns, list("gear", "carb"))
  expect_null(step$params$before)
  expect_null(step$params$after)
})

test_that("relocate() records .before and .after anchors", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  before_step <- dplyr::relocate(tbl, mpg, .before = cyl)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(before_step$params$before, "cyl")
  expect_null(before_step$params$after)

  after_step <- dplyr::relocate(tbl, mpg, .after = cyl)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(after_step$params$after, "cyl")
  expect_null(after_step$params$before)
})

test_that("relocate() rejects both .before and .after", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  expect_error(
    dplyr::relocate(tbl, mpg, .before = cyl, .after = gear),
    "only one"
  )
})

test_that("relocate steps print as dplyr-like calls", {
  tbl <- tbl_lazy_json(
    mocked_session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )
  plain <- dplyr::relocate(tbl, gear, carb)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(format_compute_step(plain), "relocate(gear, carb)")

  after <- dplyr::relocate(tbl, mpg, .after = cyl)$compute_steps |> (\(s) s[[length(s)]])()
  expect_equal(format_compute_step(after), "relocate(mpg, .after = cyl)")
})
