capture log close
log using logs/analysis_failure_compete.txt, text replace
//// Prosocial vaccination: Failure, competing, with LASSO
//// Lucas Reddinger <jlr@lucasreddinger.com>, David Levine, Gary Charness
//// 2022 April 8
set scheme s2mono

**** Data setup

use data/analysis_timeseries.dta, clear
replace vx1adultHazRtHat = 1 if missing(vx1adultHazRtHat)
replace vaxdoseMand = 0 if missing(vaxdoseMand)
keep if inlist(days_since_apr01,8,21,36,46,56,67,77,87,97,107,117,128,135,136)
drop if days_since_apr01>dosedate & !missing(dosedate)

**** Types of failure

gen fail_nonmand_mand = dosedByNow
replace fail_nonmand_mand=2 if vaxdoseMand==1 & dosedByNow==1

gen fail_nonmand = dosedByNow
replace fail_nonmand=0 if vaxdoseMand==1

gen fail_mand = dosedByNow
replace fail_mand=0 if vaxdoseMand==0

**** Non-mandated with mandated competing

stset days_since_apr01, id(subject_id) failure(fail_nonmand_mand==1) origin(t 7) enter(t 7) exit(t 136) scale(1)

stcrreg contrib vx1adultHazRtHat, compete(fail_nonmand_mand==2) vce(jackknife)
eststo e1, title("Non-mandated")

stcurve, cif at(contrib=(0,2,4)) xlabel(1 "Apr 9" 14 "Apr 10-30" 29 "May 1-10" 39 "May 11-20" 49 "May 21-31" 60 "Jun 1-10" 70 "Jun 11-20" 80 "Jun 21-30" 90 "Jul 1-10" 100 "Jul 11-20" 110 "Jul 21-31" 121 "Aug 1-10" 128 "Aug 11-13", angle(45)) xtitle("") ytitle("") legend(c(1) subtitle("Contribution in" "public-good game") lab(1 "$0") lab(2 "$2") lab(3 "$4") ring(0) pos(5) order(1 2 3)) title("Non-mandated vaccination, competing with mandated") subtitle("Conditional on county-by-day predicted hazard rate", margin(b=2)) ytitle("Cumulative incidence", margin(r=2)) lpattern(solid solid solid) lwidth(*1.5 *1.5 *1.5) yla(0(0.1)0.4) lcolor(red%60 purple%60 blue%60)
graph save temp/cif_atContrib_mand0.gph, replace
graph export figures/figure_cif_atContrib_mand0.png, replace
graph export figures/figure_cif_atContrib_mand0.pdf, replace

**** Mandated with non-mandated competing

stset days_since_apr01, id(subject_id) failure(fail_nonmand_mand==2) origin(t 7) enter(t 7) exit(t 136) scale(1)

stcrreg contrib vx1adultHazRtHat, compete(fail_nonmand_mand==1) vce(jackknife)
eststo e3, title("Mandated")

stcurve, cif at(contrib=(0,2,4)) xlabel(1 "Apr 9" 14 "Apr 10-30" 29 "May 1-10" 39 "May 11-20" 49 "May 21-31" 60 "Jun 1-10" 70 "Jun 11-20" 80 "Jun 21-30" 90 "Jul 1-10" 100 "Jul 11-20" 110 "Jul 21-31" 121 "Aug 1-10" 128 "Aug 11-13", angle(45)) xtitle("") ytitle("") legend(c(1) subtitle("Contribution in" "public-good game") lab(1 "$0") lab(2 "$2") lab(3 "$4") ring(0) pos(2) order(1 2 3)) title("Mandated vaccination, competing with non-mandated") subtitle("Conditional on county-by-day predicted hazard rate", margin(b=2)) ytitle("Cumulative incidence", margin(r=2)) lpattern(solid solid solid) lwidth(*1.5 *1.5 *1.5) yla(0(0.1)0.4) lcolor(red%60 purple%60 blue%60)
graph save temp/cif_atContrib_mand1.gph, replace
graph export figures/figure_cif_atContrib_mand1.png, replace
graph export figures/figure_cif_atContrib_mand1.pdf, replace

**** Combine tables

esttab e1 e3 using tables/table_failure_compete.rtf, replace rtf eform se ml(,titles) nodepvar title("Competing hazards regressions") coeflabels(contrib "Contribution in public-good game ($)" vx1adultHazRtHat "Predicted county-by-day first-dose hazard rate") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
//option notes() not allowed
//notes("Jackknife standard errors.")
esttab e1 e3 using tables/table_failure_compete.tex, replace booktabs eform se ml(,titles) nodepvar title("Competing hazards regressions") coeflabels(contrib "Contribution in public-good game (\\$)" vx1adultHazRtHat "Predicted county-by-day first-dose hazard rate") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
//option notes() not allowed
//notes("Jackknife standard errors.")

**** Combine graphs

graph combine temp/cif_atContrib_mand0.gph temp/cif_atContrib_mand1.gph, col(1) ycommon xsize(6) ysize(8) iscale(*0.9) imargin(1 1 1 1)
graph export figures/figure_cif_atContrib.png, replace
graph export figures/figure_cif_atContrib.pdf, replace

graph close

clear

capture log close
