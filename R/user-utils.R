#' Create a pretty table of information
#'
#' These functions help you create a readable table of information, intended to
#' be used to populate a coversheet in an Excel report.
#'
#' @param data_included The names of the data sheets included in the report
#' @param data_exported_by The name of the reporter
#' @param exported_on The date of the report
#' @param ... Named vectors. The names give the single value that will appear in
#'   the left-hand column, while the values will appear on separate rows in the
#'   right-hand column.
#' @param .pretty_names If `TRUE` then some standardisation is performed on the
#'   values in the left-hand column. This includes the capitalisation of the
#'   first letter and the replacement of underscores with spaces.
#'
#' @return A `data.frame`
#' @export
#'
#' @examples
#' info_table(
#'   first_category = letters[1:3],
#'   second_category = "d"
#' )
#'
#' default_info_table(
#'   data_included = c("Blackberry", "Apple", "Orange"),
#'   author = "Jacob"
#' )
info_table <- function(..., .pretty_names = TRUE) {

  entries <- list(...)
  names <- names(entries)

  if (.pretty_names) {
    names <- gsub("_", " ", names)
    substr(names, 1, 1) <- toupper(substr(names, 1, 1))
  }

  names_col <- as.list(seq_along(entries))

  for (i in seq_along(entries)) {
    names_col[[i]] <- c(
      names[[i]], rep(NA_character_, length(entries[[i]]) - 1)
    )
  }

  out <- data.frame(category = unlist(names_col), values = unlist(entries))

  if (requireNamespace("tibble", quietly = TRUE)) {
    out <- tibble::as_tibble(out)
  }

  out

}


#' @rdname info_table
#' @export
default_info_table <- function(data_included = "",
                               data_exported_by = get_user(),
                               exported_on = strftime(Sys.time(), "%Y-%m-%d"),
                               .pretty_names = TRUE,
                               ...) {
  info_table(
    data_included = data_included,
    data_exported_by = data_exported_by,
    exported_on = exported_on,
    .pretty_names = .pretty_names,
    ...
  )
}


#' Get the current user
#'
#' This function gets the name of the current user, which is used to set the
#' 'Creator' and 'Last Modified By' fields when running `report_from_sql()` or
#' `report_from_data()`
#'
#' If a `default` is not set this function gets the username from
#' - `Sys.getenv("USERNAME")` if on windows
#' - `Sys.getenv("USER")` otherwise
#' - If neither are found the `"Unknown"` is returned.
#'
#' @param default A default which can be set using `options()`
#'
#' @return A character vector of length 1
#' @export
get_user <- function(default = getOption("qr.user")) {
  out <- default %or% ifelse(
    .Platform$OS.type == "windows",
    Sys.getenv("USERNAME"),
    Sys.getenv("USER")
  )

  if (identical(out, "")) "Unknown" else out
}


#' Helper for reading an entire .xlsx file
#'
#' @param wb A filepath or `openxlsx` workbook object
#' @param ... Passed to `openxlsx::readWorkbook()`
#'
#' @return A list of data.frames
#' @export
read_worksheets <- function(wb, ...) {
  
  
  if (is.character(wb)) {
    wb <- openxlsx::loadWorkbook(wb, )
  }
  
  sheets <- names(wb)
  content <- lapply(sheets, openxlsx::readWorkbook, xlsxFile = wb, ...)
  names(content) <- sheets
  
  content
}

