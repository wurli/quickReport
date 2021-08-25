
<!-- README.md is generated from README.Rmd. Please edit that file -->

# quickReport

<!-- badges: start -->
<!-- badges: end -->

{quickReport} provides a set of functions that enable you to painlessly
create a single Excel workbook containing multiple datasets from the
comfort of your R session. The datasets you use can either be a list of
`data.frame`s, or alternatively the data can be read using a directory
containing SQL scripts. See `vignette("report_example")` for an example
of a start-to-finish report.

## Templates

You can provide an Excel template for a report using the `file_template`
argument in `report_from_sql()` or `report_from_data()`. By default, the
first worksheet will be used as the coversheet template while the second
will be used as the template for each sheet containing data. By default,
data will be placed at cell C5, but you can specify a different cell by
entering ‘!data’ at the desired location in the template. See
`vignette("templates")` for more information.

## Transformers

You may wish to apply some adjustments to your data before writing to
Excel. Both `report_from_sql()` and `report_from_data()` have a
`transformers` argument which allows you to pass a list of functions
which can be applied to the data in different worksheets before writing
the file.

## Projects

{quickReport} provides a function `create_report()` which can be used to
quickly set up a new report in its own R project. I recommend setting up
reports using `create_report()` function because this will gently guide
you towards a clean, standardised way of creating reports with a
sensible folder structure (e.g., all reports end up in an `Outputs`
folder at the top level of the project).

# Installation

You can install the development version of {quickReport} from
[github](https://github.com/wurli/quickReport) using

``` r
remotes::install_github("wurli/quickReport")
```

# Why quickReport?

You may ask, why use Excel if you have R? The answer is that life isn’t
fair, and sometimes you just have to. But you can reduce the time spent
in Excel by using {quickReport}.

# Credit

{quickReport} relies almost entirely on the wonderful package
[{openxlsx}](https://ycphs.github.io/openxlsx/). If you’re looking for a
more flexible way of manipulating Excel files from R, I highly recommend
this package.
