#' Create a project for a new report
#'
#' This function works very similarly to `usethis::create_project()`, but sets
#' up the project to generate an Excel report using {quickReport}
#'
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @param excel_files,r_files,sql_files Optional directories containing
#'   pre-existing files to use in the report
#' @param rstudio If `TRUE`, calls `use_rstudio()` to make the new package or
#'   project into an RStudio Project. If FALSE and a non-package project, a
#'   sentinel .here file is placed so that the directory can be recognized as a
#'   project by the here or rprojroot packages.
#' @param open If `TRUE`, activates the new project:
#'   - If RStudio desktop, the package is opened in a new session.
#'   - If on RStudio server, the current RStudio project is activated.
#'   - Otherwise, the working directory and active project is changed.
#'
#' @return Path to the newly created project or package, invisibly.
#' @export
create_report <- function(path,
                          excel_files = getOption("qr.default_template"),
                          r_files = NULL,
                          sql_files = NULL,
                          rstudio = rstudioapi::isAvailable(),
                          open = interactive()) {

  if (!requireNamespace("usethis")) {
    stop("Package `usethis` must be installed")
  }

  proj <- usethis::create_project(path, rstudio, open = FALSE)
  usethis::local_project(proj, force = TRUE)

  # Create extra directories in the new project
  lapply(c("Excel", "SQL", "Outputs"), usethis::use_directory, ignore = TRUE)

  # If supplied, copy over any pre-existing files to use in the project
  for (field in c("Excel", "R", "SQL")) {
    files <- get(paste0(tolower(field), "_files"))
    if (!is.null(files)) {
      usethis::ui_done("Adding files to {usethis::ui_path(field)}")
      file.copy(files, field, overwrite = TRUE)
    }
  }

  # Add a 'run-report.R' script to the top level of the project
  main_script <- c(
    "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
    "# * Run this file to customise your report",
    "# * Edit config.yml to configure a database",
    "# * Edit Excel/template.xlsx to customise your report",
    "# * Run `vignette('making-reports', 'quickReport')` for more info",
    "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
    "",
    "# load {quickReport}",
    "library(quickReport)",
    "",
    "# Run the report",
    "report_from_sql(",
    '  filename = nice_filename(dir = "Outputs"),',
    '  file_template = "Excel/template.xlsx",',
    '  coversheet_content = list(C5 = default_info_table()),',
    ")"
  )
  usethis::ui_done("Creating {usethis::ui_path('run-report.R')}")
  writeLines(main_script, "run-report.R")

  # Add a 'config.yml' file to the top level of the project
  config <- c(
    'default:',
    '  database:',
    '    driver: "Name of SQL driver"',
    '    server: "Name of server"',
    '    database: "Name of database"',
    '    uid: "Username"',
    '    pwd: "Password"',
    '    trusted: "yes/no"'
  )
  usethis::ui_done("Creating {usethis::ui_path('config.yml')}")
  writeLines(config, "config.yml")

  # Add an Excel template for easy configuration
  if (!"template.xlsx" %in% list.files("Excel")) {

    usethis::ui_done("Creating {usethis::ui_path('Excel/template.xlsx')}")
    tryCatch(
      openxlsx::saveWorkbook(
        default_template, "Excel/template.xlsx", overwrite = FALSE
      ),
      error = function(e) {
        warning("Could not create Excel template: ", e$message, call. = FALSE)
      }
    )

  }

  # Add an informative message to the .Rprofile
  rprofile <- c(
    'cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")',
    'cat("This project generates an Excel report using {quickReport}.\n")',
    'cat("Open \\"run-report.R\\" to get started :)\n")',
    'cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")'
  )
  usethis::ui_done("Creating {usethis::ui_path('.Rprofile')}")
  writeLines(rprofile, ".Rprofile")

  if (open) {
    if (usethis::proj_activate(usethis::proj_get())) {
      withr::deferred_clear()
    }
  }

  invisible(proj)

}
