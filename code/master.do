cls
* ==========================================================
* Project: UoM Research Reading
* Author: Youngwoo
* Description: Master do-file to run the entire analysis
* ==========================================================

clear all
set more off
capture log close

* please change the path to "E:" if I work my personal laptop
global project "D:/2025-2028 UoM PhD Economics/2025-2026 Course work/Research Reading/Coding"

global raw     "$project/data/raw"
global clean   "$project/data/clean"
global code    "$project/code"
global tables  "$project/output/tables"
global figures "$project/output/figures"

cd "$project"

* 실행 순서 (파일 이름이 실제와 같은지 확인하세요)
do "$code/0Setting.do"
    display "Setting.do completed successfully!"
do "$code/1Tuition_Grant.do"
    display "Tuition_Grant.do completed successfully!"
do "$code/1DataSummary.do"
    display "DataSummary.do completed successfully!"
do "$code/2Regression_RobustRDD.do"
    display "Regression_RobustRDD.do completed successfully!"

display "All do-files executed successfully!"