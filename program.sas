/*PART 1*/

/*membuat libname*/
libname a "D:\pelatihan\[SAS] ganesha - credit scoring [2019]";

/*import data*/
PROC IMPORT 	OUT= A.datapraktek 
            	DATAFILE= "D:\pelatihan\[SAS] ganesha - credit scoring [2019]\datascoring.csv" 
            	DBMS=CSV REPLACE;
     		GETNAMES=YES;
     		DATAROW=2; 
RUN;

/*sebaran umur*/
proc univariate data=a.datapraktek;
	var age;
	histogram age;
run;

/*binning variable age*/
data a.datapraktek;
	set a.datapraktek;
	if age <= 25 then agegroup = 1;
	else if age <= 30 then agegroup = 2;
	else if age <= 35 then agegroup = 3;
	else if age <= 40 then agegroup = 4;
	else if age <= 45 then agegroup = 5;
	else agegroup = 6;
run;

proc tabulate data=a.datapraktek;
	class agegroup;
	table agegroup all, n colpctn;
run;

/*Sebaran Number of Dependants*/
proc tabulate data=a.datapraktek;
	class number_of_dependants;
	table number_of_dependants all, n colpctn;
run;

/*PART 2*/

**** menghitung WOE dari variabel GENDER ***;
* tahapan:   1. Menghitung P(Gender | Good) dan P(Gender|Bad);
proc tabulate data=a.datapraktek out=woegender;
	class gender status;  
	tables gender, status*colpctn; 
run;

proc transpose data=woegender out=woegender;
	var pctn_01;  by gender;  id status;  
run;

* tahapan:   2. hitung WoE dengan formula  WoE = log(P(-|GOOD)/P(-|BAD));
data woegender;
	set woegender; 
	woegender = log(GOOD / BAD); 
run;

* tahapan:   3. Berikan nilai WoE Gender pada data lengkap (datascoring);
data woegender (keep = gender woegender);
	set woegender;  
run;

proc sort data=a.datapraktek;
	by gender; 
run;

data a.datapraktek;
	merge a.datapraktek woegender;  
	by gender; 
run;

proc print data=woegender;
run;

/*Perhitungan Woe : Residence*/
**** menghitung WOE dari variabel RESIDENCE ***;
proc tabulate data=a.datapraktek out=WOEresidence;
	class residence_ownership status; 
	tables residence_ownership, status*colpctn; 
run;

proc transpose data=woeresidence out=woeresidence;
	var pctn_01;  
	by residence_ownership;  
	id status;  
run;

data WOEresidence;
	set WOEresidence;  
	WOEresidence = log(GOOD / BAD);  
run;

data woeresidence   (keep = residence_ownership woeresidence);
	set woeresidence;
run;

proc sort data=a.datapraktek;
	by residence_ownership ; 
run;

data a.datapraktek;
	merge a.datapraktek woeresidence;
	by residence_ownership ;
run;

proc print data=woeresidence;
run;

/*2.1 Perhitungan Woe : AgeGroup*/
**** menghitung WOE dari variabel agegroup ***;
proc tabulate data=a.datapraktek out=WOEagegroup;
	class agegroup status;   
	tables agegroup, status*colpctn;  
run;

proc transpose data=woeagegroup out=woeagegroup;
	var pctn_01;  
	by agegroup;  
	id status;  
run;

data WOEagegroup;
	set WOEagegroup;  
	WOEagegroup = log(GOOD / BAD);  
run;

data woeagegroup (keep = agegroup woeagegroup);
	set woeagegroup;  
run;

proc sort data=a.datapraktek;
	by agegroup;  
run;

data a.datapraktek;
	merge a.datapraktek woeagegroup;  
	by agegroup;  
run;

proc print data=woeagegroup;
run;


/*2.1 Perhitungan Woe : Number of Dependants*/
* Menghitung WoE untuk variabel NUMBER OF DEPENDANTS;
proc tabulate data=a.datapraktek;
	class number_of_dependants;  
	tables number_of_dependants, n colpctn;  
run;

proc tabulate data=a.datapraktek out=WOEdependants;
	class number_of_dependants status;  
	tables number_of_dependants, status*colpctn;  
run;

proc transpose data=woedependants out=woedependants;
	var pctn_01;  
	by number_of_dependants;   
	id status;  
run;

data WOEdependants;  
	set WOEdependants;  
	WOEdependants = log(GOOD / BAD);  
run;

data woedependants (keep = number_of_dependants woedependants);
	set woedependants;  
run;

proc sort data=a.datapraktek;  
	by number_of_dependants;  
run;

data a.datapraktek;
	merge a.datapraktek woedependants;  
	by number_of_dependants;  
run;

proc print data=woedependants;
run;

/*2.2 Perhitungan IV : Gender*/

**** menghitung INFORMATION VALUE dari GENDER;
proc tabulate data=a.datapraktek out=WOEgender;
	class gender status;
	tables gender, status*colpctn;
run;
proc transpose data=woegender out=woegender;
	var pctn_01;
	by gender;
	id status;
run;
data WOEgender;
	set WOEgender;
	WOEgender = log(GOOD / BAD);
	IVgender = (GOOD - BAD) * WOEgender /100;
run;
proc tabulate data=WOEgender;
	var IVgender;
	tables sum, IVgender;
run;

/*2.2 Perhitungan IV : Residence*/
proc tabulate data=a.datapraktek out=WOEresidence;
	class residence_ownership status;
	tables residence_ownership, status*colpctn;
run;
proc transpose data=woeresidence out=woeresidence;
	var pctn_01;
	by residence_ownership;
	id status;
run;
data WOEresidence;
	set WOEresidence;
	WOEresidence = log(GOOD / BAD);
	IVresidence = (GOOD - BAD) * WOEresidence / 100;
run;
proc tabulate data=WOEresidence;
	var IVresidence;
	tables sum, IVresidence;
run;

/*2.2 Perhitungan IV : AgeGroup*/
proc tabulate data=a.datapraktek out=WOEagegroup;
	class agegroup status;
	tables agegroup, status*colpctn;
run;
proc transpose data=woeagegroup out=woeagegroup;
	var pctn_01;
	by agegroup;
	id status;
run;
data WOEagegroup;
	set WOEagegroup;
	WOEagegroup = log(GOOD / BAD);
	IVagegroup = (GOOD - BAD) * WOEagegroup / 100;
run;
proc tabulate data=WOEagegroup;
	var IVagegroup;
	tables sum, IVagegroup;
run;

/*2.2 Perhitungan IV : Number of Dependants*/
proc tabulate data=a.datapraktek out=WOEdependants;
	class number_of_dependants status;
	tables number_of_dependants, status*colpctn;
run;
proc transpose data=woedependants out=woedependants;
	var pctn_01;
	by number_of_dependants;
	id status;
run;
data WOEdependants;
	set WOEdependants;
	WOEdependants = log(GOOD / BAD);
	IVdependants = (GOOD - BAD) * WOEdependants / 100;
run;
proc tabulate data=WOEdependants;
	var IVdependants;
	tables sum, IVdependants;
run;

/*3.1 Pemodelan Woe : Model Woe */
********* menentukan bobot masing-masing variabel;
proc logistic data=a.datapraktek outest=bobot;
	model status (event = 'GOOD') = WOEgender WOEagegroup WOEresidence WOEdependants;
run;

/*WOE*/
data WOEgender (keep = category WOE input);
	set WOEgender; length input $ 20;
	input = 'WOEgender'; 
	category = gender; 
	WOE = WOEgender;   
run;

data WOEagegroup (keep = category WOE input);
	set WOEagegroup; 
	length input $ 20;
	input = 'WOEagegroup'; 
	category = compress(agegroup); 
	WOE = WOEagegroup;  
run;

data WOEresidence (keep = category WOE input);
	set WOEresidence; 
	length input $ 20;
	input = 'WOEresidence'; 
	category = residence_ownership; 
	WOE = WOEresidence; 
run;

data WOEdependants (keep = category WOE input);
	set WOEdependants; 
	length input $ 20;
	input = 'WOEdependants'; 
	category = compress(number_of_dependants); 
	WOE = WOEdependants;
run;

data WOEall;
	set WOEgender WOEagegroup WOEresidence WOEdependants;
run;

proc print data=woeall;
run;


/*3.3 Perhitungan Skor*/
data _null_;
	set bobot;
	if _n_=1 then call symput("b0", intercept);
	if _n_=1 then call symput("bgender", WOEgender);
	if _n_=1 then call symput("bagegroup", WOEagegroup);
	if _n_=1 then call symput("bresidence", WOEresidence);
	if _n_=1 then call symput("bdependants", WOEdependants);
run;

data WOEall (drop = factor offset);
	set WOEall;
	Factor = 20 / log (2);
	Offset = 600 - factor * log (50);
	if input = 'WOEgender' then score = (&bgender * WOE + &b0 / 4) * factor + offset / 4;
	if input = 'WOEagegroup' then score = (&bagegroup * WOE + &b0 / 4) * factor + offset / 4;
	if input = 'WOEresidence' then score = (&bresidence * WOE + &b0 / 4) * factor + offset / 4;
	if input = 'WOEdependants' then score = (&bdependants * WOE + &b0 / 4) * factor + offset / 4;
	score = round(score);
run;

proc print data=WOEall;
run;


/*4.1 Perhitungan Skor*/

data a.datapraktek;
	set a.datapraktek;
	Factor = 20 / log (2);
	Offset = 600 - factor * log (50);
	SCOREgender = round((&bgender * WOEgender + &b0 / 4) * factor + offset / 4);
	SCOREagegroup = round((&bagegroup * WOEagegroup + &b0 / 4) * factor + offset / 4);
	SCOREresidence = round((&bresidence * WOEresidence + &b0 / 4) * factor + offset / 4);
	SCOREdependants = round((&bdependants * WOEdependants + &b0 / 4) * factor + offset / 4);
	SCOREtotal = sum(SCOREgender, SCOREagegroup, SCOREresidence, SCOREdependants);
run;

proc print data=a.datapraktek (obs=10);
run;

/*4.2 Prediksi Status Skor*/
data a.datapraktek;
	set a.datapraktek;
	if SCOREtotal > 500 then predict = "GOOD";
	else predict = "BAD ";
run;

proc print data=a.datapraktek (obs=10);
	var ID gender scoretotal predict;
run;

/*4.3 Evaluasi Skor: Status vs Prediksi_status*/
proc tabulate data=a.datapraktek;
	class status predict;
	table status, predict*(n pctn rowpctn);
run;

/*mencari akurasi spesi,sensi*/
data eval;
         input status prediksi Count;
         datalines;
         0 0  570
         0 1  183
         1 0  282
         1 1 1255
         ;
 proc sort data=eval;
         by descending status ascending prediksi;
         run;
      proc freq data=eval order=data;
         weight Count;
         tables status*prediksi;
         run;

/*mencari evaluasi model*/

%macro coba(batasbawah=480,batasatas=540);
%do i=%batasbawah %to %batasatas;
data data.datascoring;
set data.datascoring;
if SCOREtotal > &i then predict = "GOOD";
else predict = "BAD ";
run;


proc tabulate data=data.datascoring out=dd;
class status predict;
table status, predict*n;
run;

data _null_;
set dd;
if status = 'BAD' and predict = 'BAD' then call symput("bb", n);
if status = 'BAD' and predict = 'GOOD' then call symput("bg", n);
if status = 'GOOD' and predict = 'GOOD' then call symput("gg", n);
if status = 'GOOD' and predict = 'BAD' then call symput("gb", n);
run;

data hasil;
threshold = &i;
akurasi = (&bb + &gg) / (&bb + &bg + &gb + &gg);
acceptancerate = (&bg + &gg) / (&bb + &bg + &gb + &gg);
badrate = &bg / (&bg + &gg);
run;

proc append data=hasil base=hasil1 force;
run;
%end;
%mend;
%coba;

*bentuknya line
Symbol1 i=join;

*scatter 
Symbol1;

Proc gplot data=hasil;
	Plot acceptancerate*;
Run;








/*4.4 Distribusi Skor*/
proc sort data=a.datapraktek;
	by status;

proc kde data=a.datapraktek;
	univar SCOREtotal / out=density bwm=3;
	by status;
run;

symbol1 i=join w=2;
symbol2 i=join w=2;
proc gplot data=density;
	plot density*value=status;
run;
quit;


/*K-S test*/
/*binning manual*/
data a.datapraktek;
	set a.datapraktek;
	if SCOREtotal <= 415 then range_score = 1;
	else if SCOREtotal <= 430 then range_score = 2;
	else if SCOREtotal <= 445 then range_score = 3;
	else if SCOREtotal <= 460 then range_score = 4;
	else if SCOREtotal <= 475 then range_score = 5;
	else if SCOREtotal <= 490 then range_score = 6;
	else if SCOREtotal <= 505 then range_score = 7;
	else if SCOREtotal <= 520 then range_score = 8;
	else if SCOREtotal <= 535 then range_score = 9;
	else if SCOREtotal <= 550 then range_score = 10;
	else if SCOREtotal <= 565 then range_score = 11;
	else if SCOREtotal <= 580 then range_score = 12;
	else if SCOREtotal <= 595 then range_score = 13;
	else if SCOREtotal <= 610 then range_score = 14;
	else if SCOREtotal <= 625 then range_score = 15;
	else if SCOREtotal <= 640 then range_score = 16;
	else if SCOREtotal <= 655 then range_score = 17;
	else range_score = 18;
run;


proc print data=a.datapraktek (obs=10);
run;

proc tabulate data=a.datapraktek out=tabel;
	class range_score status;
	table range_score*n, status ;
run;


/*tabel k-s*/
proc transpose data=tabel out=tabel;
	var n;
	by range_score;
	id status;
run;

data tabel;
	set tabel;
	if bad = . then bad = 0;
	if good = . then good = 0;
run;

/*membuat tabel ks untuk menghitung kumulatif*/
proc iml;
use tabel; /*mengubah dataset jadi matrix namanya x*/
read all var {bad, good} into x; /*var yg dibaca hanya bad dan good*/
close tabel;

sum = repeat({0 0}, nrow(x),1);
do i=1 to nrow(x);
if i = 1 then sum[i,] = x[i,]; /*penambahan baris hingga kumulatif bisa di dapat*/
else sum[i,] = sum[i-1,] + x[i,];
end;

pct = sum;
do i=1 to ncol(sum);
pct[,i] = pct[,i]/sum[nrow(x),i] *100;
end;
KS = abs(pct[,1] - pct[,2]);
hasil = sum||pct||KS;
create KS from hasil; /*menghasilkan sas data set bernama ks*/
append form hasil;
quit;

data Ks_all;
rename col3=kum_bad col4=kum_good col5=selisih_kum;
	merge  tabel KS;
run;

proc print data = Ks_all;
	var range_score bad good kum_bad kum_good selisih_kum;
run;

proc gplot data=Ks_all; 
plot col3*range_score;
plot2 col4*range_score;
run;
