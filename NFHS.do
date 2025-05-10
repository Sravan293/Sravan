clear
* Setting up working directory
cd "C:\Users\APF\Desktop\IIMA test"

* My version of STATA by default only supports 5000 variables, so increasing it to 120000
set maxvar 120000

* Loading the NFHS-5 Data Set
use "C:\Users\APF\Desktop\IIMA test\NFHS5.dta"
br


* Aswering Question 1

* Looking for which variable corresponds to hysterectomy
* I found that "s253" corresponds to question on hysterectomy
lookfor hysterectomy
tab s253
tab s253, nolabel

* Looking for which variable corresponds to PSU identifier, it is "v021"
lookfor Primary Sampling Unit
tab v021

* Creating variable for strict definition of hysterectomy
gen hysterectomy1 = .
replace hysterectomy1 =1 if s253==1
replace hysterectomy1 =0 if s253==0

* Creating variable for Loose definition of Hysterectomy
gen hysterectomy2 = 0
replace hysterectomy2 =1 if s253==1
tab hysterectomy2
save "NFHS5.dta", replace

* Finding mean hysterectomy by PSU unit
collapse (mean) hysterectomy1, by(v021)
rename hysterectomy1 hysterectomy_rate_strict
br

* Creating a histogram
hist hysterectomy_rate_strict, width(0.1) percent ///
    title("Histogram of PSU Hysterectomy Rates (Strict)") ///
    xtitle("Proportion of women with hysterectomy in PSU") ///
    ytitle("Percentage of PSUs") ///
    scheme(s1color)
* Saving histogram into my laptop
graph export "C:\Users\APF\Desktop\IIMA test\hysterectomy_strict.png", as(png) name("Graph")

* Summarizing to find mean and variability across PSUs
summarize hysterectomy_rate_strict, detail



* Answering Question 2

* Modelling for all women sample
use "nfhs5.dta", clear

* Counting number of women per PSU
bysort v021: gen women_count = _N

* Generating total number of hysterectomies per PSU
bysort v021 (hysterectomy2): gen sum_hyst = sum(hysterectomy2)
bysort v021: replace sum_hyst = sum_hyst[_N]

*  Calculating number of peers undergone hysterectomy by removing woman's own value
gen peer_sum = sum_hyst - hysterectomy2

* Calculating peer average (excluding self)
gen peer_avg = peer_sum / (women_count - 1)

* Handling cases where PSU only has 1 woman (to avoid division by 0)
replace peer_avg = . if women_count == 1
br

* Regression Robust standard errors
logit hysterectomy2 peer_avg, robust
outreg2 using "logit_model_loose_definition.doc", replace ctitle("Logit Regression for loose definition of Hysterectomy")
* Calculating marginal effects
margins, dydx(peer_avg)

* For women who give response for the question on hysterectomy as either yes or no
drop if missing(hysterectomy1)
bysort v021: gen women_count1 = _N

* Generating total number of hysterectomies per PSU
bysort v021 (hysterectomy1): gen sum_hyst1 = sum(hysterectomy1)
bysort v021: replace sum_hyst1 = sum_hyst1[_N]

* Calculating number of peers undergone hysterectomy by removing woman's own value
gen peer_sum1 = sum_hyst1 - hysterectomy1

* Calculating peer average (excluding self)
gen peer_avg1 = peer_sum1 / (women_count1 - 1)

* Handling cases where PSU only has 1 woman (to avoid division by 0)
replace peer_avg1 = . if women_count1 == 1

* Regression logit model
logit hysterectomy1 peer_avg1, robust
outreg2 using "logit_model_strict_definition.doc", replace ctitle("Logit Regression for strict definition of Hysterectomy")
* calculating marginal effects
margins, dydx(peer_avg1)



*Answering Question 3

* Keeping only women who had hysterectomy
keep if hysterectomy1 == 1

* Counting number of hysterectomies per PSU
bysort v021: gen number_hysterectomy = _N

* Keeping only PSUs with more than one hysterectomy
keep if number_hysterectomy > 1
br

lookfor hysterectomy


* Sorting data by PSU and year of hysterectomy
bysort v021 (s254): gen hysterectomy_lag = .

* Calculating the lag for women in the same PSU based on years ago hysterectomy performed
bysort v021 (s254): replace hysterectomy_lag = s254[_n+1] - s254[_n] if _n < _N
bysort v021 (s254): replace hysterectomy_lag = s254[_n] - s254[_n-1] if _n > 1
br

* Calculating and storing mean lag by PSU
collapse (mean) hysterectomy_lag, by(v021)
br

* Histogram for average age
hist hysterectomy_lag if hysterectomy_lag >= 0 & hysterectomy_lag <= 40, ///
    width(2) percent start(0) ///
    xlab(0(2)40) ///
    title("Histogram of PSU Hysterectomy Average Lag") ///
    xtitle("Hysterectomy Average Lag (Years)") ///
    ytitle("Percentage of PSUs") ///
    scheme(s1color)
* Exporting histogram
graph export "C:\Users\APF\Desktop\IIMA test\Average lag between hysterectomies.png", as(png) name("Graph")
	

	
* Answering Question 4 

use "nfhs5.dta", clear
* Step 1: Keeping only women who had hysterectomy
keep if hysterectomy1 == 1

* Finding and assigning number of hysterectomies for PSU
bysort v021 (s254): gen hyst_count = _N

* Creating a group for PSUs with only one hysterectomy
gen group_one = (hyst_count == 1)

* Creating a group for PSUs with exactly two hysterectomies
gen group_two = (hyst_count == 2)
keep if hyst_count<=2
br

* Assigning number 1 for first hysterectomy and number 2 for second hysterectomy based on years ago hysterectomy performed
bysort v021 (s254): gen hyst_order = _N - _n + 1 if _N == 2

* Testing whether there is difference between time of hysterectomy in btween group 1 and group 2
gen compare_group = .
replace compare_group = 1 if group_one == 1
replace compare_group = 2 if hyst_order == 1
ttest s254 if inlist(compare_group, 1, 2), by(compare_group)

* Testing whether there is difference between first women and second women in age
ttest v012, by(hyst_order)

* Testing whether there is education diferrence between first women and second women
lookfor education
ttest v133, by(hyst_order)

* Testing whether there is difference in age at hysterectomy between first and second women
gen age_at_hysterectomy = v012-s254
ttest age_at_hysterectomy, by(hyst_order)


* Additional excercise for some self clarification
* Testing whether missing value for question on hysterectomy is randon
use "nfhs5.dta", clear
gen miss = 1
replace miss =0 if !missing(hysterectomy1)
lookfor religion
lookfor caste

logit miss v012 v133 i.v130 i.s116, robust
























































