check_sql_scripts <- function(script) {

  if (length(script > 1)) {
    return(lapply(script, check_sql_scripts))
  }

  lines <- strsplit(script, "\n")[[1]]

  if (any(grepl("^(|.*;) *use *", script, ignore.case = TRUE))) {
    stop(
      "`USE` statements should not be used. Please specify ",
      "the database using `connect_to_database()`"
    )
  }

  # ... Can add more checks here in future maybe

  script

}

#' Read the SQL scripts in the SQL directory
#'
#' @param dir The SQL directory
#' @param engine Function used to read the scripts
#'
#' @return A list of character vectors
read_sql_scripts <- function(dir = "SQL", engine = readr::read_file) {

  notify("Reading SQL scripts from %s", dir)

  file_paths <- list.files(dir, full.names = TRUE)
  file_names <- list.files(dir)
  files_are_sql <- grepl("\\.sql$", file_paths)

  if (!all(files_are_sql)) {
    warning(sprintf(
      'Ignoring %d non-SQL files found in SQL directory: "%s"',
      sum(!files_are_sql), paste(file_names[!files_are_sql], collapse = '", "')
    ))
  }

  sql_files <- file_paths[files_are_sql]
  names(sql_files) <- gsub("\\.sql$", "", file_names[files_are_sql])

  # List the filenames
  out <- lapply(sql_files, engine)

  out

}
