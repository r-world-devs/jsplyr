test_that("dots_to_rename_query parses bare and string inputs", {
  expect_equal(
    dots_to_rename_query(new_mpg = mpg, cylinders = cyl),
    list(
      list(new = "new_mpg", old = "mpg"),
      list(new = "cylinders", old = "cyl")
    )
  )
  expect_equal(
    dots_to_rename_query("new_mpg" = "mpg"),
    list(list(new = "new_mpg", old = "mpg"))
  )
})

test_that("rename requires named arguments", {
  expect_error(dots_to_rename_query(mpg), "must be named")
})

test_that("rename adds a compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl <- dplyr::rename(tbl, new_mpg = mpg)
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(step$verb, "rename")
  expect_equal(step$params$pairs, list(list(new = "new_mpg", old = "mpg")))
})

test_that("rename step prints as a dplyr-like call", {
  tbl <- tbl_lazy_json(
    mocked_session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )
  tbl <- dplyr::rename(tbl, new_mpg = mpg, cylinders = cyl)
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(format_compute_step(step), "rename(new_mpg = mpg, cylinders = cyl)")
})
