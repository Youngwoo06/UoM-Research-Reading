* ==========================================================
* Project: UoM Research Reading
* ==========================================================

clear all
set more off
capture log close

global project "`c(pwd)'"
    display "Current Project Path: $project"

global raw     "$project/data/raw"
global clean   "$project/data/clean"
global code    "$project/code"
global tables  "$project/output/tables"
global figures "$project/output/figures"

cd "$project"


do "$code/0Setting.do"
    display "0Setting.do completed successfully!"


do "$code/1Tuition_Grant.do"
    display "1Tuition_Grant.do completed successfully!"

do "$code/1DataSummary.do"
    display "1DataSummary.do completed successfully!"

do "$code/2Regression_RobustRDD.do"
    display "2Regression_RobustRDD.do completed successfully!"

display "All do-files executed successfully!"