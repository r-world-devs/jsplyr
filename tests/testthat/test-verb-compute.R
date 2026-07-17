# A fake session that captures what compute() registers, so we can drive the
# filterFunc by hand the way Shiny's request dispatch would. The MockShinySession
# stubs registerDataObj as a no-op, so it cannot exercise the endpoint callback.
fake_compute_session <- function() {
  downloads <- list()
  captured <- list()

  session <- list(
    # Mimics Shiny's Map$new() stored in session$downloads: registerDataObj
    # sets a handler here, and our fix must remove it after firing.
    downloads = list(
      set = function(name, value) downloads[[name]] <<- value,
      remove = function(name) downloads[[name]] <<- NULL,
      keys = function() names(downloads),
      size = function() length(downloads)
    ),
    registerDataObj = function(name, data, filterFunc) {
      # Record the handler exactly as Shiny would, then hand back a URL.
      session$downloads$set(name, list(data = data, filter = filterFunc))
      captured$name <<- name
      captured$data <<- data
      captured$filter <<- filterFunc
      paste0("session/token/dataobj/", name)
    },
    sendCustomMessage = function(type, message) invisible(NULL)
  )

  session$captured <- function() captured
  session$state_id <- "mtcars"
  session
}

# Build a POST request whose body is `text`, matching what the browser sends.
fake_post <- function(text) {
  raw_body <- charToRaw(text)
  list(rook.input = list(read = function(n) raw_body))
}

test_that("compute() endpoint deregisters itself after firing", {
  session <- fake_compute_session()
  tbl <- tbl_lazy_json(
    session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )

  computed <- dplyr::compute(tbl)
  cap <- session$captured()

  # Handler is registered up front, before any request comes in.
  expect_equal(session$downloads$size(), 1L)
  expect_true(grepl("^jsplyr_", cap$name))

  # Simulate the browser POSTing the result back to the endpoint.
  response <- cap$filter(cap$data, fake_post("[{\"mpg\":21}]"))

  expect_s3_class(response, "httpResponse")
  # The endpoint removed itself, so nothing leaks into session$downloads.
  expect_equal(session$downloads$size(), 0L)
})

test_that("many compute() calls do not accumulate endpoints", {
  session <- fake_compute_session()
  tbl <- tbl_lazy_json(
    session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )

  for (i in seq_len(5)) {
    computed <- dplyr::compute(tbl)
    cap <- session$captured()
    cap$filter(cap$data, fake_post("[]"))
  }

  expect_equal(session$downloads$size(), 0L)
})

test_that("compute() attaches a resolving promise", {
  session <- fake_compute_session()
  tbl <- tbl_lazy_json(
    session,
    "mtcars",
    compute_steps = list(compute_step(verb = "take", name = "mtcars"))
  )

  computed <- dplyr::compute(tbl)
  expect_true(promises::is.promise(computed$.promise))
})
