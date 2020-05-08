
cd F:\Measure
forvalues i=2000(1)2006{
use Match`i'.dta,clear
drop if country=="中华人民共和国"

preserve 
keep if exp_or_imp=="出口"
save Match`i'_Export.dta,replace
restore
drop if exp_or_imp=="出口"
gen mix=shipment
keep if mix=="一般贸易" | mix=="来料加工装配贸易" | mix=="进料加工贸易"|mix=="来料加工装配进口的设备"

preserve
keep if shipment=="来料加工装配进口的设备" 
save Match`i'_Import_PT_Capital.dta,replace
restore

drop if shipment=="来料加工装配进口的设备"

bysort id_new: egen value_id_imp_t=sum(value) 
bysort id_new: egen value_id_imp_pt=sum(value) if mix=="来料加工装配贸易" | mix=="进料加工贸易"
bysort id_new: egen value_id_imp_ot=sum(value) if mix=="一般贸易"
gen value_id_imp_pt_rat=value_id_imp_pt/value_id_imp_t 
gen value_id_imp_ot_rat=value_id_imp_ot/value_id_imp_t 

replace mix ="加工贸易" if value_id_imp_pt_rat==1 
replace mix ="一般贸易" if value_id_imp_ot_rat==1 
replace mix ="混合贸易" if value_id_imp_pt_rat!=1 & value_id_imp_ot_rat!=1
 
save Match`i'_Import.dta,replace

//识别进料加工、来料加工
bysort id_new: egen value_id_mix_pa=sum(value) if mix=="混合贸易" & shipment=="来料加工装配贸易"     // 混合贸易中的来料加工
bysort id_new: egen value_id_mix_ia=sum(value) if mix=="混合贸易" & shipment=="进料加工贸易"       //混合贸易中的进料加工
bysort id_new: egen value_id_pa=sum(value) if mix=="加工贸易" & shipment=="来料加工装配贸易"     //加工贸易中的来料加工
bysort id_new: egen value_id_ia=sum(value) if mix=="加工贸易" & shipment=="进料加工贸易"     //加工贸易中的进料加工
save Match`i'_Import_identification.dta, replace
}



cd F:\Measure
forvalues i=2007(1)2011{
use Match`i'.dta,clear
drop if country=="中华人民共和国"

preserve 
keep if exp_or_imp=="出口"
save Match`i'_Export.dta,replace
restore
drop if exp_or_imp=="出口"
gen mix=shipment
keep if mix=="一般贸易" | mix=="加工贸易"

bysort id_new: egen value_id_imp_t=sum(value) 
bysort id_new: egen value_id_imp_pt=sum(value) if mix=="加工贸易"
bysort id_new: egen value_id_imp_ot=sum(value) if mix=="一般贸易"
gen value_id_imp_pt_rat=value_id_imp_pt/value_id_imp_t 
gen value_id_imp_ot_rat=value_id_imp_ot/value_id_imp_t 

replace mix ="加工贸易" if value_id_imp_pt_rat==1 
replace mix ="一般贸易" if value_id_imp_ot_rat==1 
replace mix ="混合贸易" if value_id_imp_pt_rat!=1 & value_id_imp_ot_rat!=1
 
save Match`i'_Import.dta,replace

}


cd F:\Measure
forvalues i=2012(1)2014{
use Match`i'.dta,clear
drop if country=="中华人民共和国"

preserve 
keep if exp_or_imp=="出口"
save Match`i'_Export.dta,replace
restore
drop if exp_or_imp=="出口"
gen mix=shipment
keep if mix=="一般贸易" | mix=="来料加工装配贸易" | mix=="进料加工贸易"|mix=="来料加工装配进口的设备"

preserve
keep if shipment=="来料加工装配进口的设备" 
save Match`i'_Import_PT_Capital.dta,replace
restore

drop if shipment=="来料加工装配进口的设备"

bysort id_new: egen value_id_imp_t=sum(value) 
bysort id_new: egen value_id_imp_pt=sum(value) if mix=="来料加工装配贸易" | mix=="进料加工贸易"
bysort id_new: egen value_id_imp_ot=sum(value) if mix=="一般贸易"
gen value_id_imp_pt_rat=value_id_imp_pt/value_id_imp_t 
gen value_id_imp_ot_rat=value_id_imp_ot/value_id_imp_t 

replace mix ="加工贸易" if value_id_imp_pt_rat==1 
replace mix ="一般贸易" if value_id_imp_ot_rat==1 
replace mix ="混合贸易" if value_id_imp_pt_rat!=1 & value_id_imp_ot_rat!=1
 
save Match`i'_Import.dta,replace

//识别进料加工、来料加工
bysort id_new: egen value_id_mix_pa=sum(value) if mix=="混合贸易" & shipment=="来料加工装配贸易"     // 混合贸易中的来料加工
bysort id_new: egen value_id_mix_ia=sum(value) if mix=="混合贸易" & shipment=="进料加工贸易"       //混合贸易中的进料加工
bysort id_new: egen value_id_pa=sum(value) if mix=="加工贸易" & shipment=="来料加工装配贸易"     //加工贸易中的来料加工
bysort id_new: egen value_id_ia=sum(value) if mix=="加工贸易" & shipment=="进料加工贸易"     //加工贸易中的进料加工
save Match`i'_Import_identification.dta, replace
}
