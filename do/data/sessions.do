//// Prosocial vaccination: Session data
//// Lucas Reddinger <jlr@lucasreddinger.com>
//// 2022 April 18

import delimited "data/Reddinger_Charness_Levine_prosocial_vaccination.csv", clear

rename screen_clock old_screen_clock
rename survey_clock old_survey_clock
rename sessionaclock old_sessionaclock
rename sessionbclock old_sessionbclock
gen screen_clock = clock(old_screen_clock,"DMYhms",2050)
gen survey_clock = clock(old_survey_clock,"DMYhms",2050)
gen sessionAclock = clock(old_sessionaclock,"DMYhms",2050)
gen sessionBclock = clock(old_sessionbclock,"DMYhms",2050)
format %tc screen_clock
format %tc survey_clock
format %tc sessionAclock
format %tc sessionBclock
drop old_screen_clock old_survey_clock old_sessionaclock old_sessionbclock

destring loc_zipcode, force replace


label define vaxdose 1 "Took at least one dose" 0 "Have not taken a dose"
label values vaxdose vaxdose
label variable dosemonth "When did you receive your (first) dose?"
label define dosemonth 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 99 "Unsure / Don't know"
label values dosemonth dosemonth
label variable dosetimeofmonth "When in (month)?"
label define dosetimeofmonth 1 "Early in the month (Day 1 - 10)" 11 "Middle of the month (Day 11 - 20)" 21 "Late in the month (Day 21 - 31)" 99 "Unsure / Don't know"
label values dosetimeofmonth dosetimeofmonth
label variable contrib "How much to contribute to doubling pot, 0-4 USD?"
label variable covidq10_school "Mandatory for school"
label variable covidq10_work "Mandatory for work"
label variable educ "Highest grade (or year) of regular school completed"
label define educ 1 "Fewer than 10"
label values educ educ
label define pols 3 "Republican" 2 "Democrat" 1 "Independent" 0 "Other" 9 "Don't know / Prefer not to say"
label values pols pols
label variable sessions "Num sessions participated"
label define usstate 1 "AL" 2 "AK" 3 "AZ" 4 "AR" 5 "CA" 6 "CO" 7 "CT" 8 "DE" 9 "DC" 10 "FL" 11 "GA" 12 "HI" 13 "ID" 14 "IL" 15 "IN" 16 "IA" 17 "KS" 18 "KY" 19 "LA" 20 "ME" 21 "MD" 22 "MA" 23 "MI" 24 "MN" 25 "MS" 26 "MO" 27 "MT" 28 "NE" 29 "NV" 30 "NH" 31 "NJ" 32 "NM" 33 "NY" 34 "NC" 35 "ND" 36 "OH" 37 "OK" 38 "OR" 39 "PA" 40 "PR" 41 "RI" 42 "SC" 43 "SD" 44 "TN" 45 "TX" 46 "UT" 47 "VT" 48 "VA" 49 "WA" 50 "WV" 51 "WI" 52 "WY" 53 "Not US" 
label values usstate usstate

save data/sessions.dta, replace

clear