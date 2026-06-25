mock_session_env <- new.env()
mock_session_env$input <- list(
  "filter_age" = 30L,
  "city" = "New York"
)
mocked_data <- list(
  session = mock_session_env
)

mock_env <- new.env()
mock_env$vals <- list(filter_age = 30)
mock_env$city_data <- "Chicago"
mock_env$cols <- c("a", "b")

test_that("dots_to_filter_query works as expected", {
  expect_equal(
    dots_to_filter_query(mocked_data, age > input$filter_age),
    "age > 30"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, city == input$city),
    "city == 'New York'"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, "age > 30"),
    "age > 30"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, "city == 'New York'"),
    "city == 'New York'"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, city == "Chicago"),
    "city == 'Chicago'"
  )
  
  expect_equal(
    dots_to_filter_query(mocked_data, age > vals$filter_age, .env = mock_env),
    "age > 30"
  )
  
  expect_equal(
    dots_to_filter_query(mocked_data, city == city_data, .env = mock_env),
    "city == 'Chicago'"
  )
})

test_that("dots_to_filter_query works with multiple expressions", {
  expect_equal(
    dots_to_filter_query(mocked_data, city == "San Francisco" & age > input$filter_age),
    "city == 'San Francisco' & age > 30"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, age > input$filter_age, city == input$city),
    "age > 30, city == 'New York'"
  )
})

test_that("dots_to_filter_query handles is.na()", {
  expect_equal(
    dots_to_filter_query(mocked_data, is.na(age)),
    "is.na(age)"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, !is.na(age)),
    "!is.na(age)"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, age > input$filter_age & is.na(city)),
    "age > 30 & is.na(city)"
  )
})

test_that("dots_to_filter_query handles between()", {
  expect_equal(
    dots_to_filter_query(mocked_data, between(age, 20, 40)),
    "between(age, 20, 40)"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, between(age, vals$filter_age, 40), .env = mock_env),
    "between(age, 30, 40)"
  )
})

test_that("dots_to_filter_query expands across()/if_all()/if_any()", {
  expect_equal(
    dots_to_filter_query(mocked_data, if_all(c(age, height), ~ .x > 0)),
    "(age > 0 & height > 0)"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, if_any(c(age, height), ~ .x > 0)),
    "(age > 0 | height > 0)"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, across(c(age, city), ~ !is.na(.x))),
    "(!is.na(age) & !is.na(city))"
  )
})

test_that("dots_to_filter_query resolves across() columns from all_of()", {
  expect_equal(
    dots_to_filter_query(
      mocked_data,
      if_all(dplyr::all_of(cols), ~ .x > 0),
      .env = mock_env
    ),
    "(a > 0 & b > 0)"
  )
})

test_that("dots_to_filter_query keeps existing comparison behaviour", {
  expect_equal(
    dots_to_filter_query(mocked_data, age > input$filter_age),
    "age > 30"
  )
  expect_equal(
    dots_to_filter_query(mocked_data, "is.na(age)"),
    "is.na(age)"
  )
})

test_that("dots_to_mutate_query expands across() with a formula", {
  result <- dots_to_mutate_query(across(c(age, height), ~ .x * 2))
  expect_equal(result, list(
    list(name = "age", expression = "age * 2"),
    list(name = "height", expression = "height * 2")
  ))
})

test_that("dots_to_mutate_query expands across() with a bare function", {
  result <- dots_to_mutate_query(across(c(age, height), round))
  expect_equal(result, list(
    list(name = "age", expression = "round(age)"),
    list(name = "height", expression = "round(height)")
  ))
})

test_that("dots_to_mutate_query expands across() with a named list of fns", {
  result <- dots_to_mutate_query(
    across(c(age), list(double = ~ .x * 2, plus1 = ~ .x + 1))
  )
  expect_equal(result, list(
    list(name = "age_double", expression = "age * 2"),
    list(name = "age_plus1", expression = "age + 1")
  ))
})

test_that("dots_to_mutate_query honours across() .names glue", {
  result <- dots_to_mutate_query(
    across(c(age, height), ~ .x * 2, .names = "{.col}_x2")
  )
  expect_equal(result, list(
    list(name = "age_x2", expression = "age * 2"),
    list(name = "height_x2", expression = "height * 2")
  ))
})

test_that("dots_to_mutate_query resolves across() columns from all_of()", {
  cols <- c("age", "height")
  result <- dots_to_mutate_query(across(dplyr::all_of(cols), ~ .x + 1))
  expect_equal(result, list(
    list(name = "age", expression = "age + 1"),
    list(name = "height", expression = "height + 1")
  ))
})

test_that("dots_to_mutate_query mixes across() with plain expressions", {
  result <- dots_to_mutate_query(
    double_age = age * 2,
    across(c(height), ~ .x + 1)
  )
  expect_equal(result, list(
    list(name = "double_age", expression = "age * 2"),
    list(name = "height", expression = "height + 1")
  ))
})

test_that("dots_to_summarise_query expands across() with a single fn", {
  result <- dots_to_summarise_query(across(c(age, height), mean))
  expect_equal(result, list(
    list(fn = "mean", column = "age", name = "age"),
    list(fn = "mean", column = "height", name = "height")
  ))
})

test_that("dots_to_summarise_query expands across() with a named list of fns", {
  result <- dots_to_summarise_query(
    across(c(age), list(mean = mean, sd = sd))
  )
  expect_equal(result, list(
    list(fn = "mean", column = "age", name = "age_mean"),
    list(fn = "sd", column = "age", name = "age_sd")
  ))
})

test_that("dots_to_summarise_query honours across() .names glue", {
  result <- dots_to_summarise_query(
    across(c(age, height), mean, .names = "avg_{.col}")
  )
  expect_equal(result, list(
    list(fn = "mean", column = "age", name = "avg_age"),
    list(fn = "mean", column = "height", name = "avg_height")
  ))
})

test_that("dots_to_summarise_query mixes across() with plain expressions", {
  result <- dots_to_summarise_query(
    count = n(),
    across(c(age), mean)
  )
  expect_equal(result, list(
    list(fn = "n", column = "", name = "count"),
    list(fn = "mean", column = "age", name = "age")
  ))
})

test_that("dots_to_group_by_query resolves c() and all_of()/any_of()", {
  cols <- c("am", "vs")
  expect_equal(dots_to_group_by_query(c(am, vs)), c("am", "vs"))
  expect_equal(
    dots_to_group_by_query(dplyr::all_of(cols), .env = environment()),
    c("am", "vs")
  )
  expect_equal(
    dots_to_group_by_query(dplyr::any_of(cols), .env = environment()),
    c("am", "vs")
  )
})

test_that("dots_to_group_by_query resolves across()", {
  expect_equal(
    dots_to_group_by_query(across(c(am, vs))),
    c("am", "vs")
  )
})

test_that("dots_to_group_by_query keeps bare column behaviour", {
  expect_equal(dots_to_group_by_query(am, vs), c("am", "vs"))
  expect_equal(dots_to_group_by_query("cyl"), "cyl")
})

test_that("dots_to_select_query works as expected", {
  expect_equal(dots_to_select_query(age), "age")
  expect_equal(dots_to_select_query("city"), "city")

  expect_equal(dots_to_select_query(am, vs), c("am", "vs"))
})

test_that("dots_to_summarise_query parses single expression", {
  result <- dots_to_summarise_query(mean_age = mean(age))
  expect_equal(result, list(
    list(fn = "mean", column = "age", name = "mean_age")
  ))
})

test_that("dots_to_summarise_query parses n()", {
  result <- dots_to_summarise_query(count = n())
  expect_equal(result, list(
    list(fn = "n", column = "", name = "count")
  ))
})

test_that("dots_to_summarise_query parses multiple expressions", {
  result <- dots_to_summarise_query(
    mean_age = mean(age),
    max_age = max(age),
    count = n()
  )
  expect_equal(result, list(
    list(fn = "mean", column = "age", name = "mean_age"),
    list(fn = "max", column = "age", name = "max_age"),
    list(fn = "n", column = "", name = "count")
  ))
})

test_that("dots_to_summarise_query parses character strings", {
  result <- dots_to_summarise_query("mean_age = mean(age)")
  expect_equal(result, list(
    list(name = "mean_age", fn = "mean", column = "age")
  ))
})

test_that("dots_to_summarise_query parses multiple character strings", {
  result <- dots_to_summarise_query(
    "result = mean(mpg)",
    "count = n()"
  )
  expect_equal(result, list(
    list(name = "result", fn = "mean", column = "mpg"),
    list(name = "count", fn = "n", column = "")
  ))
})

test_that("dots_to_mutate_query parses single expression", {
  result <- dots_to_mutate_query(double_age = age * 2)
  expect_equal(result, list(
    list(name = "double_age", expression = "age * 2")
  ))
})

test_that("dots_to_mutate_query parses multiple expressions", {
  result <- dots_to_mutate_query(
    double_age = age * 2,
    age_plus_one = age + 1
  )
  expect_equal(result, list(
    list(name = "double_age", expression = "age * 2"),
    list(name = "age_plus_one", expression = "age + 1")
  ))
})

test_that("dots_to_mutate_query parses character strings", {
  result <- dots_to_mutate_query("double_age = age * 2")
  expect_equal(result, list(
    list(name = "double_age", expression = "age * 2")
  ))
})

test_that("dots_to_mutate_query parses multiple character strings", {
  result <- dots_to_mutate_query(
    "double_age = age * 2",
    "name_upper = name"
  )
  expect_equal(result, list(
    list(name = "double_age", expression = "age * 2"),
    list(name = "name_upper", expression = "name")
  ))
})
