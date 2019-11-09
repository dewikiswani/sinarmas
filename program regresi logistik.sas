/*membuat libname*/
libname c "D:\pelatihan\[SAS] ganesha - credit scoring [2019]\data";


proc logistic data = a.rating;
model eksternal_rating =
	return_on_equity
	return_on_asset
	cost_to_income_ratio
;
run;

/*1. pastikan model konvergen dilihat dari hasil 1."model convergence status" satisfied*/
/*2. probability modeled is eksternal_rating="No" , jika ingin yg di lihat itu P(good) maka hrus di custom di programnya*/
/*		--> pengaruhnya hanya mengubah tanda positif dan negatif di koefisien (estimate) variable*/
/*		--> jika koefisien positif maka jika ROE smkin besar akan mempengaruh rating good pada bank*/
/*		--> jika koef negatif maka jika Cost income ratio nya rendah maka akan mempengaruhi rating good pada bank*/
/*3. lihat p value setiap variable , jika p kecil maka var tsb signifikan */
/*4. ukuran kebaikan model bagian "assosciation of predicted prob and obs" : kesesuaian dg prediksinya dengan aktualnya*/
/*	--> samkin tinggi smkin tepat prediksinya (untuk ke empat nilai statistik*/
/*	--> nilai c paling kanan bawah menandakan AIC*/

/*jika sudah di rubah p(good)*/
proc logistic data = c.rating outmodel = modelrating; /*menyimpan modelnya dengan out*/
model eksternal_rating (event = "OK" )=
	return_on_equity
	return_on_asset
	cost_to_income_ratio
;
run;

/*misal ada perusahan baru mau kita predik, maka gunakan model yang sudah di simpan*/
/*buat data baru dengan nama variabel yang percis sama*/
data maudiprediksi;
input;
cards;
0.1 0.02 0.8
0.2	0.02 0.6
;

proc logistic inmodel=modelrating;
score data=maudiprediksi out =prediksi; /*hasil prediksinya dimunculkan di data prediksi dg peluang yg dimunculkan*/
run;

proc logistic inmodel=modelrating plots=roc;
score data=c.rating out =prediksi_asli; 
run;

/*membandingkan rating aktual dengan rating prediksi*/
proc tabulate data=prediksi_asli ;
class eksternal_rating i_eksternal_rating;
tables eksternal_rating, i_eksternal_rating * n;
run;

/*score cutnya di custom manual yang masuk kategori goo yaitu yg > 0.6*/
data prediksi_asli2;
	set prediksi_asli;
	if P_OK > 0.6 then prediksi_rating = "OK";
	else prediksi_rating = "NO";
run;

/*menampilkan kurva ROC menambahkan option plots*/
proc logistic data = c.rating outmodel = modelrating plots=roc; /*menyimpan modelnya dengan out*/
model eksternal_rating (event = "OK" )=
	return_on_equity
	return_on_asset
	cost_to_income_ratio
;
run;

/*melakukan diskretisasi variabel roe*/
proc hpbin data=c.rating numbin=10;
	input return_on_equity;
	ods output mapping=map;
run;

proc univariate data=c.rating;
	var return_on_equity;
run;

data batasroe;
	input variable$20.  binnedvariable $  LB UB Range $ Bin;
	cards;
	return_on_equity bin . 0.07	x<0.07	1
	return_on_equity bin 0.07 0.17	0.07<x<0.17	2
	return_on_equity bin 0.17 0.27	0.17<x<0.27	3
	return_on_equity bin 0.27 . x>0.27	4
run;

proc hpbin data=c.rating WOE BINS_META=batasroe;
target eksternal_rating /level=nominal;
run;





