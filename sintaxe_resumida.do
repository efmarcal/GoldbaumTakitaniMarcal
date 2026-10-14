**Comandos de início
clear all
set more off
capture log close// Obs: Os comandos Virtual, Memory e Matrix foram atualizados e não precisam ser mais utilizados nessa versão do Stata
**cd "C:\Users\marin\OneDrive\Documents\Documentos-Mestrado\python"
cd "C:\Users\Sergio.Goldbaum\Dropbox\PC\Desktop\Resultados_Marina"
**import delimited "C:\Users\marin\OneDrive\Documents\Documentos-Mestrado\python\imports_complete_monthly_lag.csv", encoding(UTF-8) 
import delimited "C:\Users\Sergio.Goldbaum\Dropbox\PC\Desktop\imports_complete_monthly_lag.csv", encoding(UTF-8) 

*==Ajustes na base==*
*Drop variáveis em excesso
drop if t_ini<-24
drop if t>60
drop if sh6==281121
drop if sh6==281129
drop if sh6==283525
drop if sh6==290515
drop if sh6==290542
drop if sh6==290543
drop if sh6==290529
drop if sh6==290516
drop if sh6==290559
drop if sh6==291634
drop if sh6==291635
drop if sh6==291636
drop if sh6==292213
drop if sh6==292214
drop if sh6==292215
drop if sh6==292216
drop if sh6==292217
drop if sh6==292231
drop if sh6==292239
drop if sh6==292243
drop if sh6==292242
drop if sh6==320490
drop if sh6==390140
drop if sh6==400211
drop if sh6==400239
drop if sh6==400249
drop if sh6==400260
drop if sh6==400291
drop if sh6==400299
drop if sh6==400950
drop if sh6==480620
drop if sh6==481031
drop if sh6==481039
drop if sh6==481092
drop if sh6==481032
drop if sh6==540253
drop if sh6==540248
drop if sh6==540251
drop if sh6==540259
drop if sh6==700530
drop if sh6==721911
drop if sh6==721914
drop if sh6==721924
drop if sh6==721931
drop if sh6==721990
drop if sh6==721921
drop if sh6==722011
drop if sh6==722611
drop if sh6==722591
drop if sh6==722599
drop if sh6==722591
drop if sh6==722530
drop if sh6==821195
drop if sh6==901839
drop if country=="Other"

summarize fob_value_usd net_weight_kg kg_price if treatment == 1


*Ajustando a data
split date, parse(-) generate(year)
drop year3
rename year2 month
rename year1 year
destring month, replace

*Criar lns
gen ln_ma_value = ln(moving_avg_fob_value)
gen ln_ma_quantity = ln(moving_avg_net_weight)
gen ln_ma_price = ln(moving_avg_kg_price)
gen ln_value = ln(fob_value_usd)
gen ln_quantity = ln(net_weight_kg)
gen ln_price = ln(kg_price)

gen ln_value_L1= ln(fob_value_lag_1)
gen ln_value_L2 = ln(fob_value_lag_2)
gen ln_quantity_L1= ln(net_weight_lag_1)
gen ln_quantity_L2= ln(net_weight_lag_2)
gen ln_price_L1= ln(kg_price_lag_1)
gen ln_price_L2= ln(kg_price_lag_2)

gen ln_value_diff= ln(fob_value_diff)
gen ln_quantity_diff= ln(net_weight_diff)
gen ln_price_diff= ln(kg_price_diff)

gen ln_exchange_rate = ln(exchange_rate)
gen ln_oil = ln(oil_brent_global)
gen ln_pim = ln(pim_pf_transf)
gen ln_duty = ln(ad_value)

gen ln_exchange_rate_L1= ln(exchange_rate_lag_1)
gen ln_pim_L1= ln(pim_pf_transf_lag_1)
gen ln_oil_L1= ln(oil_brent_global_lag_1)

*Criar dummies 
gen China=1 if country=="China"
	replace China=0 if China==.

gen control_group=1 if treatment==0
	replace control_group=0 if control_group==.

gen low=1 if ad_value<.25
	replace low=0 if low==.
	replace low=0 if t<0
	
gen high=1 if ad_value>.6
	replace high=0 if high==.
	replace high=0 if t<0

gen numnamed=1 if investigated_countries>=3
	replace numnamed=0 if numnamed==.

gen summer=1 if month==1
	replace summer=1 if month==2
	replace summer=1 if month==3
	replace summer=0 if summer==.

gen autumn=1 if month==4
	replace autumn=1 if month==5
	replace autumn=1 if month==6
	replace autumn=0 if autumn==.

gen winter=1 if month==7
	replace winter=1 if month==8
	replace winter=1 if month==9
	replace winter=0 if winter==.

gen spring=1 if month==10
	replace spring=1 if month==11
	replace spring=1 if month==12
	replace spring=0 if spring==.
	
	
*Summary Statistics
bysort China: sum fob_value_usd net_weight_kg kg_price if treatment==1 & t_ini<0
bysort China: sum fob_value_usd net_weight_kg kg_price if treatment==1 & t_ini>=0


*Preparar variáveis para painel e ts
egen product_id = group(sh6)
egen month_id= group(date)
egen country_id = group(country)
gen country_product_id = country_id*(1000) + product_id


*==Gráficos==*
*Gráfico Value
bysort t_ini: egen ln_value_treated = mean(ln_ma_value) if treatment==1 & country!="Other"
bysort t_ini: egen ln_value_control = mean(ln_ma_value) if treatment==0 & country!="Other"
bysort t_ini: egen ln_value_china = mean(ln_ma_value) if China==1 & treatment==1
bysort t_ini: egen ln_value_others = mean(ln_ma_value) if China==0 & country!="Other" & treatment==1

twoway (connected ln_value_treated t_ini if treatment==1 & t_ini>-24 & t_ini<78, lcolor(ebblue) mcolor(ebblue)), xline(0, lcolor(red)) || /// 
	   (connected ln_value_control t_ini if treatment==0 & country!="Other" & t_ini>-24 & t_ini<78, lcolor(teal) mcolor(teal)), xline(17, lcolor(red)) ///
	   xtitle("t", size(4)) ytitle("ln_Value", size(4))  ///
	   legend(colfirst order(1 "Treatment" 2 "Control") cols(2)) graphregion(color(white))
	   
twoway (connected ln_value_china t_ini if China==1 & t_ini>-24 & t_ini<78, lcolor(gs7) mcolor(gs7)), xline(17, lcolor(gs13)) || /// 
	   (connected ln_value_others t_ini if China==0 & t_ini>-24 & t_ini<78, lcolor(gs11) mcolor(gs11)), xline(0, lcolor(gs13)) ///
	   xtitle("t", size(4)) ytitle("ln_Value", size(4))  ///
	   legend(colfirst order(1 "China" 2 "Others") cols(2)) graphregion(color(white))
	   
*Gráfico Quantidade
bysort t_ini: egen ln_quantity_treated = mean(ln_ma_quantity) if country!="Other" & treatment==1
bysort t_ini: egen ln_quantity_control = mean(ln_ma_quantity) if treatment==0 & country!="Other"
bysort t_ini: egen ln_quantity_china = mean(ln_ma_quantity) if China==1 & treatment==1
bysort t_ini: egen ln_quantity_others = mean(ln_ma_quantity) if China==0 & country!="Other" & treatment==1

twoway (connected ln_quantity_treated t_ini if treatment==1 & t_ini>-24 & t_ini<78, lcolor(ebblue) mcolor(ebblue)), xline(0, lcolor(red)) || /// 
	   (connected ln_quantity_control t_ini if treatment==0 & country!="Other" & t_ini>-24 & t_ini<78, lcolor(teal) mcolor(teal)), xline(17, lcolor(red)) ///
	   xtitle("t", size(4)) ytitle("ln_Value", size(4))  ///
	   legend(colfirst order(1 "Treatment" 2 "Control") cols(2)) graphregion(color(white))
	   
twoway (connected ln_quantity_china t_ini if China==1 & t_ini>-24 & t_ini<78, lcolor(gs7) mcolor(gs7)), xline(17, lcolor(gs13)) || /// 
	   (connected ln_quantity_others t_ini if China==0 & t_ini>-24 & t_ini<78, lcolor(gs11) mcolor(gs11)), xline(0, lcolor(gs13)) ///
	   xtitle("t", size(4)) ytitle("ln_quantity", size(4))  ///
	   legend(colfirst order(1 "China" 2 "Others") cols(2)) graphregion(color(white))
 	   
*Gráfico Preço
bysort t_ini: egen ln_price_treated = mean(ln_ma_price) if country!="Other" & treatment==1
bysort t_ini: egen ln_price_control = mean(ln_ma_price) if treatment==0 & country!="Other"
bysort t_ini: egen ln_price_china = mean(ln_ma_price) if China==1 & treatment==1
bysort t_ini: egen ln_price_others = mean(ln_ma_price) if China==0 & country!="Other" & treatment==1

twoway (connected ln_price_china t_ini if China==1 & t_ini>-24 & t_ini<78, lcolor(cranberry) mcolor(cranberry)), xline(17, lcolor(red)) || /// 
	   (connected ln_price_others t_ini if China==0 & t_ini>-24 & t_ini<78, lcolor(erose) mcolor(erose)), xline(0, lcolor(red)) ///
	   xtitle("t", size(4)) ytitle("ln_price", size(4))  ///
	   legend(colfirst order(1 "China" 2 "Others") cols(2)) graphregion(color(white))

*Modelo Separado
*China
reg ln_value ad_inv ad_prel ad_ap_1 ad_ap_2 ad_ap_3 ad_ap_4 ad_ap_5 ln_pim_L1 ln_exchange_rate_L1 ln_oil_L1 new_reg low high ip i.month_id i.product_id i.country_id if treatment==1 & China==1

eststo m1

qui reg ln_quantity ad_inv ad_prel ad_ap_1 ad_ap_2 ad_ap_3 ad_ap_4 ad_ap_5 ln_pim_L1 ln_exchange_rate_L1 ln_oil_L1 new_reg low high ip i.month_id i.product_id i.country_id if treatment==1 & China==1

eststo m2

qui reg ln_price ad_inv ad_prel ad_ap_1 ad_ap_2 ad_ap_3 ad_ap_4 ad_ap_5 ln_pim_L1 ln_exchange_rate_L1 ln_oil_L1 new_reg low high ip i.month_id i.product_id i.country_id if treatment==1 & China==1

eststo m3


*Outros

qui reg ln_value ad_inv ad_prel ad_ap_1 ad_ap_2 ad_ap_3 ad_ap_4 ad_ap_5 ln_pim_L1 ln_exchange_rate_L1 ln_oil_L1 new_reg low high ip i.month_id i.product_id i.country_id if treatment==1 & China==0

eststo m4

qui reg ln_quantity ad_inv ad_prel ad_ap_1 ad_ap_2 ad_ap_3 ad_ap_4 ad_ap_5 ln_pim_L1 ln_exchange_rate_L1 ln_oil_L1 new_reg low high ip i.month_id i.product_id i.country_id if treatment==1 & China==0

eststo m5

qui reg ln_price ad_inv ad_prel ad_ap_1 ad_ap_2 ad_ap_3 ad_ap_4 ad_ap_5 ln_pim_L1 ln_exchange_rate_L1 ln_oil_L1 new_reg low high ip i.month_id i.product_id i.country_id if treatment==1 & China==0

eststo m6

esttab m1 m2 m3 m4 m5 m6, keep(ad_inv ad_prel ad_ap_1 ad_ap_2 ad_ap_3 ad_ap_4 ad_ap_5 new_reg low high ip _cons) stats(N r2 F, labels("N" "R-squared" "F-statistic")) 

outreg2 using Table3.doc, word replace



*Diferenças em diferenças
*Criando variável de interação
gen apl_total=1 if ad_ap_1==1
	replace apl_total=1 if ad_ap_2==1
	replace apl_total=1 if ad_ap_3==1
	replace apl_total=1 if ad_ap_4==1
	replace apl_total=1 if ad_ap_5==1
	replace apl_total=0 if apl_total==.

	
gen treat1=1 if treatment==1 & ad_inv==1 
	replace treat1=0 if treat1==.

gen treat2=1 if ad_prel==1
	replace treat2=0 if treat2==.
	
gen treat3=1 if treatment==1 & apl_total==1
	replace treat3=0 if treat3==.

	
gen pre1=1 if t_ini<0 & t_ini>=-12
	replace pre1=0 if pre1==.

gen pre2=1 if t_ini<-12 & t_ini>=-24
	replace pre2=0 if pre2==.
	
gen pre=1 if pre1==1
	replace pre=1 if pre2==1
	replace pre=0 if pre==.
	
*Time series
tsset country_product_id t_2000, monthly



*Regressões
areg ln_value China China##ad_inv China##ad_prel China##apl_total i.month_id ip if country!="Other" & treatment==1, absorb(country_product_id) cluster(country_product_id)

eststo m7

qui areg ln_quantity China##ad_inv China##ad_prel China##apl_total i.month_id ip if country!="Other" & treatment==1, absorb(country_product_id) cluster(country_product_id)

eststo m8

qui areg ln_price China##ad_inv China##ad_prel China##apl_total i.month_id ip if country!="Other" & treatment==1, absorb(country_product_id) cluster(country_product_id)

eststo m9

*Excluindo high e low

qui areg ln_value China##ad_inv China##ad_prel China##apl_total i.month_id ip if country!="Other" & treatment==1 & high==0 & low==0, absorb(country_product_id) cluster(country_product_id)

eststo m10

qui areg ln_quantity China##ad_inv China##ad_prel China##apl_total i.month_id ip if country!="Other" & treatment==1 & high==0 & low==0, absorb(country_product_id) cluster(country_product_id)

eststo m11

qui areg ln_price China##ad_inv China##ad_prel China##apl_total i.month_id ip if country!="Other" & treatment==1 & high==0 & low==0, absorb(country_product_id) cluster(country_product_id)

eststo m12

esttab m7 m8 m9 m10 m11 m12, keep(1.China#1.ad_inv 1.China#1.ad_prel 1.China#1.apl_total ip) stats(N r2 F, labels("N" "R-squared" "F-statistic")) 

outreg2 using Table4.doc, word append



* Efeitos diferentes ao longo do tempo

areg ln_value China China##ad_inv China##ad_prel China##ad_ap_1 China##ad_ap_2 China##ad_ap_3 China##ad_ap_4 China##ad_ap_5 i.month_id ip if country!="Other" & treatment==1, absorb(country_product_id) cluster(country_product_id)

eststo m13

qui areg ln_quantity China##ad_inv China##ad_prel China##ad_ap_1 China##ad_ap_2 China##ad_ap_3 China##ad_ap_4 China##ad_ap_5 i.month_id ip if country!="Other" & treatment==1, absorb(country_product_id) cluster(country_product_id)

eststo m14

qui areg ln_price China##ad_inv China##ad_prel China##ad_ap_1 China##ad_ap_2 China##ad_ap_3 China##ad_ap_4 China##ad_ap_5 i.month_id ip if country!="Other" & treatment==1, absorb(country_product_id) cluster(country_product_id)

eststo m15


*Excluindo low high

qui areg ln_value China##ad_inv China##ad_prel China##ad_ap_1 China##ad_ap_2 China##ad_ap_3 China##ad_ap_4 China##ad_ap_5 i.month_id ip if country!="Other" & treatment==1 & high==0 & low==0, absorb(country_product_id) cluster(country_product_id)

eststo m16

qui areg ln_quantity China##ad_inv China##ad_prel China##ad_ap_1 China##ad_ap_2 China##ad_ap_3 China##ad_ap_4 China##ad_ap_5  i.month_id ip if country!="Other" & treatment==1 & high==0 & low==0, absorb(country_product_id) cluster(country_product_id)

eststo m17

qui areg ln_price China##ad_inv China##ad_prel China##ad_ap_1 China##ad_ap_2 China##ad_ap_3 China##ad_ap_4 China##ad_ap_5  i.month_id ip if country!="Other" & treatment==1 & high==0 & low==0, absorb(country_product_id) cluster(country_product_id)

eststo m18

esttab m13 m14 m15 m16 m17 m18, keep(1.China#1.ad_inv 1.China#1.ad_prel 1.China#1.ad_ap_1 1.China#1.ad_ap_2 1.China#1.ad_ap_3 1.China#1.ad_ap_4 1.China#1.ad_ap_5 ip) stats(N r2 F, labels("N" "R-squared" "F-statistic")) 

outreg2 using Table5.doc, word append