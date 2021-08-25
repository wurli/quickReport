default_template <- openxlsx::loadWorkbook(
  "templates/default-template.xlsx"
)

usethis::use_data(default_template, overwrite = TRUE, internal = TRUE)
