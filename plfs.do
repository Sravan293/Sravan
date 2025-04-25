clear

* Working Directory
cd "C:\Users\APF\Desktop\CEDA test"
log using "filename.log", replace
*Loading Data
use "C:\Users\APF\Desktop\CEDA test\PLFS17_18\data\raw\level01_FV.dta"
br

* Creating Weigths Variable as per read me file
gen weight = multiplier/200
save "hh_data.dta", replace


* Load person-level data
use "C:\Users\APF\Desktop\CEDA test\PLFS17_18\data\raw\level02_FV.dta"
br
gen weight = multiplier/200
save "person_data.dta", replace





* Q1(i): Average HH consumption by state
* Load household data
use "hh_data.dta", clear

* Collapse to get weighted mean by state
collapse (mean) household_cons_expenditure_month [aw=weight], by(state)

* Sort and keep top 5
gsort -household_cons_expenditure_month
gen rank = _n
keep if rank <= 5

* Create a label for state names if not already labeled
label variable state "State"
label variable household_cons_expenditure_month "Avg. Monthly HH Consumption"

* Save current table for manual LaTeX export
list state household_cons_expenditure_month, clean noobs

* Use estout package to manually format output
estpost tabstat household_cons_expenditure_month, by(state) ///
    stats(mean) columns(statistics)

* Exporting to Latex Format
esttab using conexp_top5states.tex, replace ///
    cells("mean(fmt(2))") ///
    label title("Top 5 States by Mean Household Consumption (Monthly)") ///
    varlabels(state "State" household_cons_expenditure_month "Avg. Monthly HH Consumption") ///
    booktabs nonumber nostar alignment(D{.}{.}{-1})
	
	
	
	
	
	

* Q1(ii): Deciles of HH consumption
use "hh_data.dta", clear
gen exp=household_cons_expenditure_month

* Step 1: Generate decile variable using xtile
xtile decile = exp [aw=weight], nq(10)
gen deciles = "Decile" + string(decile)
save "hh_data.dta", replace

* Step 2: Get decile upper bounds (cutoffs)
collapse (max) exp [aw= weight], by(decile)

* Step 3: Rename and show clean output
rename exp decile_cutoff
list decile decile_cutoff
label variable decile "Decile"
label variable decile_cutoff "Decile Cutoff"

estpost tabstat decile_cutoff, by(decile) stats(max) columns(statistics)

* Exporting to Latex
esttab using decile_table.tex, replace ///
    cells("max(fmt(0))") ///
    label title("Decile-wise Cutoff Table (Max Value in Each Decile)") ///
    varlabels(decile "Decile" decile_cutoff "Decile Cutoff") ///
    booktabs nonumber nostar alignment(D{.}{.}{-1})
	
	
	
	



* Q1(iii): Employment proportions (15-59)
use "person_data.dta", clear
keep if age >= 15 & age <= 59
tab pr_status_code
tab pr_status_code, nolabel

* Droping other Gender other than Male and Female
drop if sex==3

* Creating employment rate at varies Principle statuses
gen employed = inlist(pr_status_code, 11,12,21,31,41,51)
gen emp11 =1 if pr_status_code==11
replace emp11=0 if pr_status_code!=11
gen emp12 =0
replace emp12=1 if pr_status_code==12
gen emp21=0
replace emp21=1 if pr_status_code==21
gen emp31=0
replace emp31=1 if pr_status_code==31
gen emp41=0
replace emp41=1 if pr_status_code==41
gen emp51=0
replace emp51=1 if pr_status_code==51
save "person_data.dta", replace

* Testing for Significance
prtest employed, by(sex)
prtest emp11, by(sex)
prtest emp12, by(sex)
prtest emp21, by(sex)
prtest emp31, by(sex)
prtest emp41, by(sex)
prtest emp51, by(sex)

* Creating Latex Table
collapse (mean) emp11 emp12 emp21 emp31 emp41 emp51 employed [aw=weight], by(sex)
estpost tabstat emp11 emp12 emp21 emp31 emp41 emp51 employed, by(sex) stats(mean) columns(statistics)
esttab using emp_status_by_sex.tex, replace ///
    cells("mean(fmt(3))") ///
    label title("Proportion Employed by Principal Status (Age 15–59)") ///
    varlabels(emp11 "Own Account Worker (11)" emp12 "Employer (12)" emp21 " hh enterprise(21)" ///
              emp31 "Regular Salaried (31)" emp41 "Casual Public (41)" emp51 "Casual Other(51)" employed "Total Employed") ///
    booktabs nonumber nostar alignment(D{.}{.}{-1})
	
	
	


* Q1(iv): Female employment by decile
use "person_data.dta", clear
merge m:1 common_id using "hh_data.dta"
drop if _merge != 3
keep if sex == 2 & age >= 15 & age <= 59
br
collapse (mean) employed [aw=weight], by(decile)

* Grapg by decile for total female employed
graph bar employed, over(decile, label(angle(0))) ///
    bar(1, color(blue)) ///
    ytitle("Employment Rate") ///
    title("Female Employment Rate by MPCE Decile") ///
    ylabel(0(.05).35) ///
    blabel(bar, format(%4.2f)) ///
    legend(off)
graph export "Female_employment_over_deciles.pdf", replace

* Graph by Decile Female Salaried Employment
use "person_data.dta", clear
merge m:1 common_id using "hh_data.dta"
drop if _merge != 3
keep if sex == 2 & age >= 15 & age <= 59
br
collapse (mean) emp31 [aw=weight], by(decile)
graph bar emp31, over(decile, label(angle(0))) ///
    bar(1, color(blue)) ///
    ytitle("Salaried Employment") ///
    title("Female Employment Rate by MPCE Decile") ///
    ylabel(0(.05).35) ///
    blabel(bar, format(%4.2f)) ///
    legend(off)
graph export "Female_Salaried_employment_over_deciles.pdf", replace





* Q1(v): Daily Wage Rate by Salaried, Casaul and Self employment
use "person_data.dta", clear

gen total_casual_wage = 0
forvalues d = 1/7 {
    foreach act in 1 2 {
        local dayname = word("1stday 2ndday 3rdday 4thday 5thday 6thday 7thday", `d')
        replace total_casual_wage = total_casual_wage + ///
            wage_earning_act_`act'_`dayname' if inlist(status_code_act_`act'_`dayname', 41, 42, 51)
    }
}
gen daily_casual_wage = total_casual_wage / 7
replace daily_casual_wage = . if total_casual_wage == 0


gen daily_salaried_wage = earning_regular_wage_1/30
replace daily_salaried_wage = . if curr_weekly_status!=31

gen daily_selfemp_wage = .
replace daily_selfemp_wage = earning_regular_wage_2/30 if inlist(curr_weekly_status, 11,12,21)
save "wage_data.dta", replace







* Q1(vi): Overall wage and caste-wise average
use "wage_data.dta", clear
merge m:1 common_id using "hh_data.dta"
drop if _merge != 3
gen daily_wage_rate = .
replace daily_wage_rate =daily_salaried_wage  if !missing(daily_salaried_wage)
replace daily_wage_rate = daily_selfemp_wage  if missing(daily_wage_rate) & !missing(daily_selfemp_wage)
save "wage_data.dta", replace
replace daily_wage_rate = daily_casual_wage if missing(daily_wage_rate) & !missing(daily_casual_wage)
collapse (mean) daily_wage_rate [aw=weight], by(social_group)
graph bar daily_wage_rate, over(social_group, label(angle(45))) bar(1, color(blue)) ///
    title("Daily Wage by Social Group") ///
    ytitle("Daily Wage (Rs.)")
graph export "Daily_wage.pdf", replace





* Q1(vii): Gender wage gap regression
use "wage_data.dta", clear
keep if age >= 15 & age <= 59 & !missing(daily_wage_rate)
gen log_wage = log(daily_wage_rate)
save "wage_data.dta", replace
eststo m1: reg log_wage i.sex age [aw=weight]
eststo m2: reg log_wage i.sex age i.education_level [aw=weight]
eststo m3: reg log_wage i.sex age i.education_level i.district [aw=weight]
eststo m4: reg log_wage i.sex age i.education_level i.district i.pr_nco_code [aw=weight]
eststo m5: reg log_wage i.sex age i.education_level i.district i.pr_nco_code i.month_survey [aw=weight]

* Step 3: Export to LaTeX showing only main vars
esttab m1 m2 m3 m4 m5 using gender_wagegap.tex, replace ///
    keep(2.sex age 2.education_level 3.education_level 4.education_level 5.education_level 6.education_level 7.education_level 8.education_level 10.education_level 11.education_level 12.education_level 13.education_level) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label title("Gender Wage Gap Regressions") ///
    addnotes("All models control for additional covariates as indicated.") ///
	compress

	
	
	
	
	
	
	
* Q1(viii): DiD for policy effect on salaried workers
use "wage_data.dta", clear
gen post_policy = (month_survey >= 1 & month_survey <=8)
gen female = (sex == 2)
gen treated = (pr_status_code == 31)
gen did = post_policy * female
eststo m6: reg log_wage post_policy female did age i.education [aw=weight] ///
    if treated == 1 & age >= 15 & age <= 59
esttab m6 using did.tex, replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label title("Gender Wage Gap Regression") ///
    compress
	
log close
