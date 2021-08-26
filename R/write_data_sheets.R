
#' Add datasheets to a Workbook
#'
#' @param wb A workbook object
#' @param datasets A list of datasets
#' @param default_data_sheet The worksheet to use as the default datasheet
#' template. Can be either the sheet name or number.
#' @param data_marker This value should be used in the datasheet template to
#'   indicate where the tables should be placed. This value will be the
#'   upper-left corner of the table.
#' @param remove_template Logical, whether the template sheet should be removed
#'   from the final report. Does not have an effect if `default_data_sheet`
#'   is `NULL`.
#'
#' @return An `openxlsx` workbook object
write_data_sheets <- function(wb, datasets,
                              default_data_sheet = 2,
                              data_marker = getOption(
                                "qr.marker", "!data"
                              ),
                              remove_template = TRUE) {

  notify("Writing %d datasets to workbook", length(datasets))

  sheets <- names(wb)
  
  if (length(default_data_sheet) == 0) {
    
    use_default <- FALSE
    
  } else {
    
    use_default <- TRUE
    
    default <- default_data_sheet
    if (length(default) > 1) {
      stop("`default_data_sheet` should be `NULL` or have length 1")
    }
    if (is.numeric(default)) {
      default <- sheets[default]
    }
    if (is.na(default_data_sheet) || !default %in% sheets) {
      notify(paste(
        "Sheet '%s' not found in template workbook, defaulting to blank",
        "template for data sheets"
        ), default_data_sheet, .type = "alert_warning"
      )
      use_default <- FALSE
    }
    
  }

  
  cli::cli_ul()

  for (d in names(datasets)) {

    notify("Writing %s", d, .type = "li")

    if (!d %in% sheets) {
      if (use_default) {
        openxlsx::cloneWorksheet(wb, d, default)
      } else {
        openxlsx::addWorksheet(wb, sheetName = d)
      }
    }

    # Read the original content of the top left cell
    first_cell_content <- suppressWarnings(openxlsx::readWorkbook(
      wb, sheet = d, rows = 1, cols = 1
    ))

    # Write some filler text to the top left cell so we can read in the whole
    # worksheet (otherwise it reads from the first nonempty cell)
    if (is.null(first_cell_content)) {
      openxlsx::writeData(
        wb, sheet = d, x = "filler", startCol = 1, startRow = 1
      )
    }

    # Read the worksheet content
    existing_content <- suppressWarnings(openxlsx::readWorkbook(
      wb, sheet = d, colNames = FALSE,
      skipEmptyRows = FALSE, skipEmptyCols = FALSE
    ))

    # Clear any filler text from the top left cell
    if (is.null(first_cell_content)) {
      openxlsx::writeData(
        wb, sheet = d, x = NA_character_, startCol = 1, startRow = 1
      )
    }

    xy <- cell_coords(existing_content, data_marker)

    if (length(xy$cols) > 1) {
      stop(sprintf(
        "Marker '%s' found at multiple locations: '%s'", data_marker,
        paste0(openxlsx::int2col(xy$cols), xy$rows, collapse = ", ")
      ))
    }

    if (is.na(xy$cols)) {
      xy <- list(cols = 3, rows = 5)
    }

    openxlsx::writeDataTable(
      wb, sheet = d, x = datasets[[d]], xy = unlist(xy, use.names = FALSE)
    )

  }

  cli::cli_end()

  if (use_default && remove_template) {
    openxlsx::removeWorksheet(wb, default)
  }

  wb

}

# Get the col number / row number of a cell
cell_coords <- function(data, value) {

  data <- as.list(data)
  names(data) <- NULL

  cols <- which(vapply(data, function(col) value %in% col, logical(1)))

  if (length(cols) == 0) return(list(cols = NA_integer_, rows = NA_integer_))

  rows <- vapply(cols, function(c) which(data[[c]] == value), integer(1))

  list(cols = cols, rows = rows)

}
