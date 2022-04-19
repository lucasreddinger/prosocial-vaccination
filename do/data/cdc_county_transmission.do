//// Prosocial vaccination: CDC county-level COVID-19 community transmission data
//// Lucas Reddinger <jlr@lucasreddinger.com>
//// 2022 January 11
////
//// https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-County-Level-of-Community-T/nra9-vzzn

**** Use the second line to pull current data directly from the CDC
import delimited "https://osf.io/w7ad5/download", clear
*import delimited "https://data.cdc.gov/api/views/nra9-vzzn/rows.csv?accessType=DOWNLOAD", clear

* We only need data until 15 August 2021
gen int days_since_apr01 = date(date,"MDY",2050) - date("2021/04/01","YMD",2050)
drop if days_since_apr01 > date("2021/08/15","YMD",2050) - date("2021/04/01","YMD",2050)

* Clean up the data
replace cases_per_100k_7_day_count_chang="" if cases_per_100k_7_day_count_chang=="suppressed"
replace cases_per_100k_7_day_count_chang=subinstr(cases_per_100k_7_day_count_chang,",","",.)
destring cases_per_100k_7_day_count_chang, replace

* Drop all the unneeded columns
drop date state_name county_name community_transmission_level

* Many duplicates due to CDC error
duplicates report
duplicates drop

* Rename an index variable
rename fips_code fips

* Bring indices to the top
order fips days_since_apr01

* Sort by indices
sort fips days_since_apr01

* Save data
save data/cdc_county_transmission.dta, replace

clear
