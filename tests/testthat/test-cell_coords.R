test_that("cell_coords() works", {

  data <- data.frame(
    x = c(letters[1:9], "!"),
    y = NA,
    z = c(1:3, NA_character_, "!", 6:10)
  )

  expect_equal(cell_coords(head(data), "!"), list(cols = 3, rows = 5))
  expect_equal(cell_coords(data, "!"), list(cols = c(1, 3), rows = c(10, 5)))
  expect_equal(cell_coords(data, "?"), list(cols = NA_integer_, rows = NA_integer_))

})
