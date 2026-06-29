test_that("dots_to_arrange_query parses ascending and descending keys", {
  expect_equal(
    dots_to_arrange_query(cyl, dplyr::desc(mpg)),
    list(
      list(column = "cyl", direction = "asc"),
      list(column = "mpg", direction = "desc")
    )
  )
})

test_that("dots_to_arrange_query parses character inputs", {
  expect_equal(
    dots_to_arrange_query("cyl", "desc(mpg)"),
    list(
      list(column = "cyl", direction = "asc"),
      list(column = "mpg", direction = "desc")
    )
  )
  expect_equal(
    dots_to_arrange_query("-mpg"),
    list(list(column = "mpg", direction = "desc"))
  )
})

test_that("arrange adds a compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl <- dplyr::arrange(tbl, cyl, dplyr::desc(mpg))
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(step$verb, "arrange")
  expect_equal(
    step$params$keys,
    list(
      list(column = "cyl", direction = "asc"),
      list(column = "mpg", direction = "desc")
    )
  )
})

test_that("arrange step prints as a dplyr-like call", {
  tbl <- tbl_lazy_json(
    mocked_session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )
  tbl <- dplyr::arrange(tbl, cyl, dplyr::desc(mpg))
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(format_compute_step(step), "arrange(cyl, desc(mpg))")
})
