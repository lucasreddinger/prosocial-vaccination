capture log close
log using logs/analysis_descriptive.txt, text replace
//// Prosocial vaccination: Analysis - Descriptive
//// Lucas Reddinger <jlr@lucasreddinger.com>, David Levine, Gary Charness
//// 2022 April 8
set scheme s2mono

**** Descriptive graphs and statistics

use data/analysis.dta, clear

* Average time at which subjects originally reported being unvaccinated
sum screen_clock
di %tc r(mean)
di %tc r(min)
di %tc r(max)

* Session A: subjects report dosedate
sum sessionAclock
di %tc r(mean)
di %tc r(min)
di %tc r(max)

* Session B: subjects play games
sum sessionBclock
di %tc r(mean)
di %tc r(min)
di %tc r(max)

bysort loc_zipcode: gen zipcode_dup = cond(_N==1,0,_n)
tab zipcode_dup, mi
drop zipcode_dup

tab vaxdose vaxmand, mi

tab dosedate vaxdose, mi

tab dosemonth vaxdose, mi

* Histograph: contrib

summarize contrib, detail
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local sd = round(r(sd), 0.01)
local min = r(min)
local max = r(max)

hist contrib, percent discrete title("Contribution in game ($)") xtitle("") ///
text( 39 -0.3 "mean     `mean'" "median  `median'" "sd          `sd'" "min        `min'" "max       `max'" , ///
place(se) tstyle(body) linegap(2pt) j(left)) ysize(3) xsize(3) scale(1.2) ///
yla(0(10)40) ytitle("Percent") lcolor(midgreen) fcolor(midgreen%60)

graph export figures/figure_hist_contrib.png, replace
graph export figures/figure_hist_contrib.pdf, replace

hist contrib, percent discrete title("Contribution in game ($)") xtitle("") ///
text( 39 -0.3 "mean     `mean'" "median  `median'" "sd          `sd'" "min        `min'" "max       `max'" , ///
place(se) tstyle(smbody) linegap(2pt) j(left)) ysize(2) xsize(3) ///
yla(0(10)40) ytitle("Percent") lcolor(midgreen) fcolor(midgreen%60)
graph save temp/hist_contrib.gph, replace

* Histograph: age

summarize age, detail
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local sd = round(r(sd), 0.01)
local min = r(min)
local max = r(max)

hist age, percent w(5) title("Years of age") ytitle("Percent") xtitle("") ///
text( 39 18 "mean     `mean'" "median  `median'" "sd          `sd'" "min        `min'" "max       `max'" , ///
place(se) tstyle(body) linegap(2pt) j(left)) ysize(3) xsize(3) scale(1.2) ///
yla(0(10)40) lcolor(midgreen) fcolor(midgreen%60)
graph export figures/figure_hist_age.png, replace
graph export figures/figure_hist_age.pdf, replace

hist age, percent w(5) title("Years of age") ytitle("Percent") xtitle("") ///
text( 39 18 "mean     `mean'" "median  `median'" "sd          `sd'" "min        `min'" "max       `max'" , ///
place(se) tstyle(smbody) linegap(2pt) j(left)) ysize(2) xsize(3) ///
yla(0(10)40) lcolor(midgreen) fcolor(midgreen%60)
graph save temp/hist_age.gph, replace

* Histograph: educ

summarize educ if educ>1, detail
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local sd = round(r(sd), 0.01)
local min = r(min)
local max = r(max)

hist educ if educ>1, percent discrete title("Years of education") ytitle("Percent") ///
text( 39 9.5 "mean     `mean'" "median  `median'" "sd          `sd'" "min        `min'" "max       `max'", ///
place(se) tstyle(body) linegap(2pt) j(left)) ysize(3) xsize(3) yla(0(10)40) ///
xtitle("") xla(10 12 14 16 18 20) scale(1.2) lcolor(midgreen) fcolor(midgreen%60)
graph export figures/figure_hist_educ.png, replace
graph export figures/figure_hist_educ.pdf, replace

hist educ if educ>1, percent discrete title("Years of education") ytitle("Percent") ///
text( 39 9.5 "mean     `mean'" "median  `median'" "sd          `sd'" "min        `min'" "max       `max'", ///
place(se) tstyle(smbody) linegap(2pt) j(left)) ysize(3) xsize(3) yla(0(10)40) ///
xtitle("") xla(10 12 14 16 18 20) lcolor(midgreen) fcolor(midgreen%60)
graph save temp/hist_educ.gph, replace

* Histograph: pols2

graph bar, over(pols2, rev) blabel(bar,format(%04.1f)) ytitle("Percent") ///
title("Political identity") ysize(3) xsize(3) scale(1.2) yla(0(10)40) ///
bar(1, color(midgreen) fcolor(midgreen%60))
graph export figures/figure_bar_pols2.png, replace
graph export figures/figure_bar_pols2.pdf, replace

graph bar, over(pols2, rev) blabel(bar,format(%04.1f)) ytitle("Percent") ///
title("Political identity") ysize(2) xsize(3) yla(0(10)40) ///
bar(1, color(midgreen) fcolor(midgreen%60))
graph save temp/bar_pols2.gph, replace

**** Bar graph of participant counts by dosedate
use data/analysis.dta, clear

drop if missing(vaxdose)

tab dosemonth dosedate, mi

egen dosedateN = total(!missing(dosedate))
sum dosedateN
egen dosemonthN = total(!missing(dosemonth))
sum dosemonthN

replace dosedate=150 if missing(dosedate)

graph bar (count), blabel(bar, margin(b=0)) over(dosedate, label(angle(45) labsize(medsmall)) relabel(1 "Apr 10-30" 2 "May 1-10" 3 "May 11-20" 4 "May 21-31" 5 "Jun 1-10" 6 "Jun 11-20" 7 "Jun 21-30" 8 "Jul 1-10" 9 "Jul 11-20" 10 "Jul 21-31" 11 "Aug 1-10" 12 "Aug 11-13" 13 "No dose*")) title("Number of participants by date of first vaccine dose", margin(b=2)) ytitle("Count", margin(r=2)) note("* These subjects reported having taken no dose as of August 12-13." "{it:Notes:} Responses collected Aug 12-13. Excluded are 3 subjects unsure when in May they took their" "first dose, 1 unsure when in June, 3 unsure of the month, and 3 who didn't report vaccination status.", size(small) margin(t=2)) b1title("Date of first COVID-19 vaccine dose") bar(1, color(midgreen) fcolor(midgreen%60)) yscale(range(0 325)) ysize(4) xsize(6)
graph export figures/figure_bar_participants_by_dosedate.png, replace
graph export figures/figure_bar_participants_by_dosedate.pdf, replace

graph bar (count), blabel(bar, margin(b=0)) over(dosedate, label(angle(45) labsize(medsmall)) relabel(1 "Apr 10-30" 2 "May 1-10" 3 "May 11-20" 4 "May 21-31" 5 "Jun 1-10" 6 "Jun 11-20" 7 "Jun 21-30" 8 "Jul 1-10" 9 "Jul 11-20" 10 "Jul 21-31" 11 "Aug 1-10" 12 "Aug 11-13" 13 "No dose*")) title("Number of participants by date of first vaccine dose", margin(b=2)) ytitle("Count", margin(r=2)) note("* These subjects reported having taken no dose as of August 12-13." "{it:Notes:} Responses collected Aug 12-13. Excluded are 3 subjects unsure when in May they took their" "first dose, 1 unsure when in June, 3 unsure of the month, and 3 who didn't report vaccination status.", size(small) margin(t=2)) b1title("Date of first COVID-19 vaccine dose") bar(1, color(midgreen) fcolor(midgreen%60)) yscale(range(0 325)) ysize(4) xsize(6) scale(0.8)
graph save temp/bar_participants_by_dosedate.gph, replace

graph close

**** Scatterplot of participants by dosedate and contrib
use data/analysis.dta, clear

replace dosedate=150 if missing(dosedate) & vaxdose==0

collapse (count) obs=subject_id, by(contrib vaxdoseNotMand vaxdose dosedate)
scatter contrib dosedate if vaxdoseNotMand==1 [w=obs], mcolor(blue%25) msymbol(O) mlstyle(color(black%25)) || scatter contrib dosedate if vaxdoseNotMand==0 & vaxdose==1 [w=obs], mcolor(red%25) msymbol(O) mlstyle(color(black%25)) || scatter contrib dosedate if vaxdose==0 [w=obs], xlabel(21 "Apr 10-30" 36 "May 1-10" 46 "May 11-20" 56 "May 21-31" 67 "Jun 1-10" 77 "Jun 11-20" 87 "Jun 21-30" 97 "Jul 1-10" 107 "Jul 11-20" 117 "Jul 21-31" 128 "Aug 1-10" 135 "Aug 11-13" 150 "No dose*", angle(45) labsize(medsmall)) xscale(range(10 160)) xtitle("Date of first COVID-19 vaccine dose") ytitle("Contribution in a public-good game ($)", margin(r=2)) yscale(range(-0.5 4.5)) mcolor(yellow%25) msymbol(O) mlstyle(color(black%25)) legend(label(1 "Vaccinated not by mandate") label(2 "Vaccinated by mandate") label(3 "Unvaccinated") cols(3) size(small)) title("Participants by contribution and vaccination status", margin(b=2)) note("* These subjects reported having taken no dose as of August 12-13." "{it:Notes:} Responses collected Aug 12-13. Excluded are 3 subjects unsure when in May they took their" "first dose, 1 unsure when in June, 3 unsure of the month, and 3 who didn't report vaccination status.", size(small) margin(t=2)) ysize(4) xsize(6)

graph export figures/figure_plot_participants_by_dosedate_contrib.png, replace
graph export figures/figure_plot_participants_by_dosedate_contrib.pdf, replace

graph close

**** Combine graphs

graph combine temp/hist_contrib.gph temp/hist_age.gph temp/hist_educ.gph temp/bar_pols2.gph, ysize(4) xsize(6) cols(2) imargin(2 2 2 2)
graph save temp/characteristics.gph, replace

graph combine temp/characteristics.gph temp/bar_participants_by_dosedate.gph, ysize(8) xsize(6) cols(1) imargin(1 1 1 1)
graph export figures/figure_characteristics_all.png, replace
graph export figures/figure_characteristics_all.pdf, replace

graph close

clear

capture log close