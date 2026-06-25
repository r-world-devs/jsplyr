test_that("tbl_lazy_json creates a 'tbl_lazy_json' object", {
  expect_s3_class(tbl_lazy_json, "tbl_lazy_json")
})

test_that("compute_steps are updated in the object", {
  tbl_lazy_json$compute_steps <- add_filter(
    .data = tbl_lazy_json,
    filter_expression = "age >= 30"
  )
  expect_equal(
    tbl_lazy_json$compute_steps,
    list(list(verb = "filter", params = list(expression = "age >= 30")))
  )

  tbl_lazy_json$compute_steps <- add_select(
    .data = tbl_lazy_json,
    columns = "name"
  )
  tbl_lazy_json$compute_steps <- add_distinct(
    .data = tbl_lazy_json
  )
  expect_equal(
    tbl_lazy_json$compute_steps,
    list(
      list(verb = "filter", params = list(expression = "age >= 30")),
      list(verb = "select", params = list(expression = "name")),
      list(verb = "distinct", params = list(expression = character(0)))
    )
  )

  expect_snapshot(
    print(tbl_lazy_json)
  )

  expect_snapshot(
    show_query(tbl_lazy_json)
  )
})

test_that("print shows source, lazy status and pipeline", {
  tbl <- tbl_lazy_json(
    mocked_session,
    "mtcars",
    compute_steps = list(
      compute_step(verb = "take", name = "mtcars")
    )
  )
  tbl$compute_steps <- add_filter(tbl, "item.mpg >= 20")
  tbl$compute_steps <- add_select(tbl, c("mpg", "cyl"))
  tbl$compute_steps <- add_distinct(tbl)
  expect_snapshot(
    print(tbl)
  )
})

test_that("print renders mutate, summarise and join steps", {
  tbl <- tbl_lazy_json(
    mocked_session,
    "mtcars",
    compute_steps = list(
      compute_step(verb = "take", name = "mtcars")
    )
  )
  tbl$compute_steps <- add_group_by(tbl, "cyl")
  tbl$compute_steps <- add_mutate(
    tbl,
    list(list(name = "double_mpg", expression = "item.mpg * 2"))
  )
  tbl$compute_steps <- add_summarise(
    tbl,
    list(list(name = "mean_mpg", fn = "mean", column = "mpg"))
  )
  expect_snapshot(
    print(tbl)
  )
})

test_that("format_compute_step renders join by clauses", {
  natural <- compute_step(
    verb = "join",
    type = "left",
    by = list(x = character(0), y = character(0)),
    y_steps = list()
  )
  expect_equal(format_compute_step(natural), "left_join(by = <natural>)")

  same_key <- compute_step(
    verb = "join",
    type = "inner",
    by = list(x = "id", y = "id"),
    y_steps = list()
  )
  expect_equal(format_compute_step(same_key), "inner_join(by = \"id\")")

  renamed_key <- compute_step(
    verb = "join",
    type = "full",
    by = list(x = "a", y = "b"),
    y_steps = list()
  )
  expect_equal(format_compute_step(renamed_key), "full_join(by = \"a\" = \"b\")")
})

test_that("group_by adds compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_group_by(tbl, "city")
  expect_equal(
    tbl$compute_steps,
    list(list(verb = "group_by", params = list(expression = "city")))
  )
})

test_that("group_by with multiple columns adds compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_group_by(tbl, c("city", "age"))
  expect_equal(
    tbl$compute_steps,
    list(list(verb = "group_by", params = list(expression = c("city", "age"))))
  )
})

test_that("summarise adds compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_group_by(tbl, "city")
  tbl$compute_steps <- add_summarise(
    tbl,
    list(list(name = "mean_age", fn = "mean", column = "age"))
  )
  expect_equal(
    tbl$compute_steps,
    list(
      list(verb = "group_by", params = list(expression = "city")),
      list(verb = "summarise", params = list(
        expressions = list(list(name = "mean_age", fn = "mean", column = "age"))
      ))
    )
  )
})

test_that("mutate adds compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_mutate(
    tbl,
    list(list(name = "double_age", expression = "age * 2"))
  )
  expect_equal(
    tbl$compute_steps,
    list(list(verb = "mutate", params = list(
      expressions = list(list(name = "double_age", expression = "age * 2"))
    )))
  )
})

test_that("mutate with multiple expressions adds compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_mutate(
    tbl,
    list(
      list(name = "double_age", expression = "age * 2"),
      list(name = "age_plus_one", expression = "age + 1")
    )
  )
  expect_equal(
    tbl$compute_steps,
    list(list(verb = "mutate", params = list(
      expressions = list(
        list(name = "double_age", expression = "age * 2"),
        list(name = "age_plus_one", expression = "age + 1")
      )
    )))
  )
})

test_that("distinct with columns adds compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_distinct(tbl, "name")
  expect_equal(
    tbl$compute_steps,
    list(list(verb = "distinct", params = list(expression = "name")))
  )
})

test_that("distinct with multiple columns adds compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_distinct(tbl, c("name", "city"))
  expect_equal(
    tbl$compute_steps,
    list(list(verb = "distinct", params = list(expression = c("name", "city"))))
  )
})

test_that("distinct without columns adds compute step", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_distinct(tbl)
  expect_equal(
    tbl$compute_steps,
    list(list(verb = "distinct", params = list(expression = character(0))))
  )
})

test_that("collect() returns a promise", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  result <- tbl |> dplyr::collect()
  expect_true(promises::is.promise(result))
})

test_that("collect() piped through %...>% returns a promise", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  result <- tbl |>
    dplyr::collect() %...>%
    head(10)
  expect_true(promises::is.promise(result))
})

test_that("group_by and summarise show_query output", {
  tbl <- tbl_lazy_json(mocked_session, "test data")
  tbl$compute_steps <- add_group_by(tbl, c("city", "am"))
  tbl$compute_steps <- add_summarise(
    tbl,
    list(
      list(name = "mean_age", fn = "mean", column = "age"),
      list(name = "count", fn = "n", column = "")
    )
  )
  expect_snapshot(
    show_query(tbl)
  )
})
