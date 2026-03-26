cls
//-------------------------Setting--------------------------------------//
clear all

if "$project" == "" {
    display "Notice: master.do was not run. Detecting project path automatically..."
    
    global project "`c(pwd)'"
  
    global raw     "$project/data/raw"
    global clean   "$project/data/clean"
}

/* Check Path before proceed */
import excel "$raw/sumGOMS2007-2019.xlsx", sheet("Sheet1") firstrow clear

/*Generate/Edit Variables*/
drop if enter_year == 2019

drop scholarship
gen scholarship = scholarship_old

replace highschool_area = 99 if highschool_area == .
gen hsarea_clean = highschool_area
replace hsarea_clean = . if hsarea_clean < 0 | hsarea_clean == 99
label variable hsarea_clean "Cleaned high school area (no negatives or 99)"

replace area_matching = 0
replace area_matching = 1 if uni_area == highschool_area
replace GPA_raw = -1 if GPA_raw == .
replace GPA_standard = -1 if GPA_standard == .

replace GPA_percentage = GPA_raw/4.5*100 if GPA_standard == 4.5
replace GPA_percentage = GPA_raw/4.3*100 if GPA_standard == 4.3
replace GPA_percentage = GPA_raw/4.0*100 if GPA_standard == 4.0

		/*Adjsting leave of absence semester due to military service*/
		gen adjleave_sem = leave_sem
		replace adjleave_sem = leave_sem - 4 if Military == 1 & gender == 0
		replace adjleave_sem = 0 if adjleave_sem < 0
		gen adjleave_school = 0
		replace adjleave_school = 1 if adjleave_sem > 0

		/*Generate Location specific*/
		gen seoul = 0
		replace seoul = 1 if uni_location == 1
		gen seoul_metro = 0
		replace seoul_metro = 1 if uni_location == 2

gen academic = 0
replace academic = 1 if uni_type == 2 | uni_type == 3

		/*Parental education*/
		gen academicfather = 0
		replace academicfather = 1 if father_edu >= 5
		gen academicmother = 0
		replace academicmother = 1 if mother_edu >= 5
		gen sumacademicparents = academicfather + academicmother
		gen academicparents = 0
		replace academicparents = 1 if sumacademicparents >= 1

tabulate major, generate(major_)

/*Fixing Error in Master data file*/
replace scholarship = 1 if scholarship_percent > 0 & collection >=2011
replace scholarship = 0 if scholarship_percent == 0 & collection >=2011
replace scholarship_percent = 0 if scholarship == 0

replace scholarship_old = 1 if scholarship_percent > 0 & collection >=2011
replace scholarship_old = 0 if scholarship_percent == 0 & collection >=2011



	/*Construct Scholarship_percent Data*/
/*
Based on 2011 Data, mean scholarship_percent based on uni_found (National vs Private) and Parnetal Income ==1, ==2, and =>3
uni_found == 0 (national) 50 40 40
uni_found == 1 (private)  70 50 45
 */
	replace scholarship_percent = 100 if scholarship == 1 & uni_found == 0 & parent_income <= 1 & collection < 2011
	replace scholarship_percent = 50 if scholarship == 1 & uni_found == 0 & parent_income == 2 & collection < 2011
	replace scholarship_percent = 40 if scholarship == 1 & uni_found == 0 & parent_income >= 3 & collection < 2011
	
	replace scholarship_percent = 70 if scholarship == 1 & uni_found == 1 & parent_income <= 1 & collection < 2011
	replace scholarship_percent = 50 if scholarship == 1 & uni_found == 1 & parent_income == 2 & collection < 2011
	replace scholarship_percent = 45 if scholarship == 1 & uni_found == 1 & parent_income >= 3 & collection < 2011


/*Standardization*/
gen GPAZ = . if GPA_raw != -1 & GPA_standard != -1
bys GPA_standard : egen mean_gpa = mean(GPA_raw) if GPA_raw != -1 & GPA_standard != -1
bys GPA_standard : egen sd_gpa = sd(GPA_raw) if GPA_raw != -1 & GPA_standard != -1
replace GPAZ = (GPA_raw - mean_gpa) / sd_gpa if GPA_raw != -1 & GPA_standard != -1
drop mean_gpa sd_gpa
sum GPAZ

/*Labelling*/
label define gender_lbl 0 "Male" 1 "Female"
label values gender gender_lbl

label define uni_found_lbl 0 "National/Public" 1 "Private"
label values uni_found uni_found_lbl

label define uni_type_lbl 1 "Academic" 2 "Vocational" 3 "Education"
label values uni_type uni_type_lbl

label define father_edu_lbl 0 "No" 1 "Elementary" 2 "Middle" 3 "High" 4 "Vocational" 5 "Academic" 6 "Post"
label values father_edu father_edu_lbl

label define mother_edu_lbl 0 "No" 1 "Elementary" 2 "Middle" 3 "High" 4 "Vocational" 5 "Academic" 6 "Post"
label values mother_edu mother_edu_lbl

label define major_lbl 1 "Humanity" 2 "Social Science" 3 "Education" 4 "Technology" 5 "Science" 6 "Medical" 7 "Arts"
label values major major_lbl

label define uni_location_lbl 1 "Seoul" 2 "Seoul Capital Area (excluding Seoul)" 3 "Chungcheong" 4 "Gyeongsang" 5 "Jeolla"
label values uni_location uni_location_lbl

label define sumacademicparents_lbl 0 "Neither parent" 1 "One parent" 2 "Both parents"
label values sumacademicparents sumacademicparents_lbl
		
save "$clean/DataGOSM.dta", replace
display "Succesfully saved"
//-----------------------------------------------------------------//