test_that("reordering by name works", {

  lttrs <- function(x) setNames(x, letters[x])

  expect_equal(reorder_by_name(lttrs(1:9), lttrs(9:1)), as.list(lttrs(9:1)))
  expect_equal(reorder_by_name(1:3, 1:3), as.list(1:3))
  expect_equal(suppressWarnings(reorder_by_name(lttrs(1:3), letters[3:1])), as.list(lttrs(1:3)))

  expect_warning(reorder_by_name(lttrs(1:3), letters[3:1]), '`x` has names but not `y`. Returning unordered `x`')
  expect_error(reorder_by_name(lttrs(1:5), lttrs(2:6)), '`x` has names not in `y`: "a"')
  expect_error(reorder_by_name(list(a = 1, a = 2, b = 3), lttrs(1:3)), "`x` has non-unique names")

})
