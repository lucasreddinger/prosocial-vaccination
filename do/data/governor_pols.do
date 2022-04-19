//// Prosocial vaccination: Governor political affiliation
//// Lucas Reddinger <jlr@lucasreddinger.com>
//// 2022 January 3
////
//// https://www.kff.org/other/state-indicator/state-political-parties/?currentTimeframe=0&selectedDistributions=governor-political-affiliation&sortModel=%7B"colId":"Location","sort":"asc"%7D

import delimited data/governor_pols.csv, clear

destring _all, replace
encode usstate_gvnr_pols, gen(gvnr_pols)
gen gvnr_gop = 0 if !missing(gvnr_pols)
replace gvnr_gop = 1 if gvnr_pols == 2

* Drop all the unneeded columns
keep usstate gvnr_gop

save data/governor_pols.dta, replace

clear
