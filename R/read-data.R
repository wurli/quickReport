#' Connect to a database
#'
#' This function attempts to generate a connection using `DBI::dbConnect()`. By
#' default, options are taken from a `config.yml` file which should contain
#' fields for
#' - driver
#' - server
#' - database
#' - uid (username)
#' - pwd (password)
#' - trusted (usually 'yes')
#'
#' @param conf List of config opts
#'
#' @return A connection
connect_to_database <- function(conf = config::get("database")) {

  if (!requireNamespace("odbc", quietly = TRUE)) {
    stop("Package 'odbc' is not installed")
  }

  required_fields <- c("driver", "server", "database", "uid", "pwd", "trusted")

  if (!all(required_fields %in% names(conf))) {
    stop(sprintf(
      'Missing fields in database specification. Fields must include "%s"',
      paste(required_fields, collapse = '", "')
    ))
  }

  # connect to db using the connection
  conn <- DBI::dbConnect(
    odbc::odbc(),
    Driver             = conf$driver,
    Server             = conf$server,
    Database           = conf$database,
    UID                = conf$uid,
    PWD                = conf$pwd,
    Trusted_Connection = conf$trusted
  )

  # return the connection
  conn

}

#' Read data using SQL scripts
#'
#' @param scripts A list of character vectors containing SQL
#' @param con A connection to an SQL database
#'
#' @return A named list of data.frames
collect_data <- function(scripts, con = connect_to_database()) {

  notify(
    "Reading %d datasets from %s",
    length(scripts), attr(con, "dbname") %or% "database"
  )

  cli::cli_ul()

  datasets <- lapply(names(scripts), function(name) {
    notify("Reading %s", name, .type = "li")
    DBI::dbGetQuery(con, scripts[[name]])
  })

  cli::cli_end()

  names(datasets) <- names(scripts)

  if (requireNamespace("tibble", quietly = TRUE)) {
    datasets <- lapply(datasets, tibble::as_tibble)
  }

  datasets

}

