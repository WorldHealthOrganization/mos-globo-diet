/*Sept 2017 - By AM*/
/*MALTA SURVEY*/
/*Unique dataset for analyses*/
*creation of 2 datasets
ALL- 2 lines per individuals (2 interviews)
DAYS - 1 line per individuals (transpose of interview information)*/

/************************************************************/
OPTION LINESIZE=256 PAGESIZE=1000 COMPRESS=BINARY NOCENTER ;
LIBNAME A       '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses';
LIBNAME library '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses';
%include "\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses\0-Formats.sas";



PROC SORT DATA=A.INTGI; BY ID_NUM DATE_REC; RUN;
PROC SORT DATA=A.INTAKES; BY ID_NUM DATE_REC;RUN;
PROC SORT DATA=A.NUTRIENTS; BY ID_NUM DATE_REC;RUN;

data ALL onlyINTGI onlyIntakes onlyNut;
	merge A.INTGI(in=a) A.INTAKES(in=b) A.NUTRIENTS(in=c);
	by ID_NUM date_rec;
	if a and b and c then output ALL;
	if a and ^b and ^c then output onlyINTGI; 
	if ^a and b  then output onlyIntakes; 
	if ^a and c then output onlyNut; 
run;
PROC SORT DATA=ALL; BY ID_NUM DATE_REC;RUN;

PROC CONTENTS DATA=ALL ; RUN ;

/*KEEP ONLY IN THE DATABASE SUBJECTS WITH two 24HDR*/
proc freq data=A.INTGI; tables int_num;run;
data INT1 (keep=ID_NUM date_rec); SET ALL; If int_num=1;run;
data INT2(keep=ID_NUM date_rec); SET ALL; If int_num=2;run;
PROC SORT DATA=INT1; BY ID_NUM date_rec;RUN;
PROC SORT DATA=INT2; BY ID_NUM date_rec;RUN;
*dataset with id_num with two 24HDR;
data two only1 only2;
	merge INT1(in=a) INT2(in=b);
	by ID_NUM;
	if a and b then output two;
	if a and ^b then output only1; 
	if ^a and b then output only2; 
run;
*check that no duplicates in ID_NUM;
proc sql; select count (distinct id_num) from two;quit;
*KEEP only subjects with two 24HDR;
proc sql; create table ALL as select * from ALL where id_num in (select distinct ID_NUM from two); Quit;

*correct error in sex for ID_NUM='1254'; /*DATA ALL; SET ALL;IF ID_NUM='1254' then SEX='2';RUN;*/



/*MACROS*/
/*LOG TRANSFORMATION*/
%MACRO LOGTRANS(DB,VAR, LVAR);
DATA &DB; SET &DB;
&LVAR= LOG(&VAR + 1);
RUN;
%MEND;
/*MEAN OF 2 INTERVIEWS*/
%MACRO TRMEAN(DB,VAR1,VAR2, NEWV);
DATA &DB; SET &DB;
&NEWV= (&VAR1 + &VAR2)/2;
RUN;
%MEND;


/*CALCULATION OF MACRO NUTRIENTS IN PERCENTAGES OF ENERGY*/
DATA ALL; SET ALL;
*apply the conversion coefficients ;
EN_ALC=RALCOHOL*7;
EN_CARB=RCARBOHYDRATE*4;
EN_PROT=RPROTEIN*4;
EN_FAT=RTOTFAT*9;
*transformation in percent of energy;
P_EN_ALC=round (((EN_ALC/RENERGY)*100),0.01);
P_EN_CARB=round (((EN_CARB/RENERGY)*100),0.01);
P_EN_PROT=round (((EN_PROT/RENERGY)*100),0.01);
P_EN_FAT=round (((EN_FAT/RENERGY)*100),0.01);
*calculation of log percent of energy;
TEMP_ALC=((EN_ALC+1)/RENERGY)*100;
TEMP_CARB=((EN_CARB+1)/RENERGY)*100;
TEMP_PROT=((EN_PROT+1)/RENERGY)*100;
TEMP_FAT=((EN_FAT+1)/RENERGY)*100;

L_P_EN_ALC=round (LOG(TEMP_ALC),0.01);
L_P_EN_CARB=round (LOG(TEMP_CARB),0.01);
L_P_EN_PROT=round (LOG(TEMP_PROT),0.01);
L_P_EN_FAT=round (LOG(TEMP_FAT),0.01);

RUN;

*log transformation of foodgroups &nutrient variables in the dataset ALL (2 lines per individual);
%LOGTRANS(ALL,GR01,LOGGR01);
%LOGTRANS(ALL,GR02,LOGGR02);
%LOGTRANS(ALL,GR03,LOGGR03);
%LOGTRANS(ALL,GR04,LOGGR04);
%LOGTRANS(ALL,GR05,LOGGR05);
%LOGTRANS(ALL,GR06,LOGGR06);
%LOGTRANS(ALL,GR07,LOGGR07);
%LOGTRANS(ALL,GR08,LOGGR08);
%LOGTRANS(ALL,GR09,LOGGR09);
%LOGTRANS(ALL,GR10,LOGGR10);
%LOGTRANS(ALL,GR11,LOGGR11);
%LOGTRANS(ALL,GR12,LOGGR12);
%LOGTRANS(ALL,GR13,LOGGR13);
%LOGTRANS(ALL,GR14,LOGGR14);
%LOGTRANS(ALL,GR15,LOGGR15);
%LOGTRANS(ALL,GR16,LOGGR16);
%LOGTRANS(ALL,GR17,LOGGR17);
%LOGTRANS(ALL,GR18,LOGGR18);
%LOGTRANS(ALL,RALCOHOL,LOGALC);
%LOGTRANS(ALL,RCARBOHYDRATE,LOGCARB);
%LOGTRANS(ALL,RENERGY,LOGENER);
%LOGTRANS(ALL,RPROTEIN,LOGPROT);
%LOGTRANS(ALL,RTOTFAT,LOGFAT);

/*creation of 2 databases, one for each day of 24HDR*/
proc sql;
	create table DAY1 as select 
		  ID_NUM
		, DB as DB1
		, sex as SEX1
		, birth_Date as birth_Date1 
		, PAT_NAME as PAT_NAME1
		, DATE_REC as DATE_REC1 
		, DAY_REC as DAY_REC1
		, DAY_CL as DAYCL1
		, INT_DATE as INT_DATE1 
		, INT_DAY as INT_DAY1
		, HEIGHT as HEIGHT1
		, WEIGHT as WEIGHT1
		, BMI as BMI1
		, SPDAY as SPDAY1
		, SPDIET as SPDIET1
		, AGEREC as AGEREC1
		, AGECAT as AGECAT1
		, SEASONS2 as SEAS1_2
		, SEASONS4 as SEAS1_4
		, GR01 as GR01_1 
 		, GR02 as GR02_1
 		, GR03 as GR03_1 
		, GR04 as GR04_1 
 		, GR05 as GR05_1 
 		, GR06 as GR06_1 
 		, GR07 as GR07_1 
 		, GR08 as GR08_1 
		, GR09 as GR09_1 
 		, GR10 as GR10_1 
 		, GR11 as GR11_1 
 		, GR12 as GR12_1 
 		, GR13 as GR13_1 
 		, GR14 as GR14_1 
 		, GR15 as GR15_1 
 		, GR16 as GR16_1 
 		, GR17 as GR17_1 
 		, GR18 as GR18_1 
 		, RALCOHOL as RALCOHOL1
 		, RCARBOHYDRATE as RCARB1
 		, RENERGY as RENERGY1
 		, RPROTEIN as RPROTEIN1
 		, RTOTFAT as RTOTFAT1
from ALL
		where INT_NUM=1
		order by ID_NUM;

proc sql;
	create table DAY2 as select 
		  ID_NUM
		, DB as DB2
		, sex as SEX2
		, birth_Date as birth_Date2 
		, PAT_NAME as PAT_NAME2
		, DATE_REC as DATE_REC2 
		, DAY_REC as DAY_REC2
		, DAY_CL as DAYCL2
		, INT_DATE as INT_DATE2 
		, INT_DAY as INT_DAY2
		, HEIGHT as HEIGHT2
		, WEIGHT as WEIGHT2
		, BMI as BMI2
		, SPDAY as SPDAY2
		, SPDIET as SPDIET2
		, AGEREC as AGEREC2
		, AGECAT as AGECAT2
		, SEASONS2 as SEAS2_2
		, SEASONS4 as SEAS2_4
		, GR01 as GR01_2 
 		, GR02 as GR02_2 
 		, GR03 as GR03_2 
		, GR04 as GR04_2 
 		, GR05 as GR05_2 
 		, GR06 as GR06_2 
 		, GR07 as GR07_2 
 		, GR08 as GR08_2 
		, GR09 as GR09_2 
 		, GR10 as GR10_2 
 		, GR11 as GR11_2 
 		, GR12 as GR12_2 
 		, GR13 as GR13_2 
 		, GR14 as GR14_2 
 		, GR15 as GR15_2 
 		, GR16 as GR16_2 
 		, GR17 as GR17_2 
 		, GR18 as GR18_2 
 		, RALCOHOL as RALCOHOL2
 		, RCARBOHYDRATE as RCARB2
 		, RENERGY as RENERGY2
 		, RPROTEIN as RPROTEIN2
 		, RTOTFAT as RTOTFAT2
from ALL
		where INT_NUM=2
		order by ID_NUM;
quit;

PROC SORT DATA=DAY1; BY ID_NUM;RUN;
PROC SORT DATA=DAY2; BY ID_NUM;RUN;

*merge the two datasets and keep only subjects in both files=> only subjects with 2 interviews;
data DAYS onlyDAY1 onlyDAY2;
	merge DAY1(in=a) DAY2(in=b);
	by ID_NUM;
	if a and b then output DAYS;
	if a and ^b then output onlyDAY1; 
	if ^a and b then output onlyDAY2; 
run;


*calculation of the FG means based on average of the two 24HDR;
%TRMEAN(DAYS,GR01_1,GR01_2, M_GR01);
%TRMEAN(DAYS,GR02_1,GR02_2, M_GR02);
%TRMEAN(DAYS,GR03_1,GR03_2, M_GR03);
%TRMEAN(DAYS,GR04_1,GR04_2, M_GR04);
%TRMEAN(DAYS,GR05_1,GR05_2, M_GR05);
%TRMEAN(DAYS,GR06_1,GR06_2, M_GR06);
%TRMEAN(DAYS,GR07_1,GR07_2, M_GR07);
%TRMEAN(DAYS,GR08_1,GR08_2, M_GR08);
%TRMEAN(DAYS,GR09_1,GR09_2, M_GR09);
%TRMEAN(DAYS,GR10_1,GR10_2, M_GR10);
%TRMEAN(DAYS,GR11_1,GR11_2, M_GR11);
%TRMEAN(DAYS,GR12_1,GR12_2, M_GR12);
%TRMEAN(DAYS,GR13_1,GR13_2, M_GR13);
%TRMEAN(DAYS,GR14_1,GR14_2, M_GR14);
%TRMEAN(DAYS,GR15_1,GR15_2, M_GR15);
%TRMEAN(DAYS,GR16_1,GR16_2, M_GR16);
%TRMEAN(DAYS,GR17_1,GR17_2, M_GR17);
%TRMEAN(DAYS,GR18_1,GR18_2, M_GR18);
%TRMEAN(DAYS,RALCOHOL1,RALCOHOL2, MALC);
%TRMEAN(DAYS,RCARB1,RCARB2, MCARB);
%TRMEAN(DAYS,RENERGY1,RENERGY2, MENER);
%TRMEAN(DAYS,RPROTEIN1,RPROTEIN2, MPROT);
%TRMEAN(DAYS,RTOTFAT1,RTOTFAT2, MFAT);

*log transfo of the means variables;
%LOGTRANS(DAYS,M_GR01,LOGM_GR01);
%LOGTRANS(DAYS,M_GR02,LOGM_GR02);
%LOGTRANS(DAYS,M_GR03,LOGM_GR03);
%LOGTRANS(DAYS,M_GR04,LOGM_GR04);
%LOGTRANS(DAYS,M_GR05,LOGM_GR05);
%LOGTRANS(DAYS,M_GR06,LOGM_GR06);
%LOGTRANS(DAYS,M_GR07,LOGM_GR07);
%LOGTRANS(DAYS,M_GR08,LOGM_GR08);
%LOGTRANS(DAYS,M_GR09,LOGM_GR09);
%LOGTRANS(DAYS,M_GR10,LOGM_GR10);
%LOGTRANS(DAYS,M_GR11,LOGM_GR11);
%LOGTRANS(DAYS,M_GR12,LOGM_GR12);
%LOGTRANS(DAYS,M_GR13,LOGM_GR13);
%LOGTRANS(DAYS,M_GR14,LOGM_GR14);
%LOGTRANS(DAYS,M_GR15,LOGM_GR15);
%LOGTRANS(DAYS,M_GR16,LOGM_GR16);
%LOGTRANS(DAYS,M_GR17,LOGM_GR17);
%LOGTRANS(DAYS,M_GR18,LOGM_GR18);
%LOGTRANS(DAYS,MALC,LOGMALC);
%LOGTRANS(DAYS,MCARB,LOGMCARB);
%LOGTRANS(DAYS,MENER,LOGMENER);
%LOGTRANS(DAYS,MPROT,LOGMPROT);
%LOGTRANS(DAYS,MFAT,LOGMFAT);


DATA DAYS; SET DAYS;
*apply coefficient conversion;
EN_ALC1=RALCOHOL1*7;
EN_CARB1=RCARB1*4;
EN_PROT1=RPROTEIN1*4;
EN_FAT1=RTOTFAT1*9;

EN_ALC2=RALCOHOL2*7;
EN_CARB2=RCARB2*4;
EN_PROT2=RPROTEIN2*4;
EN_FAT2=RTOTFAT2*9;

*transfo in percent of energy;
P_EN_ALC1=round (((EN_ALC1/RENERGY1)*100),0.01);
P_EN_CARB1=round (((EN_CARB1/RENERGY1)*100),0.01);
P_EN_PROT1=round (((EN_PROT1/RENERGY1)*100),0.01);
P_EN_FAT1=round (((EN_FAT1/RENERGY1)*100),0.01);

P_EN_ALC2=round (((EN_ALC2/RENERGY2)*100),0.01);
P_EN_CARB2=round (((EN_CARB2/RENERGY2)*100),0.01);
P_EN_PROT2=round (((EN_PROT2/RENERGY2)*100),0.01);
P_EN_FAT2=round (((EN_FAT2/RENERGY2)*100),0.01);

*calculation of log percent of ener;
TEMP_ALC1=((EN_ALC1+1)/RENERGY1)*100;
TEMP_CARB1=((EN_CARB1+1)/RENERGY1)*100;
TEMP_PROT1=((EN_PROT1+1)/RENERGY1)*100;
TEMP_FAT1=((EN_FAT1+1)/RENERGY1)*100;

TEMP_ALC2=((EN_ALC2+1)/RENERGY2)*100;
TEMP_CARB2=((EN_CARB2+1)/RENERGY2)*100;
TEMP_PROT2=((EN_PROT2+1)/RENERGY2)*100;
TEMP_FAT2=((EN_FAT2+1)/RENERGY2)*100;

L_P_EN_ALC1=round (LOG(TEMP_ALC1),0.01);
L_P_EN_CARB1=round (LOG(TEMP_CARB1),0.01);
L_P_EN_PROT1=round (LOG(TEMP_PROT1),0.01);
L_P_EN_FAT1=round (LOG(TEMP_FAT1),0.01);

L_P_EN_ALC2=round (LOG(TEMP_ALC2),0.01);
L_P_EN_CARB2=round (LOG(TEMP_CARB2),0.01);
L_P_EN_PROT2=round (LOG(TEMP_PROT2),0.01);
L_P_EN_FAT2=round (LOG(TEMP_FAT2),0.01);
RUN;

*mean of percents;
%TRMEAN(DAYS,P_EN_ALC1,P_EN_ALC2, M_PER_ALC);
%TRMEAN(DAYS,P_EN_CARB1,P_EN_CARB2, M_PER_CARB);
%TRMEAN(DAYS,P_EN_PROT1,P_EN_PROT2, M_PER_PROT);
%TRMEAN(DAYS,P_EN_FAT1,P_EN_FAT2, M_PER_FAT);
*mean of log;
%TRMEAN(DAYS,L_P_EN_ALC1,L_P_EN_ALC2, M_L_PER_ALC);
%TRMEAN(DAYS,L_P_EN_CARB1,L_P_EN_CARB2, M_L_PER_CARB);
%TRMEAN(DAYS,L_P_EN_PROT1,L_P_EN_PROT2, M_L_PER_PROT);
%TRMEAN(DAYS,L_P_EN_FAT1,L_P_EN_FAT2, M_L_PER_FAT);


/*QUALITY CONTROLS*/
/*COMPARE HEIGHT AND WEIGHT AND SEX FROM DAY1 AND DAY2, FOR ALL AGES*/
DATA sexcheck; SET DAYS; where SEX1 ne SEX2;RUN;
PROC PRINT DATA=SEXCHECK; var db1 id_num sex1 date_rec1 sex2 date_rec2;run;
/*DATA agecheck; SET DAYS; where AGE1 >AGE2;RUN;*/
DATA agecheck; SET DAYS; where birth_Date1 ne birth_Date2;RUN;
PROC PRINT DATA=agecheck; var db1 id_num birth_Date1 PAT_NAME1 date_rec1 birth_Date2 PAT_NAME2 date_rec2 ;run;
PROC FREQ DATA=agecheck;
TABLES db1*id_num*birth_Date1*PAT_NAME1*date_rec1*birth_Date2*PAT_NAME2*date_rec2 /out=Freqcount_birthdate list;RUN;
/*data a (keep=CODE_INT ID_NUM DATE_REC PAT_NAME PAT_FNAME); set INTGI; where ID_NUM='1254';run;*/

/*DATA agecheck; SET DAYS; where AGE1 >AGE2;RUN;*/

/*HEIGHT & WEIGHT
Email Daniel 27/4/16
we have told interviewers that at the second interview, they need not check height and weight again in order to save time. We asked them to put '999'
in the height and weight boxes at the second interview to indicate that it is not measured. Shall I leave it like this, or would you like me to delete '999'*/

/*Email Daniel 1/07/16
Weight and height: We instructed interviews to only measured weight and height during the first interview. 
If I may, I'd like to suggest that all weight and height values listed in second interviews (i.e. whether '999' values or other values) should be replaced by blanks in order 
to avoid confusion.*/

/*data height_weight1; set DAYS;
	where height1^=height2 or weight1^=weight2;
	diffH=height2-height1;
	diffW=weight2-weight1;
run;
proc sql;
	create table height_weight2 as select
		  ID_NUM
		, height1
		, height2
		, weight1
		, weight2
	from height_weight1;
quit;
*/
* Selection less than 15 days more than 60 days between two interviews;
/*Email Daniel 1/07/16
Average time between the two interviews: I do not have an exact figure for this, my feeling is that it is around 5 weeks, 
based on the interviews I have cleaned so far. Sorry I can't be more accurate unfortunately :( */

data dur;
	set DAYS;
	diff_D1D2=DATE_REC2-DATE_REC1;
	if 15<=diff_D1D2=<90 then delete;
run;
proc sql;
	create table int_periode as select
		  ID_NUM
		 , DB1
		, DATE_REC1 
		, DATE_REC2
		, diff_D1D2 as periode_dur
	from dur;
quit;
PROC PRINT DATA=int_periode;run;

* Selection interview is not about yesterday;
data dif;
	set DAYS;
difference1=INT_DATE1-DATE_REC1; 
difference2=INT_DATE2-DATE_REC2; run;

proc sql;
	create table pbdif as select
		  ID_NUM
		 , DB1
		, DATE_REC1
		, DATE_REC2
		, INT_DATE1
		, INT_DATE2
		, difference1
		, difference2
	from dif
where difference1 ne 1 or difference2 ne 1;
quit;
 PROC PRINT DATA=PBDIF;RUN;






/*SAVE DATABASES*/
DATA A.ALL; set ALL;run;
DATA A.DAYS; set DAYS;run;

/*ADD SAMPLEWEIGHTS DATA*/
*%include "\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses\4-ImportSampleweights.sas";

/*ADD QUEST DATA*/
*%include "\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses\3-ImportQuest.sas";

/*Table by age sex*/
*TABLE WITH AGE CATEGORIES DEFINED BY TH NATIONAL STATISTICS OFFICE;
data DAYS; set DAYS;
if AGEREC1 lt 11 then AGECL=1; 
else if AGEREC1 ge 11 and AGEREC1 le 17 then AGECL=2;
else if AGEREC1 ge 18 and AGEREC1 le 30 then AGECL=3;
else if AGEREC1 ge 31 and AGEREC1 le 51 then AGECL=4;
else if AGEREC1 ge 52 and AGEREC1 le 64 then AGECL=5;
else if AGEREC1 gt 64 then AGECL=6;
RUN;

PROC FREQ DATA=DAYS;TABLES DB1*SEX1*AGECAT1 DB1*SEX1*AGECL SEX1*AGECL/missing list;RUN;
