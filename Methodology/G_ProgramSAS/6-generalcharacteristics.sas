
/*---------------------------------*/
/*STATISTICAL ANALYSES*/
/*---------------------------------*/
/*prog by AM - August 2016 and oct 2017*/

/*SAS script for analyses*/
/*Table with General characteristics*/

/*with and without correction for sample weights*/

OPTION LINESIZE=256 PAGESIZE=1000 COMPRESS=BINARY NOCENTER ;
LIBNAME A       '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses';
LIBNAME library '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses';
%include "\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses\0-Formats.sas";

DATA ALL; set A.ALL;run;
DATA DAYS; set A.DAYS;run;
proc contents data=days;run;

/*Table by Age categories defined by the National Statistics Office*/
*temp table;
data DAYS; set DAYS;
if AGEREC1 lt 11 then AGECL=1; 
else if AGEREC1 ge 11 and AGEREC1 le 17 then AGECL=2;
else if AGEREC1 ge 18 and AGEREC1 le 30 then AGECL=3;
else if AGEREC1 ge 31 and AGEREC1 le 51 then AGECL=4;
else if AGEREC1 ge 52 and AGEREC1 le 64 then AGECL=5;
else if AGEREC1 gt 64 then AGECL=6;
RUN;

/*when inconsistencies between age group and age from 24HRD-> priority given to age at interv*/
PROC FREQ DATA=DAYS;
	TABLES SEX1*AGECL SEX1*AGE_GROUP SEX1*AGECL*AGE_GROUP/missing list;
RUN;

/*KEEP ONLY SUBJECTS WITH 2 24HDR & QUEST??*/
/*
DATA ALL; set ALL; if lang='' then delete; run;
DATA DAYS; set DAYS;if lang='' then delete; run;
*/

/*QC btw FFQ and 24HDR sent to Daniel 19/8/16 -> to be corrected before preparation of table1*/
/*sex*/
proc freq data=DAYS;
	tables gender*sex1 gender*sex2/nocol norow nopercent;
run;
proc print data=DAYS; 
var id /*subject_id*/ gender sex1 sex2 id_num date_rec1;
where gender=1 and SEX1="2";
run;
proc print data=days; 
var id gender sex1 sex2 sex id_num date_rec1;
where gender=2 and SEX1="1";
run;

proc print data=DAYS; 
var id /*subject_id*/ gender sex1 sex id_num date_rec1;
where gender=2 and SEX1="1";
run;
/*proc print data=DAYS; 
var id subject_id gender sex1 sex id_num date_rec1;
where gender=1 and sex='Female';
run;
proc print data=DAYS; 
var id  gender sex1 sex2 id_num date_rec1;
where gender=-1;
run;*/


/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*creation of formats for Quest SES var*/
Proc format /*library=a */;
/*marit1*/
  Value fmaritstat
	-1 = 'Missing/dont know'
	1=	'Single'
	2=	'Married'        
	3=	'Widowed'
	4=	'Divorced';
/*educa*/
  Value feduca
	1	='No formal education    '
	2	='Schools for persons with special needs '
	3	='Primary        '
	4	='Secondary general      '
	5	='Secondary vocational training  '
	6	='Foundation courses     '
	7	='Post secondary         '
	8	='Post secondary vocational      '
	9	='Post secondary vocational<2 years      '
	10	='Post secondary vacational >2 years     '
	11	='University diploma/certificate '
	12	='Bachelor degree or equivalent  '
	13	='Postgraduate certificate/diploma       '
	14	='Masters degree '
	15	='PhD    '
	16	='Other'  ;
/*edu*/
  Value fedu
	1	='No formal education    '
	2	='Primary school'
	3	='Secondary school (general/vocational training)  '
	4	='Post secondary school /Foundation courses     '
	5	='Higher educ (University degree, Postgraduate diploma/certificate '
	6	='Other'  
	9	= 'Don t know';

/*income*/
  Value fincome
	-1 = 'Missing/dont know'
	1	='<895   '
	2	='895-1342       '
	3	='1343-1963      '
	4	='1964-2829      '
	5	='>2829  '
	;
/*smoking*/
  Value fsmoke
	-1 = 'Missing/dont know'
	1= 'Yes daily      '
	2='Yes occasionally'       
	3='Not at all     ';

 Value fpasts
	-1 = 'Missing/dont know'
1 = 'Yes '
2 ='No';   


RUN;



/*Distribution of Quest SES var with&without sample weight correction*/
/*Stratification by Sex (all age groups)
& because different questionnaires used, stratification by age (to separate adults >17 and children <18 in a 2nd table*/
PROC SORT DATA=DAYS; BY SEX1 ;RUN;
proc freq data=days; tables educa educa_F educa_M;run;

/*Education*/
/*create new var with less number of categories
*/
data DAYS; set DAYS;
if educa =1 then edu=1;
if educa =3 then edu=2;
if educa in (4,5) then edu=3;
if educa in (6,7,8,9,10) then edu=4;
if educa in (11,12,13,14,15) then edu=5;
if educa=16 then edu=6;
if educa in(-1,.) then edu=9;

if educa_F =1 then edu_F=1;
if educa_F =3 then edu_F=2;
if educa_F in (4,5) then edu_F=3;
if educa_F in (6,7,8,9,10) then edu_F=4;
if educa_F in (11,12,13,14,15) then edu_F=5;
if educa_F=16 then edu_F=6;
if educa_F in(-1,.) then edu_F=9;

if educa_M =1 then edu_M=1;
if educa_M =3 then edu_M=2;
if educa_M in (4,5) then edu_M=3;
if educa_M in (6,7,8,9,10) then edu_M=4;
if educa_M in (11,12,13,14,15) then edu_M=5;
if educa_M=16 then edu_M=6;
if educa_M in(-1,.) then edu_M=9;
RUN;
/*For adults, use edu variable*/
/*For children <18 use the 3 variable as followed:
when edu is filled, edu_child=edu_M & edu_F else */
proc freq data=DAYS; tables AGECL*sex1 agecl*sex1; format agecl fagegr.;run;
proc freq data=DAYS; tables AGECL*age_group sex1*AGECL*age_group /nocol norow nopercent; format agecl fagegr.;run;

/*adults*/
proc freq data=DAYS;
	tables educa edu /*edu_F edu_M *//nocol norow nopercent missing;
	format edu fedu. /*edu_F fedu. edu_M fedu.*/ educa feduca.;
	where AGECL not in (1,2);
	by sex1;
run;
/*children*/
proc freq data=DAYS;
	tables /*educa*/ edu edu_F edu_M edu*edu_M edu*EDU_F EDU_M*EDU_F/nocol norow nopercent missing;
	format edu edu_F edu_M fedu. /*educa feduca.*/;
	where AGECL in (1,2);
	by sex1;
run;
data days; set days;
if AGECL=1 then do;
	if edu ne 9 then edu_child=edu; else do;
	edu_child=edu_M;
	end;
end;
run;
data days; set days;
if AGECL=1 then do;
	if edu_child ne 9 then do;
		if edu_F ne 9 then do;
			if edu_f>edu_child then edu_child=edu_F;
		end;
	end;
end;
RUN;
PROC FREQ DATA=DAYS;
tables EDU_CHILD EDU_CHILD*EDU_F/nocol norow nopercent missing;
	where AGECL in (1,2);
	by sex1;
RUN;




title;
*tables with general characteristics based on 899 subjects incl those without questionnaires -> incl. in unknown categories;
*classify missing values in the unknown categories;
proc freq data=days; tables district marit1 edu income smoking past_1 smoking*past_1;run;
data days_complete; set days; 
if marit1=. then marit1=-1;
if income=. then income=-1;
if smoking=. then smoking=-1;
if past_1=. then past_1=-1;
run;

 ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\SESquest_characteristics.rtf';
*General table with age and sex based on age-group categories provided by the National statistics office;
proc freq data=days_complete; 
	tables AGECL*sex1 Age_group*sex/*/nocol norow nopercent*/;  format agecl fagegr.;
*WEIGHT sampleweight;
run;
proc freq data=days_complete; 
	tables AGECL*sex1 Age_group*sex/*/nocol norow nopercent*/;  format agecl fagegr.;
WEIGHT sampleweight;
run;

*Adults;
title 'Adults characteristics by sex';
proc freq data=days_complete; 
	tables district marit1 edu income smoking past_1 smoking*past_1;
*WEIGHT sampleweight;
format income fincome. smoking fsmoke. marit1 fmaritstat. edu fedu. past_1 fpasts.;
where AGECL not in (1,2); format agecl fagegr.;
by sex1 ;
run;
title 'Adults characteristics by sex with weights';

proc freq data=days_complete;
	tables district marit1 edu income smoking past_1 smoking*past_1;
WEIGHT sampleweight;
format income fincome. smoking fsmoke. marit1 fmaritstat. edu fedu. past_1 fpasts.;
where AGECL not in (1,2);  format agecl fagegr.;
by sex1 ;
run;

title 'Adults characteristics both sex combined';
*both sexes combined;
proc freq data=days_complete; 
	tables district marit1 edu income smoking past_1 smoking*past_1;
*WEIGHT sampleweight;
format income fincome. smoking fsmoke. marit1 fmaritstat. edu fedu. past_1 fpasts.;
where AGECL not in (1,2);  format agecl fagegr.;
run;
title 'Adults characteristics both sex combined with weights';
proc freq data=days_complete; 
	tables district marit1 edu income smoking past_1 smoking*past_1;
WEIGHT sampleweight;
format income fincome. smoking fsmoke. marit1 fmaritstat. edu fedu. past_1 fpasts.;
where AGECL not in (1,2);  format agecl fagegr.;
run;
/*
EDU AMONG 25-50 ONLY*/
title 'Education among 25-50y by sex';
*Adults;
proc freq data=days_complete; 
	tables edu;
format edu fedu. ;
where agerec1 >24 and agerec1<51;
by sex1 ;
run;
title 'Education among 25-50y by sex with weights';
proc freq data=days_complete; 
	tables edu ;
WEIGHT sampleweight;
format edu fedu. ;
where agerec1 >24 and agerec1<51;
by sex1 ;
run;
title 'Education among 25-50y  both sexes combined';
*both sexes combined;
proc freq data=days_complete; 
	tables edu ;
format edu fedu. ;
where agerec1 >24 and agerec1<51;
run;
title 'Education among 25-50y with weights both sexes combined';
proc freq data=days_complete; 
	tables edu ;
WEIGHT sampleweight;
format edu fedu. ;
where agerec1 >24 and agerec1<51;
run;

*Children;
title 'children characteristcis by sex';
proc freq data=days_complete; 
	tables district marit1 edu_M edu_F income smoking past_1 smoking*past_1;
*WEIGHT sampleweight;
format income fincome. smoking fsmoke. marit1 fmaritstat. edu_M edu_F fedu. past_1 fpasts.;
where AGECL in (1,2);  format agecl fagegr.;
by sex1 ;
run;
title 'children characteristcis by sex with weights';
proc freq data=days_complete; 
	tables district marit1 edu_M edu_F  income smoking past_1 smoking*past_1;
WEIGHT sampleweight;
format income fincome. smoking fsmoke. marit1 fmaritstat. edu_M edu_F fedu. past_1 fpasts.;
where AGECL in (1,2);  format agecl fagegr.;
by sex1 ;
run;

*both sexes combined;
title 'children characteristcis both sex combined';
proc freq data=days_complete; 
	tables district marit1 edu_M edu_F income smoking past_1 smoking*past_1;
*WEIGHT sampleweight;
format income fincome. smoking fsmoke. marit1 fmaritstat. edu_M edu_F fedu. past_1 fpasts.;
where AGECL in (1,2);  format agecl fagegr.;
run;
title 'children characteristcis with weights both sex combined';
proc freq data=days_complete; 
	tables district marit1 edu_M edu_F  income smoking past_1 smoking*past_1;
WEIGHT sampleweight;
format income fincome. smoking fsmoke. marit1 fmaritstat. edu_M edu_F fedu. past_1 fpasts.;
where AGECL in (1,2);  format agecl fagegr.;
run;
ods rtf close;
/*Anthropometric measures*/
/*HEIGHT1 WEIGHT1 BMI1 waist1*/
title;





























