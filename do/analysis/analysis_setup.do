capture log close
log using logs/analysis_setup.txt, text replace
//// Prosocial vaccination: Analysis Setup
//// Lucas Reddinger <jlr@lucasreddinger.com>, David Levine, Gary Charness
//// 2022 January 10

use data/sessions.dta, clear

**** Descriptive graphs and statistics for all three sessions

egen screenClockMin = min(screen_clock)
egen screenClockMax = max(screen_clock)
egen sessionAclockMin = min(sessionAclock)
egen sessionAclockMax = max(sessionAclock)
egen sessionBclockMin = min(sessionBclock)
egen sessionBclockMax = max(sessionBclock)
format %tc screenClockMin
format %tc screenClockMax
format %tc sessionAclockMin
format %tc sessionAclockMax
format %tc sessionBclockMin
format %tc sessionBclockMax
list screenClockMin in 1/1
list screenClockMax in 1/1
list sessionAclockMin in 1/1
list sessionAclockMax in 1/1
list sessionBclockMin in 1/1
list sessionBclockMax in 1/1

tab sessions, mi

**** Reload data
use data/sessions.dta, clear

**** Only keep participants who completed all sessions
keep if sessions==3

**** Generate variables to use in analysis

** Mandatory vaccination

* Consider a vaccine mandatory if required for school or work
gen vaxmand = (covidq10_school==1 | covidq10_work==1) if !missing(covidq10_school, covidq10_work)

tab vaxmand covidq10_school, mi
tab vaxmand covidq10_work, mi

tab vaxdose vaxmand if missing(loc_zipcode), mi

* Indicator that respondent got vaccinated and it was mandated
gen vaxdoseMand = ( vaxdose == 1 & vaxmand == 1 ) if !missing(vaxdose, vaxmand)
* Indicator that respondent got vaccinated and it was not mandated
gen vaxdoseNotMand = ( vaxdose == 1 & vaxmand == 0 ) if !missing(vaxdose, vaxmand)

tab vaxdoseMand vaxdose, mi
tab vaxdoseMand vaxmand, mi
tab vaxdoseNotMand vaxdose, mi
tab vaxdoseNotMand vaxmand, mi

** Timing of first dose
* Everyone in our sample was unvaccinated as of April 7-27, 2021.
* We will set dosedate=21 for all obs with dosemonth==4, which is
* halfway between general availability of vaccines (April 15th)
* and the end of this particular date bin.
replace dosemonth = . if dosemonth == 99
replace dosetimeofmonth = . if dosetimeofmonth == 99
gen dosedate = .
replace dosedate = 21          if dosemonth == 4
replace dosedate = 30          if dosemonth == 5 & !missing(dosetimeofmonth)
replace dosedate = 30+31       if dosemonth == 6 & !missing(dosetimeofmonth)
replace dosedate = 30+31+30    if dosemonth == 7 & !missing(dosetimeofmonth)
replace dosedate = 30+31+30+31 if dosemonth == 8 & !missing(dosetimeofmonth)
* We add 5 days to use the midpoint of each 10-day range.
replace dosedate = dosedate + dosetimeofmonth + 5 if !missing(dosetimeofmonth) & !(dosemonth==8 & dosetimeofmonth==11)
* Except for Aug 11-13, to which we add only one day.
replace dosedate = dosedate + dosetimeofmonth + 2 if !missing(dosetimeofmonth) & (dosemonth==8 & dosetimeofmonth==11)

tab dosedate, mi

label define dosedate 21 "Apr 7-30" 36 "May 1-10" 46 "May 11-20" 56 "May 21-31" 67 "Jun 1-10" 77 "Jun 11-20" 87 "Jun 21-30" 97 "Jul 1-10" 107 "Jul 11-20" 117 "Jul 21-31" 128 "Aug 1-10" 135 "Aug 11-13"
label values dosedate dosedate
label variable dosedate "Date of first vaccine dose"

tab dosemonth dosedate, mi

** Political scale

label define pols2 3 "Republican" 2 "Democrat" 1 "Other"

gen pols2=pols
replace pols2=1 if pols==0
label values pols2 pols2

tab pols pols2, mi

**** SAVE DATA
save data/analysis.dta, replace

clear

capture log close