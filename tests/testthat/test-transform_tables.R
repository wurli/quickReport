test_that("transform_tables() works", {

  tbls <- list(
    m = mtcars, b1 = beaver1, b2 = beaver2
  )

  funs <- list(
    function(t) head(t, 3),
    m = function(t) t[grepl("^[abc]", names(t))],
    b1 = function(t) head(t, 10),
    z = function(t) t + 1,
    b2 = function(t) stop("fake error!")
  )

  e <- function(funs, x) expect_equal(transform_tables(tbls, funs), x)
  w <- function(funs, x) expect_warning(transform_tables(tbls, funs), x)
  f <- function(funs, x) expect_error(transform_tables(tbls, funs), x)

  e(NULL, tbls)
  e(funs[[1]], lapply(tbls, funs[[1]]))
  e(funs[2:3], list(m = funs$m(tbls$m), b1 = funs$b1(tbls$b1), b2 = tbls$b2))

  w(funs[1:4], 'Ignoring trans with no corresponding worksheet: "z"')

  f("dog", "`trans` should be a function or a named list of functions")
  f(funs[-4], "Could not apply transformer to table 'b2':\n  fake error!")

})
