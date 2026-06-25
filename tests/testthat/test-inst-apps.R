library(shinytest2)

test_that("jsplyr works in shiny application", {
  skip_on_cran()
  skip_if_not(interactive())
  appdir <- system.file(package = "jsplyr", "test_app")
  test_app(appdir)
})

test_that("jsplyr group_by and summarise work in shiny application", {
  skip_on_cran()
  skip_if_not(interactive())
  appdir <- system.file(package = "jsplyr", "test_app_summarise")
  test_app(appdir)
})

test_that("jsplyr mutate works in shiny application", {
  skip_on_cran()
  skip_if_not(interactive())
  appdir <- system.file(package = "jsplyr", "test_app_mutate")
  test_app(appdir)
})

test_that("jsplyr distinct works in shiny application", {
  skip_on_cran()
  skip_if_not(interactive())
  appdir <- system.file(package = "jsplyr", "test_app_distinct")
  test_app(appdir)
})

test_that("jsplyr joins work in shiny application", {
  skip_on_cran()
  skip_if_not(interactive())
  appdir <- system.file(package = "jsplyr", "test_app_join")
  test_app(appdir)
})
