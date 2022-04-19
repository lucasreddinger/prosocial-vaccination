//// Prosocial vaccination: CDC variant data
//// Lucas Reddinger <jlr@lucasreddinger.com>
//// 2022 January 12
////
//// https://covid.cdc.gov/covid-data-tracker/#variant-proportions

**** Use the second line to pull current data directly from the CDC
import delimited "data/cdc_variants.csv", clear

destring _all, replace

* For now, for simplicity, only use the US-wide figures.
* In the future, we could use region-specific data.
keep if usaorhhsregion=="USA"

* Only Delta VoC matters for the Summer of 2021
keep if variant=="B.1.617.2"

* We only need data until 15 August 2021
gen int days_since_apr01 = date(dayofweekending,"MDY",2050) - date("2021/04/01","YMD",2050)
drop if days_since_apr01 > date("2021/08/15","YMD",2050) - date("2021/04/01","YMD",2050)

* Clean up the data
rename share prop_delta
replace prop_delta=prop_delta*100
keep days_since_apr01 prop_delta

* Bring indices to the top
order days_since_apr01

* Sort by indices
sort days_since_apr01

* Save data
save data/cdc_variants.dta, replace

clear
