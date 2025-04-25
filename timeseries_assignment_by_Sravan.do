import excel "C:\Users\APF\Downloads\CPIndex_Jan11-To-Jan13.xlsx",firstrow clear
gen date = ym(2011,1)+_n-1
format date %tm
browse
tsset date




* Rural
tsline Rural
dfuller Rural, trend
generate didrural = D.Rural
browse
tsline didrural
dfuller didrural

*Identification
ac didrural
pac didrural

arima Rural, arima(1,1,1)
estimates store RARIMA111

arima Rural, arima(2,1,1)
estimates store RARIMA211

arima Rural, arima(4,1,1)
estimates store RARIMA411

arima Rural, arima(2,1,5)
estimates store RARIMA215

arima Rural, arima(4,1,5)
estimates store RARIMA415

arima Rural, arima(1,1,5)
estimates store RARIMA115


arima Rural, arima(1,1,0)
estimates store RARIMA110

arima Rural, arima(0,1,1)
estimates store RARIMA011
estimates stats RARIMA110 RARIMA011 RARIMA111 RARIMA211 RARIMA411 RARIMA115 RARIMA215 RARIMA415

* Estimation
arima Rural, arima(2,1,5) 
predict rerror, resid
wntestq rerror
estat aroots

arima Rural, arima(4,1,5) 
predict rerror1, resid
wntestq rerror1
estat aroots

arima Rural, arima(4,1,1) 
predict rerror2, resid
wntestq rerror2
estat aroots

arima Rural if date <=tm(2023m8), arima(4,1,1)
predict onestep_forecasterural, xb
tsline didrural onestep_forecasterural
gen forecaste_error = didrural-onestep_forecasterural if date >tm(2023m8)

predict dyforecast_rural, dynamic(tm(2023m8))
tsline didrural dyforecast_rural
gen dynamic_error = didrural-dyforecast_rural if date >tm(2023m8)

tsline forecaste_error dynamic_error if date >tm(2023m8)
tsline didrural onestep_forecasterural dyforecast_rural if date >tm(2023m8)

* Totalling Errors
total(forecaste_error) if date >tm(2023m8) 
total(dynamic_error) if date >tm(2023m8)


* Urban
tsline Urban
dfuller Urban, trend
generate didurban = D.Urban
tsline didurban
dfuller didurban

*Identification
ac didurban
pac didurban

arima Urban, arima(1,1,1)
estimates store UARIMA111

arima Urban, arima(2,1,1)
estimates store UARIMA211

arima Urban, arima(4,1,1)
estimates store UARIMA411

arima Urban, arima(2,1,5)
estimates store UARIMA215

arima Urban, arima(4,1,5)
estimates store UARIMA415

arima Urban, arima(1,1,5)
estimates store UARIMA115


arima Urban, arima(1,1,0)
estimates store UARIMA110

arima Urban, arima(0,1,1)
estimates store UARIMA011
estimates stats UARIMA110 UARIMA011 UARIMA111 UARIMA211 UARIMA411 UARIMA115 UARIMA215 UARIMA415

* Estimation
arima Urban, arima(4,1,5) 
predict Uerror, resid
wntestq Uerror
estat aroots

arima Urban, arima(4,1,1) 
predict uerror1, resid
wntestq uerror1
estat aroots

arima Urban if date <=tm(2023m8), arima(4,1,1)
predict onestep_forecasteurban, xb
tsline didurban onestep_forecasteurban
gen forecaste_error1 = didurban-onestep_forecasteurban if date >tm(2023m8)

predict dyforecast_urban, dynamic(tm(2023m8))
tsline didurban dyforecast_urban
gen dynamic_error1 = didurban-dyforecast_urban if date >tm(2023m8)

tsline forecaste_error1 dynamic_error1 if date >tm(2023m8)
tsline didurban onestep_forecasteurban dyforecast_urban if date >tm(2023m8)

* Totalling Errors
total(forecaste_error1) if date >tm(2023m8) 
total(dynamic_error1) if date >tm(2023m8)

* Combined
tsline Combined
dfuller Combined, trend
generate didcombined = D.Combined
tsline didcombined
dfuller didcombined

*Identification
ac didcombined
pac didcombined

arima Combined, arima(1,1,1)
estimates store CARIMA111

arima Combined, arima(2,1,1)
estimates store CARIMA211

arima Combined, arima(4,1,1)
estimates store CARIMA411

arima Combined, arima(2,1,5)
estimates store CARIMA215

arima Combined, arima(4,1,5)
estimates store CARIMA415

arima Combined, arima(1,1,5)
estimates store CARIMA115


arima Combined, arima(1,1,0)
estimates store CARIMA110

arima Combined, arima(0,1,1)
estimates store CARIMA011
estimates stats CARIMA110 CARIMA011 CARIMA111 CARIMA211 CARIMA411 CARIMA115 CARIMA215 CARIMA415

*Estimation 
arima Combined, arima(2,1,5) 
predict cerror, resid
wntestq cerror
estat aroots

arima Combined, arima(4,1,5) 
predict cerror1, resid
wntestq cerror1
estat aroots

arima Combined, arima(4,1,1) 
predict cerror2, resid
wntestq cerror2
estat aroots

arima Combined if date <=tm(2023m8), arima(4,1,1)
predict onestep_forecastecombined, xb
tsline didcombined onestep_forecastecombined
gen forecaste_error2 = didcombined-onestep_forecastecombined if date >tm(2023m8)

predict dyforecast_combined, dynamic(tm(2023m8))
tsline didcombined dyforecast_combined
gen dynamic_error2 = didcombined-dyforecast_combined if date >tm(2023m8)

tsline forecaste_error2 dynamic_error2 if date >tm(2023m8)
tsline didcombined onestep_forecastecombined dyforecast_combined if date >tm(2023m8)

* Totalling Errors
total(forecaste_error2) if date >tm(2023m8) 
total(dynamic_error2) if date >tm(2023m8)


* For all Rural, Urban, Combined one-step forecaste is better than the Dynamic one, so I am doing one-step forecasting
* Forecasting
tsappend, add(6)

* Forecasting Rural CPI
arima Rural if date <=tm(2024m8), arima(4,1,1)
predict didrural_forecaste, xb
tsline didrural didrural_forecaste

 
* Forcasting Urban CPI
arima Urban if date <=tm(2024m8), arima(4,1,1)
predict didurban_forecaste, xb
tsline didurban didurban_forecaste

* Forcasting Combined CPI
arima Combined if date <=tm(2024m8), arima(4,1,1)
predict didcombined_forecaste, xb
tsline didcombined didcombined_forecaste
 








