import excel "Data.xlsx", sheet("Total_sectors") firstrow clear

collapse (sum) Revenews Companies Employees, by( Year Aggr_region Sector )
rename Aggr_region Region

save "Revenews.dta", replace

import excel "Data.xlsx", sheet("Regions_all") firstrow clear

collapse (sum) TotalPurchaseforlocalusem TotalPurchasem NumberofCompaniesallincludin TotalNumberofEmployeesPurch TotalPurchaseImportsm TotalPurchaseDomesticMarketS TotalPurchaseGlobalMarketSha , by( Year NACE AdaptationMeasure Region)

rename NACE Sector
encode Region, generate(id)
encode Sector, generate(sec)

destring Year, replace
merge m:m Year Region Sector using "Revenews.dta"
encode AdaptationMeasure, generate(adapt)

*Fixed effect combinations
egen group=group( Region Sector AdaptationMeasure )
egen group2=group( Region Sector)
egen group3=group( Region AdaptationMeasure )
xtset group Year

gen lnRevenews=ln(Revenews)
gen lnInvestment=ln(TotalPurchasem)
gen lnEmployees=ln(Employees)
gen lnCompanies=ln(Companies)



*########OLD###############################

*########NEW###############################
xtabond2 lnRevenews L.lnRevenews c.L.lnInvestment lnEmployees lnCompanies 2020.Year 2021.Year if sec!=15, ///
    gmm(L.lnRevenews c.L.lnInvestment, lag(2 .) collapse) ///
    iv(i.Year lnEmployees lnCompanies, equation(level)) ///
    robust twostep
outreg2 using FINAL_ESTIMATION, append excel ctitle("System GMM") stats(coef se pval) long onecol label dec(3) pdec(5)
	
	
xtreg lnRevenews c.l.lnInvestment lnCompanies lnEmployees 2020.Year 2021.Year if sec!=15, fe
outreg2 using FINAL_ESTIMATION, append excel ctitle("FE") stats(coef se pval) long onecol label dec(3) pdec(5)


xtreg lnRevenews c.l.lnInvestment#ibn.id lnCompanies lnEmployees 2020.Year 2021.Year if sec!=15, fe
outreg2 using FINAL_ESTIMATION, append excel ctitle("FE by Region") stats(coef se pval) long onecol label dec(3) pdec(5)
coefplot, keep(*.lnInvestment) sort ///
    horizontal ///
    xlabel(-0.1(0.1)0.5, format(%3.2f)) ///
    xtitle("Percentage change in Revenews (%)") ///
    ytitle("1% increase in CCA investments in:") ///
    graphregion(color(white))



xtreg lnRevenews c.l.lnInvestment#ibn.sec lnCompanies lnEmployees 2020.Year 2021.Year if sec!=15, fe
outreg2 using FINAL_ESTIMATION, append excel ctitle("FE by Sector") stats(coef se pval) long onecol label dec(3) pdec(5)
coefplot, keep(*.lnInvestment) sort ///
    horizontal ///
    xlabel(-0.1(0.1)0.5, format(%3.2f)) ///
    xtitle("Percentage change in Revenews (%)") ///
    ytitle("1% increase in CCA investments in:") ///
    graphregion(color(white))