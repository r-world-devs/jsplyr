library(shinytest2)

app <- AppDriver$new(name = "app", height = 911, width = 1619)

test_that("filter verbs work correctly", {
  app$set_inputs(filter_expression = "age >= 25")
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  filtered_data <- jsonlite::fromJSON(manipulated_json)
  expect_true(all(filtered_data$age >= 25))
  
  Sys.sleep(1)

  app$set_inputs(filter_expression = "age >= 40")
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  filtered_data <- jsonlite::fromJSON(manipulated_json)
  expect_true(all(filtered_data$age >= 40))
  
  Sys.sleep(1)
  
  app$set_inputs(filter_expression = "city == 'Chicago'")
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  filtered_data <- jsonlite::fromJSON(manipulated_json)
  expect_true(all(filtered_data$city == "Chicago"))
  
  Sys.sleep(1)
  
  app$set_inputs(filter_expression = "city == 'New York' & age > 25")
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  filtered_data <- jsonlite::fromJSON(manipulated_json)
  expect_true(all(filtered_data$age > 25) & all(filtered_data$city == "New York"))

  app$set_inputs(filter_expression = "city == 'New York', age > 25")
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  filtered_data <- jsonlite::fromJSON(manipulated_json)
  expect_true(all(filtered_data$age > 25) & all(filtered_data$city == "New York"))

  Sys.sleep(1)

  app$set_inputs(filter_expression = "between(age, 30, 40)")
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  filtered_data <- jsonlite::fromJSON(manipulated_json)
  expect_true(all(filtered_data$age >= 30 & filtered_data$age <= 40))

  Sys.sleep(1)

  app$set_inputs(filter_expression = "!is.na(city) & between(age, 35, 45)")
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  filtered_data <- jsonlite::fromJSON(manipulated_json)
  expect_true(all(filtered_data$age >= 35 & filtered_data$age <= 45))
  expect_true(all(!is.na(filtered_data$city)))
})

test_that("select verbs work correctly", {
  Sys.sleep(1)
  app$set_inputs(select_expression = "name")
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  selected_data <- jsonlite::fromJSON(manipulated_json)
  expect_length(selected_data, 1)
  expect_true(all(names(selected_data) == "name"))
  
  Sys.sleep(1)
  app$set_inputs(select_expression = c("city", "age"))
  app$click("run_btn")
  manipulated_json <- app$get_value(output = "manipulated_json")
  selected_data <- jsonlite::fromJSON(manipulated_json)
  expect_length(selected_data, 2)
  expect_true(all(names(selected_data) == c("city", "age")))
})