#' Generate a filename
#'
#' This is a helper function to quickly generate not-terrible filenames. This
#' will be of the form 'day created-author-description.xlsx'
#' Filenames are put in lower-case and spaces are replaced with dashes.
#'
#' @param name A brief description of the file
#' @param user The name of the creater of the file
#' @param time The time the file was created (i.e. `Sys.time()`)
#' @param ext The file extension
#' @param dir The directory to save the file to
#' @param replace If `FALSE` then filenames that already exist will have a number
#' appended to ensure that replacement doesn't occur.
#'
#' @return A character vector of length 1
#'
#' @export
#'
#' @examples
#' nice_filename("demo_file", user = "example")
nice_filename <- function(name = NULL,
                          user = Sys.info()[["user"]],
                          time = strftime(Sys.time(), "%Y-%m-%d"),
                          ext = ".xlsx",
                          dir = NULL,
                          replace = FALSE) {

  file <- paste(c(time, user, name), collapse = "-")
  file <- gsub(" ", "-", file)
  file <- tolower(paste0(file, ext))

  validate_filename(file, dir, replace)

}

#' Get a valid filepath
#'
#' @param filename The name of the file to check
#' @param dir The directory
#' @param replace If `TRUE` then the input is returned regardless of whether
#' the file exists
#' @param filepath Optionally supply the full filepath instead of `filename` and
#' `dir`
#'
#' @return A character string
validate_filename <- function(filename = nice_filename(),
                              dir = NULL,
                              replace = FALSE,
                              filepath = paste(c(dir, filename), collapse = "/")
                              ) {

  # If the file doesn't exist return the input
  if (!file.exists(filepath)) {
    return(filepath)
  }

  # If replace, then remove the file and return the input
  if (replace) {
    if (file.exists(filepath)) {
      notify(
        "Existing file %s will be replaced", filepath, .type = "alert_warning"
      )
    }
    return(filepath)
  }

  # Function that recursively adds a number to the original path
  # until a file, i.e. that doesn't exist yet, is found
  get_valid_path <- function(filepath, index = 1) {

    # Get the parts before and after the last '.' in the filepath
    name <- gsub("\\.[^\\.]+$", "", filepath)
    ext <- str_extract(filepath, "\\.[^\\.]+$") %or% ""

    # Add the new index
    try_path <- paste0(name, sprintf("_%02.f", index), ext)

    # Return the new path if file doesn't exist
    if (!file.exists(try_path)) {

      return(try_path)

      # Otherwise, increment index and repeat
    } else {

      get_valid_path(filepath, index + 1)

    }

  }

  filepath <- get_valid_path(filepath)

  notify(
    'File already exists. Using "%s"', str_extract(filepath, "[^\\/]+$"),
    .type = "alert_warning"
  )

  filepath

}
