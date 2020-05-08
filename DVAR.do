
*

//加工贸易
cd "G:\Measure\DVAR_AccumulatedDepreciation\Results_pt_cap"
 forvalues i =2000(1)2014{
 	
	use id`i'_cap.dta,clear
	drop _m
	local j=0
	while `i'>=2000{
	rename id`i'_cap  cap`i'
	local i=`i'-1	
	local j=`j'+1
	}
	local i=1999+`j'
	reshape long cap,i(id_new) j(year)	
    
	bysort id_new:egen cap_acc=sum(cap)
    duplicates drop id_new,force
    gen Dep=0.1096*cap_acc
    keep id_new Dep
	label var Dep "资本折旧"
	save cap`i'.dta,replace
 }

 
forvalues i =2000(1)2014{
  cd "G:\Measure\DVAR_Input\Results_pt_input"
  use Match`i'_Import_Export_id_PT.dta,clear
  cd "G:\Measure\DVAR_AccumulatedDepreciation\Results_pt_cap"
  merge 1:1 id_new using cap`i'.dta
  drop if _m==2
  replace Dep = 0 if _m!=3
  drop _m
  gen vs_new=value_imp_real_id+Dep
  gen dvar=1-vs_new/value_exp_pt_real_id
  
  save dvar`i'_pt.dta
 
}

//一般贸易

cd G:\Measure\DVAR_AccumulatedDepreciation\Results_ot_cap
 forvalues i =2000(1)2014{
 	
	use id`i'_cap.dta,clear
	drop _m
	local j=0
	while `i'>=2000{
	rename id`i'_cap  cap`i'
	local i=`i'-1	
	local j=`j'+1
	}
	local i=1999+`j'
	reshape long cap,i(id_new) j(year)	
    
	bysort id_new:egen cap_acc=sum(cap)
    duplicates drop id_new,force
    gen Dep=0.1096*cap_acc
    keep id_new Dep
	label var Dep "资本折旧"
	save cap`i'.dta,replace
 }

forvalues i =2000(1)2014{
  cd "G:\Measure\DVAR_Input\Results_ot_input"
  use Match`i'_Import_Export_id_OT.dta,clear
  cd "G:\Measure\DVAR_AccumulatedDepreciation\Results_ot_cap"
  merge 1:1 id_new using cap`i'.dta
  drop if _m==2
  replace Dep = 0 if _m!=3
  drop _m
  merge m:1 year using "G:\Measure\DVAR_AccumulatedDepreciation\Results_ot_cap\Exchange Rate_China.dta"
  keep if _m==3
  drop _m
  gen vs_new=(value_imp_real_id+Dep)*exchange_rate/1000
  gen dvar=1-vs_new/salescur
  
  save dvar`i'_ot.dta,replace
 
}

//混合贸易

*混合贸易中的加工贸易部分
cd "G:\Measure\DVAR_AccumulatedDepreciation\Results_mix-pt_cap"
forvalues i =2000(1)2014{
 	
	use id`i'_cap.dta,clear
	drop _m
	local j=0
	while `i'>=2000{
	rename id`i'_cap  cap`i'
	local i=`i'-1	
	local j=`j'+1
	}
	local i=1999+`j'
	reshape long cap,i(id_new) j(year)	
    
	bysort id_new:egen cap_acc=sum(cap)
    duplicates drop id_new,force
    gen Dep=0.1096*cap_acc
    keep id_new Dep
	label var Dep "资本折旧"
	save cap`i'.dta,replace
 }

 
forvalues i =2000(1)2014{
  cd "G:\Measure\DVAR_Input\Results_mix-pt_input"
  use Match`i'_Import_Export_id_mix-pt.dta,clear
  cd "G:\Measure\DVAR_AccumulatedDepreciation\Results_mix-pt_cap"
  merge 1:1 id_new using cap`i'.dta
  drop if _m==2
  replace Dep = 0 if _m!=3
  drop _m
  gen vs_new=value_imp_real_id+Dep
  gen dvar=1-vs_new/value_exp_mix_pt_real_id
  
  save dvar`i'_mix-pt.dta
 
}


*混合贸易中的一般贸易部分
cd "G:\Measure\DVAR_AccumulatedDepreciation\Results_mix-ot_cap"
forvalues i =2000(1)2014{
 	
	use id`i'_cap.dta,clear
	drop _m
	local j=0
	while `i'>=2000{
	rename id`i'_cap  cap`i'
	local i=`i'-1	
	local j=`j'+1
	}
	local i=1999+`j'
	reshape long cap,i(id_new) j(year)	
    
	bysort id_new:egen cap_acc=sum(cap)
    duplicates drop id_new,force
    gen Dep=0.1096*cap_acc
    keep id_new Dep
	label var Dep "资本折旧"
	save cap`i'.dta,replace
 }

cd "G:\Measure\DVAR_Input\Results_mix-pt_input"
 forvalues i =2000(1)2014{
 
 use Match`i'_Import_Export_id_mix-pt.dta,clear
 keep id_new value_exp_mix_pt_real_id
 save export`i'_pt.dta,replace
 }

forvalues i =2000(1)2014{
  cd "G:\Measure\DVAR_Input\Results_mix-ot_input"
  use Match`i'_Import_Export_id_mix-ot.dta,clear
  cd "G:\Measure\DVAR_AccumulatedDepreciation\Results_mix-ot_cap"
  merge 1:1 id_new using cap`i'.dta
  drop if _m==2
  replace Dep = 0 if _m!=3
  drop _m
  merge m:1 year using "G:\Measure\DVAR_AccumulatedDepreciation\Results_ot_cap\Exchange Rate_China.dta"
  keep if _m==3
  drop _m
  cd "G:\Measure\DVAR_Input\Results_mix-pt_input"
  merge 1:1 id_new using export`i'_pt.dta
  keep if _m==3
  drop _m
  gen y = salescur-value_exp_mix_pt_real_id*exchange_rate/1000
  
  gen vs_new=(value_imp_real_id+Dep)*exchange_rate/1000
  
  gen dvar=1-vs_new/y
  
  save dvar`i'_mix-ot.dta
 
}

*混合贸易的dvar
 
forvalues i = 2000(1)2014{
  cd "G:\Measure\DVAR"  
  use dvar2000_mix-pt.dta,clear
  rename dvar dvar_pt
  keep id_new dvar_pt
  save dvar`i'_pt.dta,replace

  use dvar`i'_mix-ot.dta,clear
  rename dvar dvar_ot
  gen exp_t=value_exp_mix_ot_real_id + value_exp_mix_pt_real_id
  gen omega1=value_exp_mix_pt_real_id/exp_t
  gen omega2=value_exp_mix_ot_real_id/exp_t
  merge 1:1 id_new using dvar`i'_pt.dta
  keep if _m==3 
  drop _m
  gen dvar=omega1*dvar_pt+omega2*dvar_ot
  save dvar`i'_mix.dta,replace
	  
  }
  


