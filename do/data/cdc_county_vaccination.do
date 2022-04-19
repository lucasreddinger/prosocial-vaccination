//// Prosocial vaccination: CDC county-level COVID-19 vaccination data
//// Lucas Reddinger <jlr@lucasreddinger.com>
//// 2022 January 11
////
//// https://data.cdc.gov/Vaccinations/COVID-19-Vaccinations-in-the-United-States-County/8xkx-amqh

**** Use the second line to pull current data directly from the CDC
import delimited "https://osf.io/kuacg/download", clear
*import delimited "https://data.cdc.gov/api/views/8xkx-amqh/rows.csv?accessType=DOWNLOAD", clear

* We only need data until 15 August 2021
gen int days_since_apr01 = date(date,"MDY",2050) - date("2021/04/01","YMD",2050)
drop if days_since_apr01 > date("2021/08/15","YMD",2050) - date("2021/04/01","YMD",2050)

* Clean up the data
destring fips, force replace
rename recip_state usstate_name

* Drop unneeded states
drop if inlist(usstate_name, "VA2", "DD2", "RP", "IH2", "FM", "US", "UNK", "PW")
drop if inlist(usstate_name, "MH", "GU", "AS", "MP", "BP2", "VI", "LTC", "PR")

* Merge state codes
merge m:1 usstate_name using data/usstates.dta
drop _merge

**** NOTICE
* Here I drop many columns that could be useful.
keep fips usstate days_since_apr01 series_complete_pop_pct series_complete_18pluspop_pct administered_dose1_pop_pct administered_dose1_recip_18plusp

* Many duplicates due to CDC error
duplicates report
duplicates drop

* Bring indices to the top
order fips days_since_apr01

* Sort by indices
sort fips days_since_apr01

* Save data
save data/cdc_county_vaccination.dta, replace

clear
