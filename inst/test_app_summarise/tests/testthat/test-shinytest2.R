library(shinytest2)

app <- AppDriver$new(name = "app", height = 911, width = 1619)

test_that("group_by and summarise with mean works correctly", {
  app$set_inputs(group_by = "city", wait_ = FALSE)
  app$set_inputs(summary_fn = "mean", wait_ = FALSE)
  app$click("run_btn")
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  # 8 unique cities in the dataset
  expect_equal(nrow(result), 8)
  expect_true("city" %in% names(result))
  expect_true("result" %in% names(result))
  expect_true("count" %in% names(result))

  # New York has 6 people: Alice (25), Eve (28), Ivan (50), Olivia (29), Wendy (26), Chloe (29)
  ny <- result[result$city == "New York", ]
  expect_equal(ny$count, 6)
  expect_equal(ny$result, mean(c(25, 28, 50, 29, 26, 29)))
})

test_that("switching summary function to sum works", {
  Sys.sleep(1)
  app$set_inputs(summary_fn = "sum", wait_ = FALSE)
  app$click("run_btn")
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  # Chicago has David (40), Judy (22), Quinn (27), Xander (39) -> sum = 128
  chi <- result[result$city == "Chicago", ]
  expect_equal(chi$count, 4)
  expect_equal(chi$result, 128)
})

test_that("switching summary function to min works", {
  Sys.sleep(1)
  app$set_inputs(summary_fn = "min", wait_ = FALSE)
  app$click("run_btn")
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  # Phoenix has Frank (45), Heidi (38), Mallory (37), Victor (48), Brian (46) -> min = 37
  phx <- result[result$city == "Phoenix", ]
  expect_equal(phx$count, 5)
  expect_equal(phx$result, 37)
})

test_that("switching summary function to max works", {
  Sys.sleep(1)
  app$set_inputs(summary_fn = "max", wait_ = FALSE)
  app$click("run_btn")
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  # Los Angeles has Charlie (35), Nathan (42), Tina (24), Zach (44) -> max = 44
  la <- result[result$city == "Los Angeles", ]
  expect_equal(la$count, 4)
  expect_equal(la$result, 44)
})

test_that("switching summary function to median works", {
  Sys.sleep(1)
  app$set_inputs(summary_fn = "median", wait_ = FALSE)
  app$click("run_btn")
  result_json <- app$get_value(output = "result_json")
  result <- jsonlite::fromJSON(result_json)

  # New York: 25, 26, 28, 29, 29, 50 -> median = (28 + 29) / 2 = 28.5
  ny <- result[result$city == "New York", ]
  expect_equal(ny$count, 6)
  expect_equal(ny$result, 28.5)
})
