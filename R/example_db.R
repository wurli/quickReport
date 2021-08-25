
#' Create an example SQLite database
#'
#' This function creates an SQLite database in memory containing 3 base
#' datasets: `mtcars`, `beaver1` and `C02`.
#'
#' @return A connection
#' @export
example_db <- function() {

  if (!requireNamespace("DBI", quietly = TRUE)) {
    stop("Package 'DBI' must be installed")
  }

  if(!requireNamespace("RSQLite", quietly = TRUE)) {
    stop("Package 'RSQLite' must be installed")
  }

  # Create an SQLite database in memory
  db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")

  # Add 3 base datasets to the database
  for (dataset in c("mtcars", "beaver1", "CO2")) {
    DBI::dbWriteTable(db, dataset, as.data.frame(get(dataset)))
  }

  db
}
