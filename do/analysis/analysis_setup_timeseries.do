capture log close
log using logs/analysis_setup_timeseries.txt, text replace
//// Prosocial vaccination: Create time-series dataset
//// Lucas Reddinger <jlr@lucasreddinger.com>, David Levine, Gary Charness
//// 2022 March 2

*** CREATE SUBJECT-BY-DAY DATA

use data/analysis.dta, clear

* Only keep subjects who participated in all three sessions
keep if sessions == 3

order subject_id
sort subject_id

* Use fake zipcode if missing
rename loc_zipcode zipcode
replace zipcode=1 if missing(zipcode)

* Join FIPS onto ZIP
joinby zipcode using data\crosswalk_zip_to_fips, unmatched(master)
tab _merge, mi
drop _merge

* Join LASSO predictions of vx1adultHazRt
joinby fips using data\analysis_lasso_vx1adultHazRtHat, unmatched(master)
tab _merge, mi
drop _merge

order subject_id days_since_apr01

* Fill in missing vx1adultHazRt timeseries
joinby fips using data\analysis_lasso_vx1adultHazRtHat_missing, unmatched(master) update replace
tab _merge, mi
drop _merge

order subject_id days_since_apr01

* Sanity check
sort subject_id days_since_apr01 usstate zipcode fips
by subject_id days_since_apr01 usstate zipcode fips: gen dup = cond(_N==1,0,_n)
tab dup, mi
drop dup

* Drop early days
* NOTE: 2021-04-01 is days_since_apr01==0
drop if days_since_apr01<0

* Subjects have multiple FIPS
duplicates report subject_id days_since_apr01 zipcode

* Keep the FIPS with the largest res_ratio
bysort subject_id (res_ratio): keep if res_ratio==res_ratio[_N]

* Ensure no FIPS remain duplicates
bysort subject_id days_since_apr01 (fips): gen dup = cond(_N==1,0,_n)
tab dup, mi
drop dup

**** TIME SERIES SETUP

tsset subject_id days_since_apr01

gen dosedByNow = .
replace dosedByNow = 0 if vaxdose==0
replace dosedByNow = 0 if vaxdose==1 & days_since_apr01<dosedate & !missing(dosedate)
replace dosedByNow = 1 if vaxdose==1 & days_since_apr01>=dosedate & !missing(dosedate)

**** SAVE DATA
save data/analysis_timeseries.dta, replace

clear

capture log close