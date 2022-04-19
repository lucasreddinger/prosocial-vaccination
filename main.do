//// Prosocial vaccination
//// Lucas Reddinger <jlr@lucasreddinger.com>, David Levine, Gary Charness
//// 2022 April 18

ssc install tsegen
ssc install egenmore

capture mkdir figures
capture mkdir logs
capture mkdir tables
capture mkdir temp

cls
clear
set more off

*******************************************************************************
*******************************************************************************
**** DATA WORK
*******************************************************************************
*******************************************************************************

* Create session participant dataset
do do/data/sessions.do

* Create US state coding dataset
do do/data/usstates.do

* Create CDC state-level vaccination dataset
do do/data/cdc_state_vaccination.do

* Create CDC county-level vaccination dataset
do do/data/cdc_county_vaccination.do

* Create CDC county-level community transmission dataset
do do/data/cdc_county_transmission.do

* Create CDC US-level COVID-19 variant distribution dataset
do do/data/cdc_variants.do

* Create ZIP-FIPS crosswalk dataset
do do/data/zip_fips_crosswalk.do

* Create US state governor political party dataset
do do/data/governor_pols.do

* Create fake FIPS timeseries to later fill in missing values
do do/data/analysis_lasso_vx1adultHazRtHat_missing.do

*******************************************************************************
*******************************************************************************
**** ANALYSIS SETUP
*******************************************************************************
*******************************************************************************

* Setup
do do/analysis/analysis_setup.do

* LASSO to predict vx1adultHazRt
do do/analysis/analysis_lasso_vx1adultHazRtHat.do

* Setup time-series
do do/analysis/analysis_setup_timeseries.do

*******************************************************************************
*******************************************************************************
**** ANALYSIS
*******************************************************************************
*******************************************************************************

* Analysis: Descriptive
do do/analysis/analysis_descriptive.do

* Analysis: Failure, Cox
do do/analysis/analysis_failure_cox.do

* Analysis: Failure, competing
do do/analysis/analysis_failure_compete.do

* Analysis: Failure, robustness checks
do do/analysis/analysis_failure_checks.do
