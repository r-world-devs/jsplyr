generate_id <- function() {
  paste0(sample(c(0:9, letters, LETTERS), 30, replace = TRUE), collapse = "")
}
