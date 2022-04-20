capture log close
log using logs/analysis_lasso_vx1adultHazRtHat.txt, text replace
//// Prosocial vaccination: Analysis with LASSO to predict vx1adultHazRt
//// Lucas Reddinger <jlr@lucasreddinger.com>, David Levine, Gary Charness
//// 2022 January 16

set seed 103157

* Use CDC county-level transmission data
use data\cdc_county_transmission, clear

* Join CDC county-level vaccination data
* Only keep records if in both, just to keep things clean
joinby fips days_since_apr01 using data\cdc_county_vaccination

* Join CDC state-level vaccination data
joinby usstate days_since_apr01 using data\cdc_state_vaccination, unm(both)
tab _merge
drop _merge

* Join CDC variant proportion data
joinby days_since_apr01 using data\cdc_variants, unm(both)
tab _merge
drop _merge
replace prop_delta = 0 if missing(prop_delta)
gen deltaExists = 1
replace deltaExists = 0 if prop_delta == 0
egen deltaPctRec = record(prop_delta), order(days_since_apr01)
drop prop_delta

* Join governor political affiliation
joinby usstate using data\governor_pols, unm(both)
tab _merge
* Drop PR
drop if usstate==40
drop _merge

duplicates report fips days_since_apr01

order usstate fips days_since_apr01
sort usstate fips days_since_apr01

**** DROP VERY EARLY DATA

drop if days_since_apr01 < -28

**** CLEAN-UP OUTLIERS

* dosesAvailPer100k = dist_per_100k - admin_per_100k
sum dosesAvailPer100k, detail
replace dosesAvailPer100k=0 if dosesAvailPer100k<0
sum dosesAvailPer100k, detail

* New cases per 100,000 persons in the past 7 days
sum cases_per_100k_7_day_count_chang, detail
replace cases_per_100k_7_day_count_chang=0 if cases_per_100k_7_day_count_chang<0

sum cases_per_100k_7_day_count_chang, detail

* Percentage of positive NAAT in the past 7 days
sum percent_test_results_reported_po, detail
replace percent_test_results_reported_po=0 if percent_test_results_reported_po<0
replace percent_test_results_reported_po=100 if percent_test_results_reported_po>100 & !missing(percent_test_results_reported_po)
sum percent_test_results_reported_po, detail

* Percent of people who are fully vaccinated (have second dose of a
* two-dose vaccine or one dose of a single-dose vaccine) based on the
* jurisdiction and county where recipient lives
sum series_complete_pop_pct, detail
replace series_complete_pop_pct=0 if series_complete_pop_pct<0
replace series_complete_pop_pct=100 if series_complete_pop_pct>100 & !missing(series_complete_pop_pct)
sum series_complete_pop_pct, detail

* Percent of Total Pop with at least one Dose by State of Residence
sum administered_dose1_pop_pct, detail
replace administered_dose1_pop_pct=0 if administered_dose1_pop_pct<0
replace administered_dose1_pop_pct=100 if administered_dose1_pop_pct>100 & !missing(administered_dose1_pop_pct)
sum administered_dose1_pop_pct, detail

* Percent of people 18+ who are fully vaccinated (have second dose of a
* two-dose vaccine or one dose of a single-dose vaccine) based on the
* jurisdiction and county where recipient lives
sum series_complete_18pluspop_pct, detail
replace series_complete_18pluspop_pct=0 if series_complete_18pluspop_pct<0
replace series_complete_18pluspop_pct=100 if series_complete_18pluspop_pct>100 & !missing(series_complete_18pluspop_pct)
sum series_complete_18pluspop_pct, detail

* Percent of 18+ Pop with at least one Dose by State of Residence
sum administered_dose1_recip_18plusp, detail
replace administered_dose1_recip_18plusp=0 if administered_dose1_recip_18plusp<0
replace administered_dose1_recip_18plusp=100 if administered_dose1_recip_18plusp>100 & !missing(administered_dose1_recip_18plusp)
sum administered_dose1_recip_18plusp, detail

**** TIME SERIES SETUP

tsset fips days_since_apr01

gen casRtMA07dL = cases_per_100k_7_day_count_chang
gen posRtMA07dL = percent_test_results_reported_po
tsegen vx1RtMA07dL = rowmean(L(1/7).administered_dose1_pop_pct)
tsegen vx2RtMA07dL = rowmean(L(1/7).series_complete_pop_pct)
tsegen vx1adultRtMA07dL = rowmean(L(1/7).administered_dose1_recip_18plusp)
tsegen vx2adultRtMA07dL = rowmean(L(1/7).series_complete_18pluspop_pct)
tsegen deltaPctRecMA07dL = rowmean(L(1/7).deltaPctRec)

gen casRtMA07dLL = L8.cases_per_100k_7_day_count_chang
gen posRtMA07dLL = L8.percent_test_results_reported_po
tsegen vx1RtMA07dLL = rowmean(L(8/14).administered_dose1_pop_pct)
tsegen vx2RtMA07dLL = rowmean(L(8/14).series_complete_pop_pct)
tsegen vx1adultRtMA07dLL = rowmean(L(8/14).administered_dose1_recip_18plusp)
tsegen vx2adultRtMA07dLL = rowmean(L(8/14).series_complete_18pluspop_pct)
tsegen deltaPctRecMA07dLL = rowmean(L(8/14).deltaPctRec)

tsegen delCasRtMA14dL = rowmean(L(1/14).cases_per_100k_7_day_count_chang * deltaPctRec)
tsegen delPosRtMA14dL = rowmean(L(1/14).percent_test_results_reported_po * deltaPctRec)
tsegen delVx1RtMA14dL = rowmean(L(1/14).administered_dose1_pop_pct * deltaPctRec)
tsegen delVx2RtMA14dL = rowmean(L(1/14).series_complete_pop_pct * deltaPctRec)
tsegen delVx1adultRtMA14dL = rowmean(L(1/14).administered_dose1_recip_18plusp * deltaPctRec)
tsegen delVx2adultRtMA14dL = rowmean(L(1/14).series_complete_18pluspop_pct * deltaPctRec)

egen casRtMARec = record(casRtMA07dL), by(fips) order(days_since_apr01)
egen posRtMARec = record(posRtMA07dL), by(fips) order(days_since_apr01)

gen vx1adultRtWoW = vx1adultRtMA07dL - vx1adultRtMA07dLL
sum vx1adultRtWoW, detail
hist vx1adultRtWoW
replace vx1adultRtWoW=0 if vx1adultRtWoW<0
* Don't do outlier censoring here, as we will do it with Hazard Rates below
*_pctile vx1adultRtWoW, p(98)
*replace vx1adultRtWoW=r(r1) if vx1adultRtWoW>r(r1) & !missing(vx1adultRtWoW)
sum vx1adultRtWoW, detail
hist vx1adultRtWoW

gen vx1adultHazRt = 100 * vx1adultRtWoW / (100 - vx1adultRtMA07dLL)
sum vx1adultHazRt, detail
hist vx1adultHazRt
replace vx1adultHazRt=0 if vx1adultHazRt<0
_pctile vx1adultHazRt, p(98)
replace vx1adultHazRt=r(r1) if vx1adultHazRt>r(r1) & !missing(vx1adultHazRt)
sum vx1adultHazRt, detail
hist vx1adultHazRt

**** LASSO

lasso linear vx1adultHazRt days_since_apr01 gvnr_gop dosesAvailPer100k ///
  casRtMARec posRtMARec casRtMA07dL posRtMA07dL vx1RtMA07dL vx2RtMA07dL ///
  casRtMA07dLL posRtMA07dLL vx1RtMA07dLL vx2RtMA07dLL vx1adultRtMA07dLL vx2adultRtMA07dLL ///
  deltaExists ///
  delCasRtMA14dL delPosRtMA14dL delVx1RtMA14dL delVx2RtMA14dL delVx1adultRtMA14dL delVx2adultRtMA14dL
sum vx1adultHazRt, detail

lassocoef, di(coef)

capture drop vx1adultHazRtHat
predict vx1adultHazRtHat

sum vx1adultHazRtHat, detail
hist vx1adultHazRtHat

_pctile vx1adultHazRtHat, p(2 98)
replace vx1adultHazRtHat=r(r1) if vx1adultHazRtHat<r(r1)
replace vx1adultHazRtHat=r(r2) if vx1adultHazRtHat>r(r2) & !missing(vx1adultHazRtHat)

sum vx1adultHazRtHat, detail
hist vx1adultHazRtHat

graph close

**** KEEP, SORT, ORDER

keep fips days_since_apr01 vx1adultHazRtHat
order fips days_since_apr01 vx1adultHazRtHat
sort fips days_since_apr01 vx1adultHazRtHat

**** SAVE DATA
save data/analysis_lasso_vx1adultHazRtHat.dta, replace

clear

capture log close