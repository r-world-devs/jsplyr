library(shinytest2)

app <- AppDriver$new(name = "app", height = 911, width = 1619)

test_that("distinct by city returns unique cities", {
  app$click("run_by_city")
  result_json <- app$get_value(output = "result_by_city")
  result <- jsonlite::fromJSON(result_json)

  # The dataset has 8 unique cities out of 30 rows
  expect_equal(nrow(result), 8)
  expect_equal(length(unique(result$city)), nrow(result))
  # All original columns are preserved
  expect_true(all(c("name", "age", "city", "department") %in% names(result)))
})

test_that("distinct by city keeps first occurrence", {
  result_json <- app$get_value(output = "result_by_city")
  result <- jsonlite::fromJSON(result_json)

  # First New York row is Alice (age 25), not Eve or Ivan
  ny_row <- result[result$city == "New York", ]
  expect_equal(nrow(ny_row), 1)
  expect_equal(ny_row$name, "Alice")

  # First Phoenix row is Frank (age 45), not Heidi or Mallory
  phoenix_row <- result[result$city == "Phoenix", ]
  expect_equal(nrow(phoenix_row), 1)
  expect_equal(phoenix_row$name, "Frank")
})

test_that("distinct all returns all rows when no duplicates exist", {
  app$click("run_all")
  result_json <- app$get_value(output = "result_all")
  result <- jsonlite::fromJSON(result_json)

  # All 30 rows are unique across all columns
  expect_equal(nrow(result), 30)
})
