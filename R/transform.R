#' Apply functions to a list of data.frames
#'
#' This function provides an interface for applying functions to a named
#' list of data.frames.
#'
#' @param tables A named list of data.frames
#' @param trans Can be either a single function that will be applied to each
#' element of `tables` or a named list of functions. If the latter:
#' - Names should correspond to the names of `tables` to indicate the tables
#' the functions should be applied to
#' - If you supply an unnamed function, this will be applied to each table
#' that doesn't have a corresponding named function. You can think of this as
#' a 'default' transformation.
#'
#' @return A list of data.frames
transform_tables <- function(tables, trans) {

  # Optional early return
  if (length(trans) == 0)
    return(tables)

  notify("Applying transformations to the data")

  # Promote a bare function to a list
  if (is.function(trans))
    trans <- list(trans)

  if (!is.list(trans) || !all(vapply(trans, is.function, logical(1))))
    stop("`trans` should be a function or a named list of functions")

  if (is.null(names(trans)))
    names(trans) <- ""

  if (sum(names(trans) == "") > 1)
    stop("`trans` must have at most one unnamed element")

  # Get the 'specified' and default transformers
  specified <- trans[names(trans) != ""]
  default <- trans[names(trans) == ""] %or% list(identity)

  # Warn about any unmatched transformers
  unmatched <- !names(specified) %in% names(tables)
  if (any(unmatched)) {
    warning(sprintf(
      'Ignoring trans with no corresponding worksheet: "%s"',
      paste(names(specified)[unmatched], collapse = '", "')
    ))
  }

  # Get a final list of transformers to apply
  trans <- lapply(names(tables), function(n) {
    specified[[n]] %||% default[[1]]
  })
  names(trans) <- names(tables)

  cli::cli_ul()

  # Apply the transformers
  out <- lapply(names(tables), function(n) {
    tryCatch(
      {
        f <- trans[[n]]
        if (!identical(f, identity)) notify("Transforming %s", n, .type = "li")
        f(tables[[n]])
      },
      error = function(e) {
        stop(sprintf(
          "Could not apply transformer to table '%s':\n  %s", n, e$message
        ), call. = FALSE)
      }
    )
  })

  cli::cli_end()

  names(out) <- names(tables)

  out

}
