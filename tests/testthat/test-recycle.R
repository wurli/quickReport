test_that("recycling works", {

  expect_equal(recycle(1, 1:3), list(1, 1, 1))
  expect_equal(recycle(1:3, 1:3), as.list(1:3))
  expect_error(recycle(1:3, 1), "Cannot recycle object of length 3 to length 1")
  expect_error(recycle(NULL, 1), "Cannot recycle object of length 0 to length 1")

})
