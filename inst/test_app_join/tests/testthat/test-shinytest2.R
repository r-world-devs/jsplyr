library(shinytest2)

app <- AppDriver$new(name = "app", height = 911, width = 1619)

test_that("left_join keeps all left rows and adds right columns", {
  app$click("run_btn")
  result <- jsonlite::fromJSON(app$get_value(output = "result_left"))

  expect_equal(nrow(result), 4)
  expect_true(all(c("name", "dept_id", "dept_name") %in% names(result)))

  # David has dept_id 99 with no match -> dept_name is NA.
  david <- result[result$name == "David", ]
  expect_true(is.na(david$dept_name))

  alice <- result[result$name == "Alice", ]
  expect_equal(alice$dept_name, "Engineering")
})

test_that("inner_join keeps only matching rows", {
  result <- jsonlite::fromJSON(app$get_value(output = "result_inner"))

  expect_equal(nrow(result), 3)
  expect_false("David" %in% result$name)
  expect_setequal(result$name, c("Alice", "Bob", "Charlie"))
})

test_that("full_join keeps unmatched rows from both sides", {
  result <- jsonlite::fromJSON(app$get_value(output = "result_full"))

  # 4 employees + Sales (dept 3) with no employee = 5 rows.
  expect_equal(nrow(result), 5)
  expect_true("Sales" %in% result$dept_name)

  sales <- result[!is.na(result$dept_name) & result$dept_name == "Sales", ]
  expect_true(is.na(sales$name))
})

test_that("semi_join keeps matching left rows without right columns", {
  result <- jsonlite::fromJSON(app$get_value(output = "result_semi"))

  expect_equal(nrow(result), 3)
  expect_false("dept_name" %in% names(result))
  expect_setequal(result$name, c("Alice", "Bob", "Charlie"))
})

test_that("anti_join keeps only non-matching left rows", {
  result <- jsonlite::fromJSON(app$get_value(output = "result_anti"))

  expect_equal(nrow(result), 1)
  expect_equal(result$name, "David")
  expect_false("dept_name" %in% names(result))
})
