test_that("process_by handles NULL as a natural join", {
  expect_equal(
    process_by(NULL),
    list(x = character(0), y = character(0))
  )
})

test_that("process_by handles unnamed character vectors", {
  expect_equal(
    process_by("id"),
    list(x = "id", y = "id")
  )
  expect_equal(
    process_by(c("id", "city")),
    list(x = c("id", "city"), y = c("id", "city"))
  )
})

test_that("process_by handles named vectors for differing key names", {
  expect_equal(
    process_by(c("a" = "b")),
    list(x = "a", y = "b")
  )
  expect_equal(
    process_by(c("id", "a" = "b")),
    list(x = c("id", "a"), y = c("id", "b"))
  )
})

test_that("left_join adds a compute step", {
  x <- tbl_lazy_json(mocked_session, "left data")
  y <- tbl_lazy_json(mocked_session, "right data")
  y$compute_steps <- list(compute_step(verb = "take", name = "right data"))

  out <- dplyr::left_join(x, y, by = "id")

  expect_equal(
    out$compute_steps,
    list(list(verb = "join", params = list(
      type = "left",
      by = list(x = "id", y = "id"),
      y_steps = list(list(verb = "take", params = list(name = "right data")))
    )))
  )
})

test_that("join verbs set the correct type", {
  x <- tbl_lazy_json(mocked_session, "left data")
  y <- tbl_lazy_json(mocked_session, "right data")

  types <- list(
    left = dplyr::left_join,
    right = dplyr::right_join,
    inner = dplyr::inner_join,
    full = dplyr::full_join,
    semi = dplyr::semi_join,
    anti = dplyr::anti_join
  )

  purrr::iwalk(types, function(join_fn, type) {
    out <- join_fn(x, y, by = "id")
    last_step <- out$compute_steps[[length(out$compute_steps)]]
    expect_equal(last_step$verb, "join")
    expect_equal(last_step$params$type, type)
  })
})

test_that("join with named by carries both key sides", {
  x <- tbl_lazy_json(mocked_session, "left data")
  y <- tbl_lazy_json(mocked_session, "right data")

  out <- dplyr::inner_join(x, y, by = c("left_id" = "right_id"))
  last_step <- out$compute_steps[[length(out$compute_steps)]]

  expect_equal(last_step$params$by, list(x = "left_id", y = "right_id"))
})

test_that("natural join (by = NULL) records empty keys", {
  x <- tbl_lazy_json(mocked_session, "left data")
  y <- tbl_lazy_json(mocked_session, "right data")

  out <- dplyr::full_join(x, y)
  last_step <- out$compute_steps[[length(out$compute_steps)]]

  expect_equal(last_step$params$by, list(x = character(0), y = character(0)))
})

test_that("join rejects a non tbl_lazy_json right-hand side", {
  x <- tbl_lazy_json(mocked_session, "left data")
  expect_error(
    dplyr::left_join(x, data.frame(id = 1)),
    "tbl_lazy_json"
  )
})

test_that("join preserves earlier compute steps", {
  x <- tbl_lazy_json(mocked_session, "left data")
  x$compute_steps <- add_filter(x, "age >= 30")
  y <- tbl_lazy_json(mocked_session, "right data")

  out <- dplyr::left_join(x, y, by = "id")

  expect_equal(out$compute_steps[[1]]$verb, "filter")
  expect_equal(out$compute_steps[[2]]$verb, "join")
})
