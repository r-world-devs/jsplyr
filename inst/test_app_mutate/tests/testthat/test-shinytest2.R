library(shinytest2)

app <- AppDriver$new(name = "app", height = 911, width = 1619)

test_that("mutate preserves original columns and adds new ones", {
  app$click("run_btn")
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  expect_true(all(c("name", "age", "city", "department") %in% names(result)))
  expect_true(all(
    c("age_doubled", "age_plus_ten", "senior", "senior_strict", "age_band") %in% names(result)
  ))
  expect_equal(nrow(result), 30)
})

test_that("arithmetic mutate expressions produce correct values", {
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  expect_equal(result$age_doubled, result$age * 2)
  expect_equal(result$age_plus_ten, result$age + 10)
})

test_that("ifelse mutate expression produces correct labels", {
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  expected_senior <- ifelse(result$age >= 35, "yes", "no")
  expect_equal(result$senior, expected_senior)
})

test_that("if_else() is treated as an alias for ifelse()", {
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  expected_senior <- ifelse(result$age >= 35, "yes", "no")
  expect_equal(result$senior_strict, expected_senior)
})

test_that("case_when mutate expression produces correct labels", {
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  expected_band <- dplyr::case_when(
    result$age >= 45 ~ "senior",
    result$age >= 30 ~ "mid",
    TRUE ~ "junior"
  )
  expect_equal(result$age_band, expected_band)
})
