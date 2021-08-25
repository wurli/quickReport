`%||%` <- function(l, r) {
  if (is.null(l)) r else l
}

`%or%` <- function(l, r) {
  if (length(l) == 0) r else l
}

notify <- function(msg, ..., .type = "li",
                   quiet = getOption("qr.quiet", FALSE)) {

  cyan_bold <- function(x) sprintf("\033[1m\033[36m%s\033[39m\033[22m", x)

  msg <- gsub("(%[dfs])", cyan_bold("\\1"), msg)
  msg <- sprintf(msg, ...)

  fun <- utils::getFromNamespace(paste0("cli_", .type), ns = "cli")

  if (!quiet) fun(msg)

  invisible(msg)

}

# base implementation of stringr::str_extract
str_extract <- function(x, pattern, invert = FALSE) {
  regmatches(x, regexpr(pattern, x), invert)
}

pad <- function(x, pad, length_out) {
  x <- as.list(x)
  pad <- rep(list(pad), length_out - length(x))
  c(x, pad)
}

# Recycle any object to the length of another. The result is always a list
recycle <- function(x, y) {

  xlen <- length(x)
  ylen <- length(y)

  x <- if (length(x) == 1) list(x) else as.list(x)

  if (xlen == 1 && ylen > 1) {
    x <- rep(x, ylen)
  } else if (xlen != ylen) {
    stop(sprintf("Cannot recycle object of length %s to length %s", xlen, ylen))
  }

  x

}

# Reorder one named object based on the names of another.
# The result is always a list
reorder_by_name <- function(x, y, warn_unnamed_x = FALSE) {

  x <- as.list(x)
  y <- as.list(y)

  x <- recycle(x, y)

  xnam <- names(x)
  ynam <- names(y)

  if (is.null(xnam)) {
    if (warn_unnamed_x) warning("`x` is unnamed")
    return(x)
  }
  if (is.null(ynam)) {
    warning("`x` has names but not `y`. Returning unordered `x`", call. = FALSE)
    return(x)
  }
  if (length(unique(xnam)) != length(xnam)) {
    stop("`x` has non-unique names")
  }
  if (length(unique(ynam)) != length(ynam)) {
    stop("`y` has non-unique names")
  }
  if (!all(xnam %in% ynam)) {
    stop(sprintf(
      '`x` has names not in `y`: "%s"',
      paste(xnam[!xnam %in% ynam], collapse = '", "')
    ))
  }

  new_order <- vapply(
    xnam, function(n) which(ynam == n) %or% NA_integer_, integer(1)
  )
  x <- x[new_order]

  x

}

# lapply but vectorised over `x` and `fun`
lapply1 <- function(x, fun, ...) {

  fun <- recycle(fun, x)

  out <- vector("list", length(x))

  for (i in seq_along(out)) {
    out[[i]] <- fun[[i]](x[[i]], ...)
  }

  out

}

# Similar to purrr::map2
lapply2 <- function(x, y, fun, ...) {

  x <- recycle(x, y)
  fun <- recycle(fun, y)

  out <- vector("list", length(x))

  for (i in seq_along(out)) {
    out[[i]] <- fun[[i]](x[[i]], y[[i]], ...)
  }

  out

}

# Turn a vector of Excel cell references, e.g. AZ34, into a list containing two
# vectors, 'rows' giving the row numbers and 'cols' giving the col numbers
parse_cellref <- function(x) {

  x <- toupper(x)
  matches <- grepl("^[A-Z]+\\d+$", x)

  if (!all(matches)) {
    stop(sprintf(
      'Invalid cell reference(s) "%s"',
      paste(x[!matches], collapse = '", "')
    ))
  }

  letters <- str_extract(x, "^[A-Z]+")

  # Turns a vector of strings into a vector of column numbers using Excel
  # column-naming syntax, i.e. A->1, B->2, ..., AA->27, AB-> 28, ...
  cols <- vapply(strsplit(letters, ""), function(lttrs) {

    lttrs <- rev(lttrs)
    indices <- vapply(lttrs, function(l) which(LETTERS == l), integer(1))
    indices <- indices * 26 ^ (seq_along(lttrs) - 1)
    as.integer(sum(indices))

  }, integer(1))

  rows <- as.integer(str_extract(x, "\\d+$"))

  list(rows = rows, cols = cols)

}
