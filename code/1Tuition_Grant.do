cls
clear all

* [안전장치] 드라이브 문자 없이 현재 위치 자동 파악
if "$project" == "" {
    global project "`c(pwd)'"
    global raw     "$project/data/raw"
    global output  "$project/output"
}

* 1. 데이터 불러오기
import excel "$raw/Tuition_Grant.xlsx", sheet("Sheet1") firstrow clear


// Tuition Increase Cap //
/*Cap*/
twoway ///
	(line Cap Year, lcolor(black)), ///
	xline(2011) ///
	ytitle(`"Tuition Increase Cap (%)"') xtitle(`"Year"')

graph export "$figures/Tuition_Increase_Cap.png", replace
// --------------------------------------------------------- //

// Tutition //

replace Average = Average/1000
replace National = National/1000
replace Private = Private/1000
replace Capital = Capital/1000
replace Local = Local/1000

/*Tuition Trend leave gap*/
twoway ///
	(line Average Year, lcolor(black) lpattern(solid) cmissing(n)) ///
	(line National Year, lcolor(edkblue) lpattern(dash) cmissing(n)) ///
	(line Private Year, lcolor(cranberry) lpattern(longdash) cmissing(n)) ///
	(line Capital Year, lcolor(emerald) lpattern(shortdash) cmissing(n)) ///
	(line Local Year, lcolor(red) lpattern(shortdash_dot) cmissing(n)), ///
	xline(2011) xline(2012) ///
	text(8 2011 "TICP announced", yoffset(+5)) ///
	text(8 2015 "TICP & KNSP effective") ///
	legend(label(1 Average) label(2 National) label(3 Private) ///
	label(4 Capital) label(5 Local)) ///
	ytitle("Tuition (in million KRW, nominal terms)") xtitle("Year") ///
	xlabel(2009(2)2025)

graph export "$figures/Tuition_nominal_terms.png", replace	


/*Tuition in Real Terms*/
/*Generate Real Value*/
tset Year
replace RAverage = Average/CPI_base2020 *100
replace RNational = National/CPI_base2020 *100
replace RPrivate = Private/CPI_base2020 *100
replace RCapital = Capital/CPI_base2020 *100
replace RLocal = Local/CPI_base2020 *100

gen grA = D.RAverage / L.RAverage
gen grN = D.RNational / L.RNational
gen grP = D.RPrivate / L.RPrivate
gen grC = D.RCapital / L.RCapital
gen grL = D.RLocal / L.RLocal

twoway ///
	(line RAverage Year, lcolor(black) lpattern(solid) cmissing(n)) ///
	(line RNational Year, lcolor(edkblue) lpattern(dash) cmissing(n)) ///
	(line RPrivate Year, lcolor(cranberry) lpattern(longdash) cmissing(n)) ///
	(line RCapital Year, lcolor(emerald) lpattern(shortdash) cmissing(n)) ///
	(line RLocal Year, lcolor(red) lpattern(shortdash_dot) cmissing(n)), ///
	xline(2011) xline(2012) ///
	text(8 2011 "TICP announced", yoffset(+5)) ///
	text(8 2015 "TICP & KNSP effective") ///
	legend(label(1 Average) label(2 National) label(3 Private) ///
	label(4 Capital) label(5 Local)) ///
	ytitle("Tuition (in million KRW, real terms)") xtitle("Year") ///
	xlabel(2009(2)2025)
	
graph export "$figures/Tuition_real_terms.png", replace	

// --------------------------------------------------------- //

// Korean National Scholarship Program //
cls
clear all

* 이미 상단이나 master.do에서 $raw를 설정했다면 아래 if문은 그냥 지나갑니다.
if "$raw" == "" {
    global project "`c(pwd)'"
    global raw     "$project/data/raw"
}

* 표준 경로($raw)를 사용하여 Sheet4를 불러옵니다.
import excel "$raw/Tuition_Grant.xlsx", sheet("Sheet4") firstrow clear

/*Grant Trend*/
tset Year
replace Total = Total/10000
replace type1 = type1/10000
replace type2 = type2/10000
replace multi = multi/10000
replace FutureDream = FutureDream/10000
replace HopeDream = HopeDream/10000

* Nominal Terms
twoway ///
	(line Total Year, lcolor(black) lpattern(solid)) ///
	(line type1 Year, lcolor(edkblue) lpattern(dash)) ///
	(line type2 Year, lcolor(cranberry) lpattern(longdash)) ///
	(line multi Year, lcolor(emerald) lpattern(shortdash)) ///
	(line FutureDream Year, lcolor(red) lpattern(shortdash_dot)) ///
	(line HopeDream Year, lcolor(brown) lpattern(dash_dot)), ///
	xline(2012) text(4.2 2012 "KNSP implemented") ///
	legend(label(1 Total) label(2 Type1) label(3 Type2) label(4 Multiple-child) ///
	label(5 Future-Dream) label(6 Hope-Dream)) ///
	ytitle(`"Grants (in trillion KRW, nominal terms)"') xtitle(`"Year"') ///
	xlabel(2009(1)2019)
	graph export "$figures/Grants_nominal_terms.png", replace	
	
	
* Real Terms	
gen RTotal = Total/CPI_base2020 *100
gen Rtype1 = type1/CPI_base2020 *100
gen Rtype2 = type2/CPI_base2020 *100
gen Rmulti = multi/CPI_base2020 *100
gen RFutureDream = FutureDream/CPI_base2020 *100
gen RHopeDream = HopeDream/CPI_base2020 *100

twoway ///
	(line RTotal Year, lcolor(black) lpattern(solid)) ///
	(line Rtype1 Year, lcolor(edkblue) lpattern(dash)) ///
	(line Rtype2 Year, lcolor(cranberry) lpattern(longdash)) ///
	(line Rmulti Year, lcolor(emerald) lpattern(shortdash)) ///
	(line RFutureDream Year, lcolor(red) lpattern(shortdash_dot)) ///
	(line RHopeDream Year, lcolor(brown) lpattern(dash_dot)), ///
	xline(2012) text(4.2 2012 "KNSP implemented") ///
	legend(label(1 Total) label(2 Type1) label(3 Type2) label(4 Multiple-child) ///
	label(5 Future-Dream) label(6 Hope-Dream)) ///
	ytitle(`"Grants (in trillion KRW, real terms)"') xtitle(`"Year"') ///
	xlabel(2009(1)2019)	
	graph export "$figures/Grants_real_terms.png", replace	
