
//混合贸易中的一般贸易

*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%
**2000-2001
*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%

forvalues i=2000(1)2001{
cd "F:\Measure\OriginalData"
use Match`i'_Import.dta,clear
keep if mix=="混合贸易" & (shipment=="来料加工装配贸易" | shipment=="进料加工贸易")
*一是中间品、消费品、资本品识别
gen hs6=substr(hs,1,6)
merge m:1 hs6 using HS96_BEC.dta
keep if _m==3
drop _m
gen product="中间品" if bec=="111" | bec=="121" | bec=="21" | bec=="22" | bec=="31" | bec=="322" | bec=="42" | bec=="53"
replace product="资本品" if bec=="41" | bec=="521"
replace product="消费品" if product==""
*二是贸易中间商识别
gen Intermediary=strmatch(name, "*贸易*" ) | strmatch(name, "*外贸*" ) | strmatch(name, "*外经*" ) | strmatch(name, "*进出口*" )| strmatch(name, "*科贸*" )| strmatch(name, "*工贸*" ) | strmatch(name, "*经贸*" )
preserve
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
keep if product=="资本品"
save Match`i'_Import_MIX-OT_Capital.dta,replace
restore
keep if product=="中间品"

preserve
bysort hs6: egen value_imp_hs_inter=sum(value)if Intermediary==1  //HS6产品中贸易中间商的进口额
bysort hs6: egen value_imp_hs_t=sum(value) //HS6产品的总进口额
gen imp_inter_ratio=value_imp_hs_inter/value_imp_hs_t // HS6产品中贸易中间商的进口额占总进口额的比重
drop if imp_inter_ratio==.
duplicates drop  hs6,force
keep hs6 imp_inter_ratio  
cd "F:\Measure\DVAR_Input\DVAR_MIX\MIX-OT"
save Imp_Inter_Ratio_mix-ot_`i'.dta,replace
restore

merge m:1 hs6 using Imp_Inter_Ratio_mix-ot_`i'.dta
replace  imp_inter_ratio = 0 if imp_inter_ratio==.
*计算每个
bysort id_new hs6:egen value_imp_id=sum(value)
bysort id_new hs6:gen value_imp_id_hs= value_imp_id/(1-imp_inter_ratio)
duplicates drop id_new hs6,force
bysort id_new: egen value_imp_real_id= sum(value_imp_id_hs)
duplicates drop id_new,force    //得到每个id_new的实际进口额
drop _m
save Match`i'_Import_id_mix-ot.dta,replace
cd "F:\Measure\OriginalData"
use Match`i'_Export.dta,clear
keep if shipment=="一般贸易" | shipment=="来料加工装配贸易" | shipment=="进料加工贸易"
cd "F:\Measure\DVAR_Input\DVAR_MIX\MIX-OT"
merge m:1 id_new using Match`i'_Import_id_mix-ot.dta  //与加工贸易企业匹配，得到加工贸易方式出口的企业
keep if _m==3 //这里只使用匹配上的样本
drop _m
preserve 
bysort hs6: egen value_exp_hs_inter=sum(value) if Intermediary==1  //HS6产品中贸易中间商的出口额
bysort hs6: egen value_exp_hs_t=sum(value) //HS6产品的总出口额

gen exp_inter_ratio=value_exp_hs_inter/value_exp_hs_t // HS6产品中贸易中间商的进口额占总进口额的比重
drop if exp_inter_ratio==.
duplicates drop  hs6 ,force
keep hs6 exp_inter_ratio  
save Exp_Inter_Ratio_mix-ot_`i'.dta,replace
restore
merge m:1 hs6 using Exp_Inter_Ratio_mix-ot_`i'.dta
drop _m
replace  exp_inter_ratio = 0 if exp_inter_ratio==.
bysort id_new hs6:egen value_exp_id=sum(value)
bysort id_new hs6:gen value_exp_id_hs= value_exp_id/(1-exp_inter_ratio)
duplicates drop id_new hs6 ,force
bysort id_new: egen value_exp_mix_ot_real_id= sum(value_exp_id_hs)
duplicates drop id_new,force     //得到每个id_new的实际出口总额
save Match`i'_Import_Export_id_mix-ot.dta ,replace   //实际进口和实际出口

*资本品
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
use Match`i'_Import_MIX-OT_Capital.dta,clear


*如果存在贸易中间商
count if Intermediary==1
if r(N)>0 {
preserve
bysort hs6: egen value_imp_hs_inter_cap=sum(value) if Intermediary==1  //HS6产品中贸易中间商的资本品进口额
bysort hs6: egen value_imp_hs_t_cap=sum(value)  //HS6产品的总进口额
duplicates drop  hs6 value_imp_hs_inter_cap value_imp_hs_t_cap,force
gen imp_inter_ratio_cap=value_imp_hs_inter_cap/value_imp_hs_t_cap // HS6产品中贸易中间商的进口额占总进口额的比重
drop if missing(imp_inter_ratio_cap)
keep hs6 imp_inter_ratio_cap  
save Imp_Inter_Ratio_MIX-OT_Cap_`i'.dta,replace
restore

keep if Intermediary==0
merge m:1 hs6 using Imp_Inter_Ratio_MIX-OT_Cap_`i'.dta
replace imp_inter_ratio_cap = 0 if imp_inter_ratio_cap==.
bysort id_new hs6:egen value_imp_id_cap=sum(value) 
bysort id_new hs6:gen value_imp_id_hs_cap= value_imp_id_cap/(1-imp_inter_ratio_cap) 
duplicates drop id_new hs6 value_imp_id_hs_cap,force
bysort id_new: egen value_imp_mix_ot_real_id_cap= sum(value_imp_id_hs_cap) 
duplicates drop id_new value_imp_mix_ot_real_id_cap,force
capture drop _m
save Match`i'_MIX-OT_Inter_Cap.dta,replace   
label data 考虑了贸易中间商的资本品进口额

}  
else{
bysort id_new:egen value_imp_mix_ot_real_id_cap=sum(value) 
duplicates drop id_new value_imp_mix_ot_real_id_cap,force
capture drop _m
save Match`i'_MIX-OT_Inter_Cap.dta,replace   
label data 考虑了贸易中间商的资本品进口额
 
}

}


*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%
**2002-2006
*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%

forvalues i=2002(1)2006{
cd "F:\Measure\OriginalData"
use Match`i'_Import.dta,clear
keep if mix=="混合贸易" & (shipment=="来料加工装配贸易" | shipment=="进料加工贸易")
*一是中间品、消费品资本品识别
gen hs6=substr(hs,1,6)
merge m:1 hs6 using HS02_BEC.dta
keep if _m==3
drop _m
gen product="中间品" if bec=="111" | bec=="121" | bec=="21" | bec=="22" | bec=="31" | bec=="322" | bec=="42" | bec=="53"
replace product="资本品" if bec=="41" | bec=="521"
replace product="消费品" if product==""
*二是贸易中间商识别
gen Intermediary=strmatch(name, "*贸易*" ) | strmatch(name, "*外贸*" ) | strmatch(name, "*外经*" ) | strmatch(name, "*进出口*" )| strmatch(name, "*科贸*" )| strmatch(name, "*工贸*" ) | strmatch(name, "*经贸*" )
preserve
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
keep if product=="资本品"
save Match`i'_Import_MIX-OT_Capital.dta,replace
restore
keep if product=="中间品"

preserve
bysort hs6: egen value_imp_hs_inter=sum(value)if Intermediary==1  //HS6产品中贸易中间商的进口额
bysort hs6: egen value_imp_hs_t=sum(value) //HS6产品的总进口额
gen imp_inter_ratio=value_imp_hs_inter/value_imp_hs_t // HS6产品中贸易中间商的进口额占总进口额的比重
drop if imp_inter_ratio==.
duplicates drop  hs6,force
keep hs6 imp_inter_ratio  
cd "F:\Measure\DVAR_Input\DVAR_MIX\MIX-OT"
save Imp_Inter_Ratio_mix-ot_`i'.dta,replace
restore

merge m:1 hs6 using Imp_Inter_Ratio_mix-ot_`i'.dta
replace  imp_inter_ratio = 0 if imp_inter_ratio==.
*计算每个
bysort id_new hs6:egen value_imp_id=sum(value)
bysort id_new hs6:gen value_imp_id_hs= value_imp_id/(1-imp_inter_ratio)
duplicates drop id_new hs6,force
bysort id_new: egen value_imp_real_id= sum(value_imp_id_hs)
duplicates drop id_new,force    //得到每个id_new的实际进口额
drop _m
save Match`i'_Import_id_mix-ot.dta,replace
cd "F:\Measure\OriginalData"
use Match`i'_Export.dta,clear
keep if shipment=="一般贸易" | shipment=="来料加工装配贸易" | shipment=="进料加工贸易"
cd "F:\Measure\DVAR_Input\DVAR_MIX\MIX-OT"
merge m:1 id_new using Match`i'_Import_id_mix-ot.dta  //与加工贸易企业匹配，得到加工贸易方式出口的企业
keep if _m==3 //这里只使用匹配上的样本
drop _m
preserve 
bysort hs6: egen value_exp_hs_inter=sum(value) if Intermediary==1  //HS6产品中贸易中间商的出口额
bysort hs6: egen value_exp_hs_t=sum(value) //HS6产品的总出口额

gen exp_inter_ratio=value_exp_hs_inter/value_exp_hs_t // HS6产品中贸易中间商的进口额占总进口额的比重
drop if exp_inter_ratio==.
duplicates drop  hs6 ,force
keep hs6 exp_inter_ratio  
save Exp_Inter_Ratio_mix-ot_`i'.dta,replace
restore
merge m:1 hs6 using Exp_Inter_Ratio_mix-ot_`i'.dta
drop _m
replace  exp_inter_ratio = 0 if exp_inter_ratio==.
bysort id_new hs6:egen value_exp_id=sum(value)
bysort id_new hs6:gen value_exp_id_hs= value_exp_id/(1-exp_inter_ratio)
duplicates drop id_new hs6 ,force
bysort id_new: egen value_exp_mix_ot_real_id= sum(value_exp_id_hs)
duplicates drop id_new,force     //得到每个id_new的实际出口总额
save Match`i'_Import_Export_id_mix-ot.dta ,replace   //实际进口和实际出口

*资本品
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
use Match`i'_Import_MIX-OT_Capital.dta,clear


*如果存在贸易中间商
count if Intermediary==1
if r(N)>0 {
preserve
bysort hs6: egen value_imp_hs_inter_cap=sum(value) if Intermediary==1  //HS6产品中贸易中间商的资本品进口额
bysort hs6: egen value_imp_hs_t_cap=sum(value)  //HS6产品的总进口额
duplicates drop  hs6 value_imp_hs_inter_cap value_imp_hs_t_cap,force
gen imp_inter_ratio_cap=value_imp_hs_inter_cap/value_imp_hs_t_cap // HS6产品中贸易中间商的进口额占总进口额的比重
drop if missing(imp_inter_ratio_cap)
keep hs6 imp_inter_ratio_cap  
save Imp_Inter_Ratio_MIX-OT_Cap_`i'.dta,replace
restore

keep if Intermediary==0
merge m:1 hs6 using Imp_Inter_Ratio_MIX-OT_Cap_`i'.dta
replace imp_inter_ratio_cap = 0 if imp_inter_ratio_cap==.
bysort id_new hs6:egen value_imp_id_cap=sum(value) 
bysort id_new hs6:gen value_imp_id_hs_cap= value_imp_id_cap/(1-imp_inter_ratio_cap) 
duplicates drop id_new hs6 value_imp_id_hs_cap,force
bysort id_new: egen value_imp_mix_ot_real_id_cap= sum(value_imp_id_hs_cap) 
duplicates drop id_new value_imp_mix_ot_real_id_cap,force
capture drop _m
save Match`i'_MIX-OT_Inter_Cap.dta,replace   
label data 考虑了贸易中间商的资本品进口额

}  
else{
bysort id_new:egen value_imp_mix_ot_real_id_cap=sum(value) 
duplicates drop id_new value_imp_mix_ot_real_id_cap,force
capture drop _m
save Match`i'_MIX-OT_Inter_Cap.dta,replace   
label data 考虑了贸易中间商的资本品进口额
 
}



}

*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%
**2007-2011
*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%

forvalues i=2007(1)2011{
cd "F:\Measure\OriginalData"
use Match`i'_Import.dta,clear
keep if mix=="混合贸易" & shipment=="加工贸易"
*一是中间品、消费品资本品识别
gen hs6=substr(hs,1,6)
merge m:1 hs6 using HS07_BEC.dta
keep if _m==3
drop _m
gen product="中间品" if bec=="111" | bec=="121" | bec=="21" | bec=="22" | bec=="31" | bec=="322" | bec=="42" | bec=="53"
replace product="资本品" if bec=="41" | bec=="521"
replace product="消费品" if product==""
*二是贸易中间商识别
gen Intermediary=strmatch(name, "*贸易*" ) | strmatch(name, "*外贸*" ) | strmatch(name, "*外经*" ) | strmatch(name, "*进出口*" )| strmatch(name, "*科贸*" )| strmatch(name, "*工贸*" ) | strmatch(name, "*经贸*" )
preserve
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
keep if product=="资本品"
save Match`i'_Import_MIX-OT_Capital.dta,replace
restore
keep if product=="中间品"

preserve
bysort hs6: egen value_imp_hs_inter=sum(value)if Intermediary==1  //HS6产品中贸易中间商的进口额
bysort hs6: egen value_imp_hs_t=sum(value) //HS6产品的总进口额
gen imp_inter_ratio=value_imp_hs_inter/value_imp_hs_t // HS6产品中贸易中间商的进口额占总进口额的比重
drop if imp_inter_ratio==.
duplicates drop  hs6,force
keep hs6 imp_inter_ratio  
cd "F:\Measure\DVAR_Input\DVAR_MIX\MIX-OT"
save Imp_Inter_Ratio_mix-ot_`i'.dta,replace
restore

merge m:1 hs6 using Imp_Inter_Ratio_mix-ot_`i'.dta
replace  imp_inter_ratio = 0 if imp_inter_ratio==.
*计算每个
bysort id_new hs6:egen value_imp_id=sum(value)
bysort id_new hs6:gen value_imp_id_hs= value_imp_id/(1-imp_inter_ratio)
duplicates drop id_new hs6,force
bysort id_new: egen value_imp_real_id= sum(value_imp_id_hs)
duplicates drop id_new,force    //得到每个id_new的实际进口额
drop _m
save Match`i'_Import_id_mix-ot.dta,replace
cd "F:\Measure\OriginalData"
use Match`i'_Export.dta,clear
keep if shipment=="一般贸易" | shipment=="加工贸易" 
cd "F:\Measure\DVAR_Input\DVAR_MIX\MIX-OT"
merge m:1 id_new using Match`i'_Import_id_mix-ot.dta  //与加工贸易企业匹配，得到加工贸易方式出口的企业
keep if _m==3 //这里只使用匹配上的样本
drop _m
preserve 
bysort hs6: egen value_exp_hs_inter=sum(value) if Intermediary==1  //HS6产品中贸易中间商的出口额
bysort hs6: egen value_exp_hs_t=sum(value) //HS6产品的总出口额

gen exp_inter_ratio=value_exp_hs_inter/value_exp_hs_t // HS6产品中贸易中间商的进口额占总进口额的比重
drop if exp_inter_ratio==.
duplicates drop  hs6 ,force
keep hs6 exp_inter_ratio  
save Exp_Inter_Ratio_mix-ot_`i'.dta,replace
restore
merge m:1 hs6 using Exp_Inter_Ratio_mix-ot_`i'.dta
drop _m
replace  exp_inter_ratio = 0 if exp_inter_ratio==.
bysort id_new hs6:egen value_exp_id=sum(value)
bysort id_new hs6:gen value_exp_id_hs= value_exp_id/(1-exp_inter_ratio)
duplicates drop id_new hs6 ,force
bysort id_new: egen value_exp_mix_ot_real_id= sum(value_exp_id_hs)
duplicates drop id_new,force     //得到每个id_new的实际出口总额
save Match`i'_Import_Export_id_mix-ot.dta ,replace   //实际进口和实际出口

*资本品
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
use Match`i'_Import_MIX-OT_Capital.dta,clear


*如果存在贸易中间商
count if Intermediary==1
if r(N)>0 {
preserve
bysort hs6: egen value_imp_hs_inter_cap=sum(value) if Intermediary==1  //HS6产品中贸易中间商的资本品进口额
bysort hs6: egen value_imp_hs_t_cap=sum(value)  //HS6产品的总进口额
duplicates drop  hs6 value_imp_hs_inter_cap value_imp_hs_t_cap,force
gen imp_inter_ratio_cap=value_imp_hs_inter_cap/value_imp_hs_t_cap // HS6产品中贸易中间商的进口额占总进口额的比重
drop if missing(imp_inter_ratio_cap)
keep hs6 imp_inter_ratio_cap  
save Imp_Inter_Ratio_MIX-OT_Cap_`i'.dta,replace
restore

keep if Intermediary==0
merge m:1 hs6 using Imp_Inter_Ratio_MIX-OT_Cap_`i'.dta
replace imp_inter_ratio_cap = 0 if imp_inter_ratio_cap==.
bysort id_new hs6:egen value_imp_id_cap=sum(value) 
bysort id_new hs6:gen value_imp_id_hs_cap= value_imp_id_cap/(1-imp_inter_ratio_cap) 
duplicates drop id_new hs6 value_imp_id_hs_cap,force
bysort id_new: egen value_imp_mix_ot_real_id_cap= sum(value_imp_id_hs_cap) 
duplicates drop id_new value_imp_mix_ot_real_id_cap,force
capture drop _m
save Match`i'_MIX-OT_Inter_Cap.dta,replace   
label data 考虑了贸易中间商的资本品进口额

}  
else{
bysort id_new:egen value_imp_mix_ot_real_id_cap=sum(value) 
duplicates drop id_new value_imp_mix_ot_real_id_cap,force
capture drop _m
save Match`i'_MIX-OT_Inter_Cap.dta,replace   
label data 考虑了贸易中间商的资本品进口额
 
}



}

*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%
**2012-2014
*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%*%

forvalues i=2012(1)2014{
cd "F:\Measure\OriginalData"
use Match`i'_Import.dta,clear
keep if mix=="混合贸易" & (shipment=="来料加工装配贸易" | shipment=="进料加工贸易")
*一是中间品、消费品资本品识别
gen hs6=substr(hs,1,6)
merge m:1 hs6 using HS12_BEC.dta
keep if _m==3
drop _m
gen product="中间品" if bec=="111" | bec=="121" | bec=="21" | bec=="22" | bec=="31" | bec=="322" | bec=="42" | bec=="53"
replace product="资本品" if bec=="41" | bec=="521"
replace product="消费品" if product==""
*二是贸易中间商识别
gen Intermediary=strmatch(name, "*贸易*" ) | strmatch(name, "*外贸*" ) | strmatch(name, "*外经*" ) | strmatch(name, "*进出口*" )| strmatch(name, "*科贸*" )| strmatch(name, "*工贸*" ) | strmatch(name, "*经贸*" )
preserve
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
keep if product=="资本品"
save Match`i'_Import_MIX-OT_Capital.dta,replace
restore
keep if product=="中间品"

preserve
bysort hs6: egen value_imp_hs_inter=sum(value)if Intermediary==1  //HS6产品中贸易中间商的进口额
bysort hs6: egen value_imp_hs_t=sum(value) //HS6产品的总进口额
gen imp_inter_ratio=value_imp_hs_inter/value_imp_hs_t // HS6产品中贸易中间商的进口额占总进口额的比重
drop if imp_inter_ratio==.
duplicates drop  hs6,force
keep hs6 imp_inter_ratio  
cd "F:\Measure\DVAR_Input\DVAR_MIX\MIX-OT"
save Imp_Inter_Ratio_mix-ot_`i'.dta,replace
restore

merge m:1 hs6 using Imp_Inter_Ratio_mix-ot_`i'.dta
replace  imp_inter_ratio = 0 if imp_inter_ratio==.
*计算每个
bysort id_new hs6:egen value_imp_id=sum(value)
bysort id_new hs6:gen value_imp_id_hs= value_imp_id/(1-imp_inter_ratio)
duplicates drop id_new hs6,force
bysort id_new: egen value_imp_real_id= sum(value_imp_id_hs)
duplicates drop id_new,force    //得到每个id_new的实际进口额
drop _m
save Match`i'_Import_id_mix-ot.dta,replace
cd "F:\Measure\OriginalData"
use Match`i'_Export.dta,clear
keep if shipment=="一般贸易" | shipment=="来料加工装配贸易" | shipment=="进料加工贸易"
cd "F:\Measure\DVAR_Input\DVAR_MIX\MIX-OT"
merge m:1 id_new using Match`i'_Import_id_mix-ot.dta  //与加工贸易企业匹配，得到加工贸易方式出口的企业
keep if _m==3 //这里只使用匹配上的样本
drop _m
preserve 
bysort hs6: egen value_exp_hs_inter=sum(value) if Intermediary==1  //HS6产品中贸易中间商的出口额
bysort hs6: egen value_exp_hs_t=sum(value) //HS6产品的总出口额

gen exp_inter_ratio=value_exp_hs_inter/value_exp_hs_t // HS6产品中贸易中间商的进口额占总进口额的比重
drop if exp_inter_ratio==.
duplicates drop  hs6 ,force
keep hs6 exp_inter_ratio  
save Exp_Inter_Ratio_mix-ot_`i'.dta,replace
restore
merge m:1 hs6 using Exp_Inter_Ratio_mix-ot_`i'.dta
drop _m
replace  exp_inter_ratio = 0 if exp_inter_ratio==.
bysort id_new hs6:egen value_exp_id=sum(value)
bysort id_new hs6:gen value_exp_id_hs= value_exp_id/(1-exp_inter_ratio)
duplicates drop id_new hs6 ,force
bysort id_new: egen value_exp_mix_ot_real_id= sum(value_exp_id_hs)
duplicates drop id_new,force     //得到每个id_new的实际出口总额
save Match`i'_Import_Export_id_mix-ot.dta ,replace   //实际进口和实际出口

*资本品
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
use Match`i'_Import_MIX-OT_Capital.dta,clear


*如果存在贸易中间商
count if Intermediary==1
if r(N)>0 {
preserve
bysort hs6: egen value_imp_hs_inter_cap=sum(value) if Intermediary==1  //HS6产品中贸易中间商的资本品进口额
bysort hs6: egen value_imp_hs_t_cap=sum(value)  //HS6产品的总进口额
duplicates drop  hs6 value_imp_hs_inter_cap value_imp_hs_t_cap,force
gen imp_inter_ratio_cap=value_imp_hs_inter_cap/value_imp_hs_t_cap // HS6产品中贸易中间商的进口额占总进口额的比重
drop if missing(imp_inter_ratio_cap)
keep hs6 imp_inter_ratio_cap  
save Imp_Inter_Ratio_MIX-OT_Cap_`i'.dta,replace
restore

keep if Intermediary==0
merge m:1 hs6 using Imp_Inter_Ratio_MIX-OT_Cap_`i'.dta
replace imp_inter_ratio_cap = 0 if imp_inter_ratio_cap==.
bysort id_new hs6:egen value_imp_id_cap=sum(value) 
bysort id_new hs6:gen value_imp_id_hs_cap= value_imp_id_cap/(1-imp_inter_ratio_cap) 
duplicates drop id_new hs6 value_imp_id_hs_cap,force
bysort id_new: egen value_imp_mix_ot_real_id_cap= sum(value_imp_id_hs_cap) 
duplicates drop id_new value_imp_mix_ot_real_id_cap,force
capture drop _m
save Match`i'_MIX-OT_Inter_Cap.dta,replace   
label data 考虑了贸易中间商的资本品进口额

}  
else{
bysort id_new:egen value_imp_mix_ot_real_id_cap=sum(value) 
duplicates drop id_new value_imp_mix_ot_real_id_cap,force
capture drop _m
save Match`i'_MIX-OT_Inter_Cap.dta,replace   
label data 考虑了贸易中间商的资本品进口额
 
}



}

forvalues i=2000(1)2014{
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT"
use Match`i'_MIX-OT_Inter_Cap.dta,clear
rename value_imp_mix_ot_real_id_cap id`i'_cap
keep id_new id`i'_cap
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT\MIX-OT_id_cap"
save id`i'_cap.dta,replace

}

**===========================================
**累计资本
**===========================================
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT\MIX-OT_id_cap"
forvalues i=2000(1)2014{
use id`i'_cap.dta,clear

save id`i'_cap_i.dta,replace


}

forvalues j=2000(1)2014{
local i=2000
while `i'<=`j'{
cd "F:\Measure\DVAR_AccumulatedDepreciation\DVAR_MIX\MIX-OT\MIX-OT_id_cap"
use id`j'_cap.dta,clear
  
capture drop _m

merge 1:1 id_new using  id`i'_cap_i.dta

drop if _m==2
replace id`i'_cap=0 if id`i'_cap==.
save id`j'_cap.dta,replace

local i=`i'+1

}

}




