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
cd "D:/2025-2028 UoM PhD Economics/2025-2026 Course work/Research Reading/Coding"

* Set Globals
global raw     "data/raw"
global clean   "data/clean"
global code    "code"
global tables  "output/tables"
global figures "output/figures"

display "Project environment is successfully set up!"