test_that("count() groups then summarises with n()", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl <- dplyr::count(tbl, cyl)
  verbs <- purrr::map_chr(tbl$compute_steps, "verb")
  expect_equal(verbs, c("group_by", "summarise"))

  group_step <- tbl$compute_steps[[1]]
  expect_equal(group_step$params$expression, "cyl")

  summary_step <- tbl$compute_steps[[2]]
  expect_equal(
    summary_step$params$expressions,
    list(list(name = "n", fn = "n", column = ""))
  )
})

test_that("count() honours name and sort", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl <- dplyr::count(tbl, cyl, name = "freq", sort = TRUE)
  verbs <- purrr::map_chr(tbl$compute_steps, "verb")
  expect_equal(verbs, c("group_by", "summarise", "arrange"))

  summary_step <- tbl$compute_steps[[2]]
  expect_equal(summary_step$params$expressions[[1]]$name, "freq")

  arrange_step <- tbl$compute_steps[[3]]
  expect_equal(
    arrange_step$params$keys,
    list(list(column = "freq", direction = "desc"))
  )
})

test_that("tally() counts the existing grouping", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_group_by(tbl, "cyl")
  tbl <- dplyr::tally(tbl)
  verbs <- purrr::map_chr(tbl$compute_steps, "verb")
  expect_equal(verbs, c("group_by", "summarise"))
  expect_equal(
    tbl$compute_steps[[2]]$params$expressions,
    list(list(name = "n", fn = "n", column = ""))
  )
})
