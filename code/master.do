* ==========================================================
* Project: UoM Research Reading (Robust Path Version)
* ==========================================================
clear all

local current_dir "`c(pwd)'"
if regexm("`current_dir'", "code$") {
    cd ".."
}

global project "`c(pwd)'"
display "Project Root: $project"

global raw     "$project/data/raw"
global clean   "$project/data/clean"
global code    "$project/code"
global tables  "$project/output/tables"
global figures "$project/output/figures"


foreach pkg in outreg2 rdrobust estout {
    capture which `pkg'
    if _rc ssc install `pkg', replace
}


do "$code/0Setting.do"
	display "0Setting.do completed successfully!"

do "$code/1Tuition_Grant.do"
	display "1Tuition_Grant.do completed successfully!"

do "$code/1DataSummary.do"
	display "1DataSummary.do completed successfully!"

do "$code/2Regression_RobustRDD.do"
	display "2Regression_RobustRDD.do completed successfully!"

display "All do-files executed successfully!"