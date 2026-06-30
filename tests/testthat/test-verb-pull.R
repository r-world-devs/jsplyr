test_that("pull_var_spec resolves names, strings and positions", {
  expect_equal(
    pull_var_spec(rlang::quo(mpg)),
    list(by = "name", value = "mpg")
  )
  expect_equal(
    pull_var_spec(rlang::quo("mpg")),
    list(by = "name", value = "mpg")
  )
  expect_equal(
    pull_var_spec(rlang::quo(1)),
    list(by = "index", value = 1L)
  )
  expect_equal(
    pull_var_spec(rlang::quo(-1)),
    list(by = "index", value = -1L)
  )
})

test_that("add_pull appends a pull compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_pull(tbl, list(by = "name", value = "mpg"))
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(step$verb, "pull")
  expect_equal(step$params$by, "name")
  expect_equal(step$params$value, "mpg")
})

test_that("pull() returns a promise", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  result <- dplyr::pull(tbl, mpg)
  expect_true(promises::is.promise(result))
})

test_that("pull step prints as a dplyr-like call", {
  tbl <- tbl_lazy_json(
    mocked_session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )
  tbl$compute_steps <- add_pull(tbl, list(by = "name", value = "mpg"))
  step <- tbl$compute_steps[[length(tbl$compute_steps)]]
  expect_equal(format_compute_step(step), "pull(mpg)")
})
