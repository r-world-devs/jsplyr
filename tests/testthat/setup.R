test_lazy_json <- "test data"

mocked_session <- shiny::MockShinySession$new()

tbl_lazy_json <- tbl_lazy_json(mocked_session, test_lazy_json)
