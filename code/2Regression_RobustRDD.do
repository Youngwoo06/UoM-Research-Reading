cls
//Econometric model
//Regression Robust(Sharp) RDD
clear all
cd "E:\2023-2025 UofG MRes Economics\2024-2025\Dissertation\Data"
use DataGOSM

//Drop Missing value
	drop if missing(enter_year) | enter_year == -1 
	drop if missing(parent_income) | parent_income == -1

//Treatment Eligibility = Treatment
* Treatment eligibility: 2012 group (parent_income = 3)
	gen elig_2012_3 = (enter_year >= 2012) & (parent_income <= 3)	
	gen elig_2012x = (elig_2012_3 == 0)

* Treatment eligibility: 2013+ group (parent_income between 4 and 6)
	gen elig_2013plus_456 = (enter_year >= 2013) & (parent_income <= 6)
	gen elig_2013x = (elig_2013plus_456 == 0)	
	
* Treatment eligibility: 2015+ group (parent_income = 7)
	gen elig_2015plus_7 = (enter_year >= 2015) & (parent_income <= 7)
	gen elig_2015x = (elig_2015plus_7 == 0)
	
* Combined treatment eligibility (dynamic)
	gen elig_agg = (parent_income <= 3 & enter_year >= 2012) | ///
		(parent_income <= 6 & enter_year >= 2013) | ///
		(parent_income <= 7 & enter_year >= 2015)
	gen elig_aggx = (elig_agg == 0)	
	
	
//Running Variable
/*Running variable centered at each cutoff*/
	gen runvar_2012 = parent_income - 3.5 if enter_year == 2012
	gen runvar_2013 = parent_income - 6.5 if enter_year == 2013
	gen runvar_2015 = parent_income - 7.5 if enter_year == 2015

	gen runvar_1213 = .
	replace runvar_1213 = runvar_2012 if enter_year == 2012
	replace runvar_1213 = runvar_2013 if enter_year == 2013 & runvar_1213 == .
	tabulate runvar_1213

	gen runvar_121315 = .
	replace runvar_121315 = runvar_2012 if enter_year == 2012
	replace runvar_121315 = runvar_2013 if enter_year == 2013 & runvar_121315 == .
	replace runvar_121315 = runvar_2015 if enter_year == 2015 & runvar_121315 == .

//Interaction Treatment*Running Variable
	gen TR2012 = elig_2012_3 * runvar_2012
	gen TR2013 = elig_2013plus_456 * runvar_2013
	gen TR2015 = elig_2015plus_7 * runvar_2015
	gen TR121315 = elig_agg * runvar_121315
	/*But due to perfect collinearity, it will be omitted*/

//Running Sharp RDD by using 'reg'
* 2012 cutoff
	reg adjleave_school elig_2012_3 runvar_2012 TR2012 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean /// 
		if inrange(parent_income, 2, 5) & enter_year == 2012, robust
	outreg2 using SharpRDD_LoA.doc, replace ctitle("2012")
	outreg2 using SharpRDD.doc, replace ctitle("LoA")

	reg adjleave_sem elig_2012_3 runvar_2012 TR2012 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean /// 
		if inrange(parent_income, 2, 5) & enter_year == 2012, robust	
	outreg2 using SharpRDD_LoAsem.doc, replace ctitle("2012")
	outreg2 using SharpRDD.doc, append ctitle("Semesters")
	
	reg GPAZ elig_2012_3 runvar_2012 TR2012 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean /// 
		if inrange(parent_income, 2, 5) & enter_year == 2012, robust
	outreg2 using SharpRDD_GPA.doc, replace ctitle("2012")
	outreg2 using SharpRDD.doc, append ctitle("GPA")
	
	
	* diff bandwidth
	reg adjleave_school elig_2012_3 runvar_2012 TR2012 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean /// 
		if inrange(parent_income, 3, 4) & enter_year == 2012, robust
	outreg2 using SharpRDDdiffband.doc, replace ctitle("LoA")

	reg adjleave_sem elig_2012_3 runvar_2012 TR2012 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean /// 
		if inrange(parent_income, 3, 4) & enter_year == 2012, robust	
	outreg2 using SharpRDDdiffband.doc, append ctitle("Semesters")
	
	reg GPAZ elig_2012_3 runvar_2012 TR2012 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean /// 
		if inrange(parent_income, 3, 4) & enter_year == 2012, robust
	outreg2 using SharpRDDdiffband.doc, append ctitle("GPA")
	
	

* 2013 cutoff
	reg adjleave_school elig_2013plus_456 runvar_2013 TR2013 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 5, 8) & enter_year == 2013, robust
	outreg2 using SharpRDD_LoA.doc, append ctitle("2013")
	outreg2 using SharpRDD.doc, append ctitle("LoA")
	
	reg adjleave_sem elig_2013plus_456 runvar_2013 TR2013 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 5, 8) & enter_year == 2013, robust
	outreg2 using SharpRDD_LoAsem.doc, append ctitle("2013")
	outreg2 using SharpRDD.doc, append ctitle("Semesters")
	
	reg GPAZ elig_2013plus_456 runvar_2013 TR2013 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 5, 8) & enter_year == 2013, robust
	outreg2 using SharpRDD_GPA.doc, append ctitle("2013")
	outreg2 using SharpRDD.doc, append ctitle("GPA")


	* diff bandwidth
	reg adjleave_school elig_2013plus_456 runvar_2013 TR2013 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 6, 7) & enter_year == 2013, robust
	outreg2 using SharpRDDdiffband.doc, append ctitle("LoA")
	
	reg adjleave_sem elig_2013plus_456 runvar_2013 TR2013 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 6, 7) & enter_year == 2013, robust
	outreg2 using SharpRDDdiffband.doc, append ctitle("Semesters")
	
	reg GPAZ elig_2013plus_456 runvar_2013 TR2013 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 6, 7) & enter_year == 2013, robust
	outreg2 using SharpRDDdiffband.doc, append ctitle("GPA")	
	
	
* 2015 cutoff
	reg adjleave_school elig_2015plus_7 runvar_2015 TR2015 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 6, 8) & enter_year == 2015, robust
	outreg2 using SharpRDD_LoA.doc, append ctitle("2015")	
	outreg2 using SharpRDD.doc, append ctitle("LoA")
	
	reg adjleave_sem elig_2015plus_7 runvar_2015 TR2015 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 6, 8) & enter_year == 2015, robust	
	outreg2 using SharpRDD_LoAsem.doc, append ctitle("2015")
	outreg2 using SharpRDD.doc, append ctitle("Semesters")
	
	reg GPAZ elig_2015plus_7 runvar_2015 TR2015 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 6, 8) & enter_year == 2015, robust
	outreg2 using SharpRDD_GPA.doc, append ctitle("2015")
	outreg2 using SharpRDD.doc, append ctitle("GPA")

	* diff bandwidth	
	reg adjleave_school elig_2015plus_7 runvar_2015 TR2015 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 7, 8) & enter_year == 2015, robust	
	outreg2 using SharpRDDdiffband.doc, append ctitle("LoA")
	
	reg adjleave_sem elig_2015plus_7 runvar_2015 TR2015 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 7, 8) & enter_year == 2015, robust	
	outreg2 using SharpRDDdiffband.doc, append ctitle("Semesters")
	
	reg GPAZ elig_2015plus_7 runvar_2015 TR2015 ///
		gender ///
		academicparents ///
		academic uni_found seoul seoul_metro area_matching i.hsarea_clean ///  
		if inrange(parent_income, 7, 8) & enter_year == 2015, robust
	outreg2 using SharpRDDdiffband.doc, append ctitle("GPA")	
	
//Print Result
shellout using `"SharpRDD_LoA.doc"'

shellout using `"SharpRDD_LoAsem.doc"'

shellout using `"SharpRDD_GPA"'	

shellout using `"SharpRDD"'			
		
	
//Plotting Graph		
ssc install rdrobust, replace


* LoA
* ===== 2012 cutoff (c = 3) =====		
rdplot adjleave_school parent_income if enter_year==2012 & parent_income >=2 & parent_income <=5, ///
	c(3.5) p(1) ///
    nbins(4 4) support(2 5) ///
    graph_options( xtitle("Parental income group") ///
				   ytitle("Mean LoA") title("RDD plot: LoA around 2012 cutoff") )		

* ===== 2013 cutoff (c = 6) =====
rdplot adjleave_school parent_income if enter_year==2013 & parent_income >= 5 & parent_income <= 8, ///
	c(6.5) p(1) ///
    nbins(4 4) support(5 8) ///
    graph_options( xtitle("Parental income group") ///
                   ytitle("Mean LoA") title("RDD plot: LoA around 2013 cutoff") )

* ===== 2015 cutoff (c = 7) =====
rdplot adjleave_school parent_income if enter_year==2015 & parent_income >= 6 & parent_income <= 8, ///
	c(7.5) p(1) ///
    nbins(3 3) support(6 8) ///
    graph_options( xtitle("Parental income group") ///
                   ytitle("Mean LoA") title("RDD plot: LoA around 2015 cutoff") )

				   
* Semesters
* ===== 2012 cutoff (c = 3) =====		
rdplot adjleave_sem parent_income if enter_year==2012 & parent_income >=2 & parent_income <=5, ///
	c(3.5) p(1) ///
    nbins(4 4) support(2 5) ///
    graph_options( xtitle("Parental income group") ///
				   ytitle("Mean Semesters") title("RDD plot: Semesters around 2012 cutoff") )		

* ===== 2013 cutoff (c = 6) =====
rdplot adjleave_sem parent_income if enter_year==2013 & parent_income >= 5 & parent_income <= 8, ///
	c(6.5) p(1) ///
    nbins(4 4) support(5 8) ///
    graph_options( xtitle("Parental income group") ///
                   ytitle("Mean Semesters") title("RDD plot: Semesters around 2013 cutoff") )

* ===== 2015 cutoff (c = 7) =====
rdplot adjleave_sem parent_income if enter_year==2015 & parent_income >= 6 & parent_income <= 8, ///
	c(7.5) p(1) ///
    nbins(3 3) support(6 8) ///
    graph_options( xtitle("Parental income group") ///
                   ytitle("Mean Semesters") title("RDD plot: Semesters around 2015 cutoff") )


				   
* GPAZ
* ===== 2012 cutoff (c = 3) =====	
rdplot GPAZ parent_income if enter_year==2012 & parent_income >=2 & parent_income <=5, ///
	c(3.5) p(1) ///
    nbins(4 4) support(2 5) ///
    graph_options( xtitle("Parental income group") ///
				   ytitle("Mean GPAZ") title("RDD plot: GPAZ around 2012 cutoff") )		

* ===== 2013 cutoff (c = 6) =====
rdplot GPAZ parent_income if enter_year==2013 & parent_income >= 5 & parent_income <= 8, ///
	c(6.5) p(1) ///
    nbins(4 4) support(5 8) ///
    graph_options( xtitle("Parental income group") ///
                   ytitle("Mean GPAZ") title("RDD plot: GPAZ around 2013 cutoff") )

* ===== 2015 cutoff (c = 7) =====
rdplot GPAZ parent_income if enter_year==2015 & parent_income >= 6 & parent_income <= 8, ///
	c(7.5) p(1) ///
    nbins(3 3) support(6 8) ///
    graph_options( xtitle("Parental income group") ///
                   ytitle("Mean GPAZ") title("RDD plot: GPAZ around 2015 cutoff") )
				   
