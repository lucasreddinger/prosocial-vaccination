capture log close
log using logs/analysis_failure_cox.txt, text replace
//// Prosocial vaccination: Failure, Cox with LASSO
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

*** Consider contribution and vaccination only with non-mandated cause

stset days_since_apr01, id(subject_id) failure(fail_nonmand==1) origin(t 7) enter(t 7) exit(t 136) scale(1)

stcox contrib, efron vce(robust)
eststo e4rbst, title("Asympt." "robust")
stcox contrib, efron vce(cluster usstate)
eststo e4clst, title("Cluster" "on US state")
stcox contrib, efron //vce(jackknife)
eststo e4jack, title("Jackknife")

stcox contrib vx1adultHazRtHat, efron vce(robust)
eststo e5rbst, title("Asympt." "robust")
stcox contrib vx1adultHazRtHat, efron vce(cluster usstate)
eststo e5clst, title("Cluster" "on US state")
stcox contrib vx1adultHazRtHat, efron //vce(jackknife)
eststo e5jack, title("Jackknife")

esttab e4jack e5jack using tables/table_failure_cox.rtf, replace rtf eform se nomtitles nodepvar nonotes title("Cox regressions of vaccination hazard (not attributed to a mandate)") coeflabels(contrib "Contribution in public-good game ($)"  vx1adultHazRtHat "Predicted county-by-day first-dose hazard rate") addnote("* p < 0.05, ** p < 0.01, *** p < 0.001. {\i Notes:} Coefficients exponentiated (hazard ratios). Jackknife standard errors in parentheses. Efron method used for ties. Vaccination attributed to a mandate is censored.")
esttab e4jack e5jack using tables/table_failure_cox.tex, replace booktabs eform se nomtitles nodepvar nonotes title("Cox regressions of vaccination hazard (not attributed to a mandate) \label{tbl:cox}") coeflabels(contrib "Contribution in public-good game (\\$)" vx1adultHazRtHat "Predicted county-by-day first-dose hazard rate") addnote("* p < 0.05, ** p < 0.01, *** p < 0.001. \emph{Notes:} Coefficients exponentiated (hazard ratios). Jackknife standard errors in parentheses. Efron method used for ties. Vaccination attributed to a mandate is censored.")

esttab e4rbst e5rbst e4clst e5clst e4jack e5jack using tables/table_failure_cox_SE.rtf, replace rtf eform se ml(,titles) nodepvar nonotes title("Standard error comparison of Cox regressions of vaccination hazard (not attributed to a mandate)") coeflabels(contrib "Contribution in public-good game ($)" vx1adultHazRtHat "Predicted county-by-day first-dose hazard rate") addnote("* p < 0.05, ** p < 0.01, *** p < 0.001. {\i Notes:} Coefficients exponentiated (hazard ratios). Standard errors in parentheses. Efron method used for ties. Vaccination attributed to a mandate is censored.")
esttab e4rbst e5rbst e4clst e5clst e4jack e5jack using tables/table_failure_cox_SE.tex, replace booktabs eform se ml(,titles) nodepvar nonotes title("Standard error comparison of Cox regressions of vaccination hazard (not attributed to a mandate) \label{tbl:cox-SE}") coeflabels(contrib "Contribution in public-good game (\\$)" vx1adultHazRtHat "Predicted county-by-day first-dose hazard rate") addnote("* p < 0.05, ** p < 0.01, *** p < 0.001. \emph{Notes:} Coefficients exponentiated (hazard ratios). Standard errors in parentheses. Efron method used for ties. Vaccination attributed to a mandate is censored.")

**** Cumhaz curve

stcurve, cumhaz at(contrib=(0,2,4)) xlabel(1 "Apr 9" 14 "Apr 10-30" 29 "May 1-10" 39 "May 11-20" 49 "May 21-31" 60 "Jun 1-10" 70 "Jun 11-20" 80 "Jun 21-30" 90 "Jul 1-10" 100 "Jul 11-20" 110 "Jul 21-31" 121 "Aug 1-10" 128 "Aug 11-13", angle(45)) xtitle("") ytitle("") legend(c(1) subtitle("Contribution in" "public-good game") lab(1 "$0") lab(2 "$2") lab(3 "$4") ring(0) pos(5) order(1 2 3)) title("Cox regression of vaccination not attributed to a mandate", size(*0.9)) subtitle("Conditional on county-by-day predicted hazard rate", margin(b=2)) ytitle("Cumulative hazard", margin(r=2)) lpattern(solid solid solid) lwidth(*1.5 *1.5 *1.5) yla(0(0.1)0.5) lcolor(red%60 purple%60 blue%60)
graph export figures/figure_cumhaz_cox_atContrib.png, replace
graph export figures/figure_cumhaz_cox_atContrib.pdf, replace
graph close

clear

capture log close