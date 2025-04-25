import excel "C:\Time Series Assignment\Stata\Data.xlsx", sheet("Sheet1") firstrow
drop in 286/294
gen date = tm(2000m1)+_n-1
format date %tm
tsset date
gen lnBSE = log(BSE)
gen lnExchangeRate = log(ExchangeRate)
gen lnSP = log(SP)
gen lnM2 = log(M2)
tsline lnBSE
dfuller lnBSE
pperron lnBSE
dfuller lnBSE, trend
tsline lnExchangeRate
dfuller lnExchangeRate
pperron lnExchangeRate
tsline lnSP
dfuller lnSP
pperron lnSP
tsline lnM2
dfuller lnM2
pperron lnM2
gen dlnBSE = d.lnBSE
gen dlnExchangeRate = d.lnExchangeRate
gen dlnSP = d.lnSP
gen dlnM2 = d.lnM2
tsline dlnBSE
dfuller dlnBSE
pperron dlnBSE
dfuller dlnBSE, trend
tsline dlnExchangeRate
dfuller dlnExchangeRate
pperron dlnExchangeRate
tsline dlnSP 
dfuller dlnSP 
pperron dlnSP
tsline dlnM2
dfuller dlnM2
pperron dlnM2
varsoc lnBSE lnExchangeRate
vecrank lnBSE lnExchangeRate,lags(2)
var lnBSE lnExchangeRate,lags(1/2)
vargranger
varsoc lnBSE lnExchangeRate lnM2 lnSP
vecrank lnBSE lnExchangeRate lnM2 lnSP, lags(3)
var lnBSE lnExchangeRate lnM2 lnSP, lags(1/3)
vargranger