cls
//-------------------------Data Summary--------------------------------------//
clear all

if "$project" == "" {
    global project "`c(pwd)'"
    global clean   "$project/data/clean"
    global output  "$project/output"
}

use "$clean/DataGOSM.dta", clear

//1.Main Dependent Variables
	/*Timely Graduation*/
	count if leave_school == . | leave_school == -1 | leave_sem == . | leave_sem == -1
	count if GPAZ == .
	sort gender
	by gender : sum leave_school leave_sem GPAZ
	foreach var in leave_school leave_sem GPAZ {
		ttest `var', by(gender)
	}
	
	/*Academic Performance*/
	count if GPA_raw == . | GPA_raw == -1 | GPA_standard == . | GPA_standard == -1
	count if GPAZ == .
	sum GPA_percent GPAZ if GPA_raw != -1 & GPA_standard != -1

sum adjleave_school adjleave_sem GPAZ
by gender : sum adjleave_school adjleave_sem
//-----------------------------------------------------------------//

//2. Independent Variables & Treatment Assignments
/*Scholarship*/
	/*Based on Entrance Year*/		
	graph bar (mean) scholarship if inrange(enter_year, 2008, 2018), ///
		over(enter_year) ///
		bar(1, color(navy)) 
	graph export "$output/figures/Scholarship_receipt_by_entrance_year.png", replace	
		
	/*New Standard for scholarship receipt*/	
	gen new_scholarshipstandard = 0
	replace new_scholarshipstandard = 1 if scholarship_percent >= 100
		graph bar (mean) new_scholarshipstandard ///
			if inrange(enter_year, 2008, 2018) & collection >= 2011, over(enter_year) ///
			bar(1, color(navy)) ///
			title("Mean Scholarship Receipt Rate by Entrance Year. 100%")	
			
	replace new_scholarshipstandard = 0		
	replace new_scholarshipstandard = 1 if scholarship_percent >= 50			
		graph bar (mean) new_scholarshipstandard ///
			if inrange(enter_year, 2008, 2018) & collection >= 2011, over(enter_year) ///
			bar(1, color(navy)) ///
			title("Mean Scholarship Receipt Rate by Entrance Year. 50%")				
		
/*Eligibility*/
	* Treatment eligibility: 2011 group (parent_income = 3)
	gen treat_2011_12 = (enter_year > 2007) & (enter_year < 2012) & (parent_income < 3)	
	* Treatment eligibility: 2012 group (parent_income = 3)
	gen treat_2012_3 = (enter_year >= 2012) & (parent_income <= 3)	
	* Treatment eligibility: 2013+ group (parent_income between 4 and 6)
	gen treat_2013plus_456 = (enter_year >= 2013) & (parent_income <= 6)
	* Treatment eligibility: 2015+ group (parent_income = 7)
	gen treat_2015plus_7 = (enter_year >= 2015) & (parent_income <= 7)		

	gen eligible = (treat_2011_12) | (treat_2012_3) | (treat_2013plus_456) | (treat_2015plus_7)

	* Step 1: Keep only 2008–2018
	keep if inrange(enter_year, 2008, 2018)

	* Step 2: Collapse to get means and standard errors
	collapse (mean) eligible (sem) se_eligible=eligible, by(enter_year)

	* Step 3: Calculate CI bounds
	gen upper = eligible + 1.96*se_eligible
	gen lower = eligible - 1.96*se_eligible

	* Step 4: Plot
	twoway (bar eligible enter_year, barwidth(0.6) color(navy)), ///
		xline(2012) ///
		text(1.05 2012 "KNSP implemented")
	graph export "$output/figures/KNSP_Eligibility.png", replace
		
	graph bar (mean) eligible ///
		if inrange(enter_year, 2008, 2018), ///
		over(enter_year) ///
		bar(1, color(navy))
				
		
// Treatment Assignments Continuity Test
/* Parental Income Real Wage based */
clear all
    
* [확인] CPI 파일이 data/raw 폴더 안에 있어야 합니다.
import excel "$raw/CPI1965-2019.xlsx", sheet("Sheet1") firstrow clear
    rename year enter_year
    
* [임시 저장] 가공 중인 데이터는 clean 폴더로 보냅니다.
save "$clean/CPI_temp.dta", replace

use "$clean/DataGOSM.dta", clear
    
    merge m:1 enter_year using "$clean/CPI_temp.dta"
    
    tab _merge
    
    * (선택사항) 병합에 실패한 데이터(_merge != 3)가 있다면 여기서 조치하거나 
    * 성공한 데이터만 남기고 싶다면: keep if _merge == 3
    * drop _merge
	
	gen income_mid = .
	replace income_mid = 0.5 if parent_income == 1
	replace income_mid = 1.5 if parent_income == 2
	replace income_mid = 2.5 if parent_income == 3
	replace income_mid = 3.5 if parent_income == 4
	replace income_mid = 4.5 if parent_income == 5
	replace income_mid = 6 if parent_income == 6
	replace income_mid = 8.5 if parent_income == 7
	replace income_mid = 30 if parent_income == 8
	
	gen real_income_mid = income_mid / (CPI / 100)
	
//No Manipulation of the Running Variable
graph bar (count) if parent_income > -1 ///
	& (enter_year == 2012 | enter_year == 2013 |enter_year == 2015), ///
	over(parent_income) ///
	over(enter_year) ///
	bar(1, color(navy))
	graph export "$output/figures/parent_income.png", replace	
	
	
//Exogenity	
	/*Based on Entrance Year*/
	gen pre1 = inlist(enter_year, 2011)
	gen post1 = inlist(enter_year, 2013)
	gen pre2 = inlist(enter_year, 2010, 2011)
	gen post2 = inlist(enter_year, 2013, 2014)
	gen pre3 = inlist(enter_year, 2009, 2010, 2011)
	gen post3 = inlist(enter_year, 2013, 2014, 2015)
	
	gen group1 = .
	replace group1 = 0 if pre1 == 1
	replace group1 = 1 if post1 == 1
	gen group2 = .
	replace group2 = 0 if pre2 == 1
	replace group2 = 1 if post2 == 1
	gen group3 = .
	replace group3 = 0 if pre3 == 1
	replace group3 = 1 if post3 == 1
		
	ttest real_income_mid if group1 < . & parent_income > -1, by(group1)
	ttest real_income_mid if group2 < . & parent_income > -1, by(group2)
	ttest real_income_mid if group3 < . & parent_income > -1, by(group3)


//-----------------------------------------------------------------//

//3. Control Variables
clear all
use "$clean/DataGOSM.dta", clear
	/*Individual-sepcific*/
	tabulate major
	tabulate gender
	tabulate highschool_area

	/*University-sepcific*/
	tabulate academic
	tabulate uni_found
	tabulate uni_location
	tabulate area_matching

	/*Family backgrounds*/
	tabulate sumacademicparents
	tabulate academicparents


pwcorr major gender highschool_area academic uni_found seoul seoul_metro area_matching sumacademicparents, star(.05)



//-----------------------------------------------------------------//

