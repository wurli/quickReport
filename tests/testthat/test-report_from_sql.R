test_that("report_from_sql() works", {

  db <- example_db()

  queries <- list(
    "Miles per Gallon by Weight.sql" = "
      select mpg, wt from mtcars
    ",
    "Active Beavers.sql" = "
      select * from beaver1 where activ = 1
    ",
    "Mean C02 Uptake.sql" = "
      select Plant, Treatment, avg(uptake) as uptake
      from CO2
      group by Plant, Treatment
    "
  )

  dir <- file.path(tempdir(), "report_from_sql_test")
  dir.create(dir, showWarnings = FALSE)

  for (q in names(queries)) {
    readr::write_file(queries[[q]], file.path(dir, q))
  }

  wb <- report_from_sql(
    sql_directory = dir, sql_connection = example_db(),
    save_on_complete = FALSE, file_template = NULL
  )

  sheets <- names(wb)

  lapply(sheets, function(s) {
    expect_snapshot_value(openxlsx::readWorkbook(wb, s))
  })

})
