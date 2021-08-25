library(purrr)
library(dplyr)


# Create an SQLite database in memory
con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")

# Add 3 base datasets to the database
for (dataset in c("mtcars", "beaver1", "CO2")) {
  DBI::dbWriteTable(con, dataset, as.data.frame(get(dataset)))
}

# 3 basic SQL queries are given names that will be used to name Excel worksheets
queries <- list(
  "Miles per Gallon by Weight" = "select mpg, wt from mtcars",
  "Active Beavers"             = "select * from beaver1 where activ = 1",
  "Mean C02 Uptake"            = "select Plant, Treatment, avg(uptake) as uptake
                                  from CO2
                                  group by Plant, Treatment"
)

# Create a test directory containing the SQL scripts
dir <- file.path(tempdir(), "SQL")
dir.create(dir)

invisible(imap(queries, function(query, file) {

  filename <- paste0(file, ".sql")
  readr::write_file(query, file.path(dir, filename))

}))

list.files(dir)

report_from_sql(
  filename = nice_filename(replace = TRUE, dir = "."),
  file_template = "templates/test-template.xlsx",
  sql_directory = dir,
  sql_connection = con,
  transformers = list(
    `Active Beavers` = function(data) {
      data %>%
        as_tibble() %>%
        mutate(
          date = lubridate::as_date("1990-01-01") + lubridate::days(day),
          date = format(date, "%Y-%b-%m"),
          time = sprintf("%04.f", time),
          datetime = paste(date, time),
          datetime = readr::parse_datetime(datetime, "%Y-%b-%m %H%M")
        ) %>%
        select(-day, -time)
    }
  )
)


# DBI::dbDisconnect(con)
