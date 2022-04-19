capture log close
log using logs/analysis_failure_checks.txt, text replace
//// Prosocial vaccination: Failure analysis checks
//// Lucas Reddinger <jlr@lucasreddinger.com>, David Levine, Gary Charness
//// 2022 March 2
set scheme s2mono

*************************
* Schoenfeld residuals
*************************

**** Data setup

use data/analysis_timeseries.dta, clear
replace vx1adultHazRtHat = 1 if missing(vx1adultHazRtHat)
replace vaxdoseMand = 0 if missing(vaxdoseMand)
keep if inlist(days_since_apr01,8,21,36,46,56,67,77,87,97,107,117,128,135,136)
drop if days_since_apr01>dosedate & !missing(dosedate)

rename contrib contribution
rename vx1adultHazRtHat dose_hazard_rate_hat

**** Types of failure

gen fail_nonmand_mand = dosedByNow
replace fail_nonmand_mand=2 if vaxdoseMand==1 & dosedByNow==1

gen fail_nonmand = dosedByNow
replace fail_nonmand=0 if vaxdoseMand==1

gen fail_mand = dosedByNow
replace fail_mand=0 if vaxdoseMand==0

*** Consider contribution and vaccination only with non-mandated cause

stset days_since_apr01, id(subject_id) failure(fail_nonmand==1) origin(t 7) enter(t 7) exit(t 136) scale(1)

stcox dose_hazard_rate_hat contribution, efron vce(robust)
estat phtest
predict vx1adultHazRtHatHat contribHat, schoen
twoway scatter vx1adultHazRtHatHat _t, title("Vaccination not attributed to a mandate") || lfit vx1adultHazRtHatHat _t
graph save temp/schoen_vx1adultHazRtHat.gph, replace
twoway scatter contribHat _t, title("Vaccination not attributed to a mandate") || lfit contribHat _t
graph save temp/schoen_contrib.gph, replace
graph close

graph combine temp/schoen_contrib.gph temp/schoen_vx1adultHazRtHat.gph, c(2) ycommon xsize(6) ysize(3) iscale(*1) imargin(1 1 1 1)
graph export figures/figure_failure_schoen.png, replace
graph export figures/figure_failure_schoen.pdf, replace
graph close

clear

capture log close