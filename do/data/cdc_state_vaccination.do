//// Prosocial vaccination: CDC state-level COVID-19 vaccination data
//// Lucas Reddinger <jlr@lucasreddinger.com>
//// 2022 January 11
////
//// https://data.cdc.gov/Vaccinations/COVID-19-Vaccinations-in-the-United-States-Jurisdi/unsk-b7fc

**** Use the second line to pull current data directly from the CDC
import delimited "https://osf.io/gvd5h/download", clear
*import delimited "https://data.cdc.gov/api/views/unsk-b7fc/rows.csv?accessType=DOWNLOAD", clear

rename location usstate_name
 
* Drop unneeded locations
drop if inlist(usstate_name, "VA2", "DD2", "RP", "IH2", "FM", "US", "UNK", "PW")
drop if inlist(usstate_name, "MH", "GU", "AS", "MP", "BP2", "VI", "LTC", "PR")

* Merge state codes
merge m:1 usstate_name using data/usstates.dta
drop _merge

* We only need data until 15 August 2021
gen int days_since_apr01 = date(date,"MDY",2050) - date("2021/04/01","YMD",2050)
drop if days_since_apr01 > date("2021/08/15","YMD",2050) - date("2021/04/01","YMD",2050)

* Create a variable of interest
gen dosesAvailPer100k = dist_per_100k - admin_per_100k

**** NOTICE
* Here I drop many columns that could be useful.
keep usstate days_since_apr01 dosesAvailPer100k

* Bring indices to the top
order usstate days_since_apr01

* Sort by indices
sort usstate days_since_apr01

save data/cdc_state_vaccination.dta, replace

clear
