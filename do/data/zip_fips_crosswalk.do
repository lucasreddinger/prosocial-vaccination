//// Prosocial vaccination: ZIP-code FIPS crosswalk
//// Lucas Reddinger <jlr@lucasreddinger.com>
//// 2022 January 11
////
//// https://www.huduser.gov/portal/datasets/usps_crosswalk.html

**** Use the second line to pull current data directly from HUD
import excel "https://osf.io/w4avj/download", sheet("ZIP_COUNTY_092021") firstrow clear
*import excel "https://www.huduser.gov/portal/datasets/usps/ZIP_COUNTY_092021.xlsx", sheet("ZIP_COUNTY_092021") firstrow clear
rename ZIP zipcode
rename COUNTY fips
rename RES_RATIO res_ratio
keep zipcode fips res_ratio
destring zipcode fips, replace
duplicates report zipcode
duplicates report fips
save data/crosswalk_zip_to_fips.dta, replace

clear
