
/*---------------------------------*/
/*STATISTICAL ANALYSES*/
/*---------------------------------*/
/*prog by AM - July 2016 and oct 2017*/

/*SAS script for preliminary report and final analyses*/

OPTION LINESIZE=256 PAGESIZE=1000 COMPRESS=BINARY NOCENTER ;
LIBNAME A       '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses';
LIBNAME library '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses';
%include "\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses\0-Formats.sas";

*correct error in sex for ID_NUM='1254'->female;
*correct error in sex for ID_NUM='1203'->female;;
/*DATA A.ALL; SET A.ALL;
IF ID_NUM='1254' then SEX='2';
IF ID_NUM='1203' then SEX='2';
RUN;
DATA A.DAYS; SET A.DAYS;
IF ID_NUM='1254' then do ; SEX='2'; SEX1='2'; SEX2='2';end;
IF ID_NUM='1203' then do ; SEX='2'; SEX1='2'; SEX2='2';end;
RUN;*/

DATA DAYS; SET A.DAYS; RUN;
DATA ALL; SET A.ALL; RUN;
PROC CONTENTS data=days;RUN;

data DAYS; set DAYS;
if AGEREC1 lt 11 then AGECL=1; 
else if AGEREC1 ge 11 and AGEREC1 le 17 then AGECL=2;
else if AGEREC1 ge 18 and AGEREC1 le 30 then AGECL=3;
else if AGEREC1 ge 31 and AGEREC1 le 51 then AGECL=4;
else if AGEREC1 ge 52 and AGEREC1 le 64 then AGECL=5;
else if AGEREC1 gt 64 then AGECL=6;
RUN;
DATA ALL; SET A.ALL;
if AGEREC lt 11 then AGECL=1; 
else if AGEREC ge 11 and AGEREC le 17 then AGECL=2;
else if AGEREC ge 18 and AGEREC le 30 then AGECL=3;
else if AGEREC ge 31 and AGEREC le 51 then AGECL=4;
else if AGEREC ge 52 and AGEREC le 64 then AGECL=5;
else if AGEREC gt 64 then AGECL=6;
RUN;


/*KEEP ONLY SUBJECTS WITH 2 24HDR & QUEST?? not sure
DATA ALL; set ALL; if lang='' then delete; run;
DATA DAYS; set DAYS;if lang='' then delete; run;
*/
/*DATASET WITH ONLY SUBJECTS THAT HAVE 2 INTW*/
*INTERVIEW DESCRIPTION;
PROC FREQ DATA=ALL; TABLE PRO_CODE PRO_COUNTRY PRO_LANGUAGE PRO_RELEASE VERSION COUNTRY CENTER INT_DAY DAY_REC SPDIET SPDAY; RUN ;
*SUBJECT INFO - SEX AGE - WEIGHT HEIGHT AND BMI AT 1st INT;
PROC FREQ DATA=DAYS; TABLES SEX1 AGECAT1; RUN;
*DESCRIPTION PER INT;
PROC FREQ DATA=DAYS; TABLES DAY_REC1 SEAS1_2 SEAS1_4 SPDAY1 SPDIET1 DAY_REC2 DAYCL1 SEAS2_2 SEAS2_4 SPDAY2 SPDIET2 DAYCL2; RUN;


PROC FREQ DATA=DAYS; TABLES SEX1 AGE_GROUP AGECAT1 /*AGEREC1*/;RUN;
PROC MEANS DATA=DAYS; VAR HEIGHT1 WEIGHT1 BMI1 WAIST1;RUN;
/*MACROS*/
/*Calculation of means*/
%MACRO PERC(DB,VAR, CVAR);
PROC MEANS DATA=&DB NOPRINT ;
  VAR &VAR ;
  CLASS &CVAR;
  OUTPUT OUT=T1 N=N NMISS=NMISS MIN=MIN P1=P1 P5=P5 P10=P10 
      P25=P25 MEAN=MEAN STD=STD P50=P50 P75=P75 P90=P90 P95=P95 P99=P99 MAX=MAX;
RUN ;
DATA T2(RENAME=(_FREQ_=N)) ; 
  LENGTH LVAR $12. ; 
  SET T1 ; 
  LVAR="&VAR" ; 
RUN ;
PROC SORT DATA=T2 ; BY LVAR ; RUN ;
DATA DBO ; SET DBO T2 ; RUN ;
%MEND;
/*Calculation of means with the weight option*/
%MACRO PERC_WT(DB,VAR, CVAR,WTVAR);
PROC MEANS DATA=&DB NOPRINT ;
  VAR &VAR ;
  CLASS &CVAR;
  WEIGHT &WTVAR;
  OUTPUT OUT=T1 N=N NMISS=NMISS MIN=MIN P1=P1 P5=P5 P10=P10 
      P25=P25 MEAN=MEAN STD=STD P50=P50 P75=P75 P90=P90 P95=P95 P99=P99 MAX=MAX;
RUN ;
DATA T2(RENAME=(_FREQ_=N)) ; 
  LENGTH LVAR $12. ; 
  SET T1 ; 
  LVAR="&VAR" ; 
RUN ;
PROC SORT DATA=T2 ; BY LVAR ; RUN ;
DATA DBO_WT ; SET DBO_WT T2 ; RUN ;
%MEND;

/*CALCULATION OF PERCENTAGE OF NC*/
%MACRO CALNC(DB,VAR, CVAR);
data temp; set &DB;
if &VAR=0 then NC=1; else NC=0;
RUN;
PROC means data=temp NOPRINT  ;
  VAR NC ;
 CLASS &CVAR;
  OUTPUT OUT=TempNC SUM=nbNC;
RUN ;
DATA TempNC; set TempNC; rename _FREQ_=N;RUN;
DATA TempNC; SET TempNC; 
LVAR="&VAR" ; 
perNC=nbNC/N*100; 
RUN;
PROC SORT DATA=TempNC ; BY LVAR ; RUN ;
DATA TableNC ; SET TableNC TempNC ; RUN ;
%MEND;


*characteristics of participants;
*crude;
DATA DBO ; SET _NULL_; RUN ;
%PERC(DAYS,AGEREC1,  );
%PERC(DAYS,HEIGHT1, );
%PERC(DAYS,WEIGHT1,);
%PERC(DAYS,BMI1,);

%PERC(DAYS,AGEREC1,SEX1  );
%PERC(DAYS,HEIGHT1,SEX1 );
%PERC(DAYS,WEIGHT1,SEX1);
%PERC(DAYS,BMI1,SEX1);

%PERC(DAYS,AGEREC1,AGECL  );
%PERC(DAYS,HEIGHT1,AGECL );
%PERC(DAYS,WEIGHT1,AGECL);
%PERC(DAYS,BMI1,AGECL);*AGECAT1;

%PERC(DAYS,AGEREC1,SEX1 AGECL  );
%PERC(DAYS,HEIGHT1,SEX1 AGECL );
%PERC(DAYS,WEIGHT1,SEX1 AGECL);
%PERC(DAYS,BMI1,SEX1 AGECL);
*waist: remove missings;
DATA D; SET DAYS; IF WAIST1 in (-1, .) then delete; RUN;
%PERC(D,WAIST1,);
%PERC(D,WAIST1,SEX1);
%PERC(D,WAIST1,AGECL );
%PERC(D,WAIST1,SEX1 AGECL );


*weighted for sampling variables;
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(DAYS,AGEREC1, ,sampleweight );
%PERC_WT(DAYS,HEIGHT1, ,sampleweight  );
%PERC_WT(DAYS,WEIGHT1, ,sampleweight );
%PERC_WT(DAYS,BMI1, ,sampleweight );

%PERC_WT(DAYS,AGEREC1,SEX1 , sampleweight );
%PERC_WT(DAYS,HEIGHT1,SEX1 , sampleweight );
%PERC_WT(DAYS,WEIGHT1,SEX1 , sampleweight );
%PERC_WT(DAYS,BMI1,SEX1 , sampleweight );

%PERC_WT(DAYS,AGEREC1,AGECL ,sampleweight   );
%PERC_WT(DAYS,HEIGHT1,AGECL ,sampleweight  );
%PERC_WT(DAYS,WEIGHT1,AGECL ,sampleweight );
%PERC_WT(DAYS,BMI1,AGECL ,sampleweight );

%PERC_WT(DAYS,AGEREC1,SEX1 AGECL  ,sampleweight  );
%PERC_WT(DAYS,HEIGHT1,SEX1 AGECL  ,sampleweight );
%PERC_WT(DAYS,WEIGHT1,SEX1 AGECL ,sampleweight );
%PERC_WT(DAYS,BMI1,SEX1 AGECL ,sampleweight );

*waist: remove missings;
DATA D; SET DAYS; IF WAIST1in (-1, .) then delete;
%PERC_WT(D,WAIST1, ,sampleweight );
%PERC_WT(D,WAIST1,SEX1 , sampleweight );
%PERC_WT(D,WAIST1,AGECL ,sampleweight );
%PERC_WT(D,WAIST1,SEX1 AGECL ,sampleweight );

 ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\AgeDistribution-Anthropometry_finalAna.rtf';
title 'Age and Anthropometry';
proc print data=DBO;run;
title 'Age and Anthropometry with weights';
proc print data=DBO_WT;run;
ods rtf close;


title ;
*Check the distributions of FGrps;
DATA DBO ; SET _NULL_; RUN ;
*1st int - crude data;
%PERC(DAYS,GR01_1,  );
%PERC(DAYS,GR02_1,  );
%PERC(DAYS,GR03_1,  );
%PERC(DAYS,GR04_1,  );
%PERC(DAYS,GR05_1,  );
%PERC(DAYS,GR06_1,  );
%PERC(DAYS,GR07_1,  );
%PERC(DAYS,GR08_1,  );
%PERC(DAYS,GR09_1,  );
%PERC(DAYS,GR10_1,  );
%PERC(DAYS,GR11_1,  );
%PERC(DAYS,GR12_1,  );
%PERC(DAYS,GR13_1,  );
%PERC(DAYS,GR14_1,  );
%PERC(DAYS,GR15_1,  );
%PERC(DAYS,GR16_1,  );
%PERC(DAYS,GR17_1,  );
%PERC(DAYS,GR18_1,  );
%PERC(DAYS,RALCOHOL1,  );
%PERC(DAYS,RCARB1,  );
%PERC(DAYS,RENERGY1,  );
%PERC(DAYS,RPROTEIN1,  );
%PERC(DAYS,RTOTFAT1,  );

*2nd int - crude data;
%PERC(DAYS,GR01_2,  );
%PERC(DAYS,GR02_2,  );
%PERC(DAYS,GR03_2,  );
%PERC(DAYS,GR04_2,  );
%PERC(DAYS,GR05_2,  );
%PERC(DAYS,GR06_2,  );
%PERC(DAYS,GR07_2,  );
%PERC(DAYS,GR08_2,  );
%PERC(DAYS,GR09_2,  );
%PERC(DAYS,GR10_2,  );
%PERC(DAYS,GR11_2,  );
%PERC(DAYS,GR12_2,  );
%PERC(DAYS,GR13_2,  );
%PERC(DAYS,GR14_2,  );
%PERC(DAYS,GR15_2,  );
%PERC(DAYS,GR16_2,  );
%PERC(DAYS,GR17_2,  );
%PERC(DAYS,GR18_2,  );
%PERC(DAYS,RALCOHOL2,  );
%PERC(DAYS,RCARB2,  );
%PERC(DAYS,RENERGY2,  );
%PERC(DAYS,RPROTEIN2,  );
%PERC(DAYS,RTOTFAT2,  );

DATA DBO_WT ; SET _NULL_; RUN ;
*1st int - weighted data for sampling variables;
%PERC_WT(DAYS,GR01_1,  ,sampleweight  );
%PERC_WT(DAYS,GR02_1,  ,sampleweight  );
%PERC_WT(DAYS,GR03_1,  ,sampleweight  );
%PERC_WT(DAYS,GR04_1,  ,sampleweight  );
%PERC_WT(DAYS,GR05_1,  ,sampleweight  );
%PERC_WT(DAYS,GR06_1,  ,sampleweight  );
%PERC_WT(DAYS,GR07_1,  ,sampleweight  );
%PERC_WT(DAYS,GR08_1,  ,sampleweight  );
%PERC_WT(DAYS,GR09_1,  ,sampleweight  );
%PERC_WT(DAYS,GR10_1,  ,sampleweight  );
%PERC_WT(DAYS,GR11_1,  ,sampleweight  );
%PERC_WT(DAYS,GR12_1,  ,sampleweight  );
%PERC_WT(DAYS,GR13_1,  ,sampleweight  );
%PERC_WT(DAYS,GR14_1,  ,sampleweight  );
%PERC_WT(DAYS,GR15_1,  ,sampleweight  );
%PERC_WT(DAYS,GR16_1,  ,sampleweight  );
%PERC_WT(DAYS,GR17_1,  ,sampleweight  );
%PERC_WT(DAYS,GR18_1,  ,sampleweight  );
%PERC_WT(DAYS,RALCOHOL1,  ,sampleweight  );
%PERC_WT(DAYS,RCARB1,  ,sampleweight  );
%PERC_WT(DAYS,RENERGY1,  ,sampleweight  );
%PERC_WT(DAYS,RPROTEIN1,  ,sampleweight  );
%PERC_WT(DAYS,RTOTFAT1,   ,sampleweight );

*2nd int - weighted data for sampling variables;
%PERC_WT(DAYS,GR01_2,  ,sampleweight);
%PERC_WT(DAYS,GR02_2,  ,sampleweight);
%PERC_WT(DAYS,GR03_2,  ,sampleweight);
%PERC_WT(DAYS,GR04_2,  ,sampleweight);
%PERC_WT(DAYS,GR05_2,  ,sampleweight);
%PERC_WT(DAYS,GR06_2,  ,sampleweight);
%PERC_WT(DAYS,GR07_2,  ,sampleweight);
%PERC_WT(DAYS,GR08_2,  ,sampleweight);
%PERC_WT(DAYS,GR09_2,  ,sampleweight);
%PERC_WT(DAYS,GR10_2,  ,sampleweight);
%PERC_WT(DAYS,GR11_2,  ,sampleweight);
%PERC_WT(DAYS,GR12_2,  ,sampleweight);
%PERC_WT(DAYS,GR13_2,  ,sampleweight);
%PERC_WT(DAYS,GR14_2,  ,sampleweight);
%PERC_WT(DAYS,GR15_2,  ,sampleweight);
%PERC_WT(DAYS,GR16_2,  ,sampleweight);
%PERC_WT(DAYS,GR17_2,  ,sampleweight);
%PERC_WT(DAYS,GR18_2,  ,sampleweight);
%PERC_WT(DAYS,RALCOHOL2, ,sampleweight );
%PERC_WT(DAYS,RCARB2,  ,sampleweight);
%PERC_WT(DAYS,RENERGY2, ,sampleweight );
%PERC_WT(DAYS,RPROTEIN2, ,sampleweight );
%PERC_WT(DAYS,RTOTFAT2,  ,sampleweight);

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\foodgroupsDistribution.rtf';
title 'Food groups distribution';
proc print data=DBO;run;
title 'Food groups distribution - weighted results';
proc print data=DBO_WT;run;
ods rtf close;

/*%PERC(DAYS,M_GR01,  ); %PERC(DAYS,M_GR02,  ); %PERC(DAYS,M_GR03,  ); %PERC(DAYS,M_GR04,  ); %PERC(DAYS,M_GR05,  ); %PERC(DAYS,M_GR06,  ); %PERC(DAYS,M_GR07,  ); %PERC(DAYS,M_GR08,  );
%PERC(DAYS,M_GR09,  ); %PERC(DAYS,M_GR10,  ); %PERC(DAYS,M_GR11,  ); %PERC(DAYS,M_GR12,  ); %PERC(DAYS,M_GR13,  ); %PERC(DAYS,M_GR14,  ); %PERC(DAYS,M_GR15,  ); %PERC(DAYS,M_GR16,  );
%PERC(DAYS,M_GR17,  ); %PERC(DAYS,M_GR18,  ); %PERC(DAYS,MALC,  ); %PERC(DAYS,MCARB,  ); %PERC(DAYS,MENER,); %PERC(DAYS,MPROT,); %PERC(DAYS,MFAT,);

%PERC(DAYS,M_GR01, SEX1  ); %PERC(DAYS,M_GR02, SEX1  ); %PERC(DAYS,M_GR03, SEX1  ); %PERC(DAYS,M_GR04, SEX1  ); %PERC(DAYS,M_GR05, SEX1  ); %PERC(DAYS,M_GR06, SEX1  ); 
%PERC(DAYS,M_GR07, SEX1  ); %PERC(DAYS,M_GR08, SEX1  ); %PERC(DAYS,M_GR09, SEX1  ); %PERC(DAYS,M_GR10, SEX1  ); %PERC(DAYS,M_GR11, SEX1  ); %PERC(DAYS,M_GR12, SEX1  );
%PERC(DAYS,M_GR13, SEX1  ); %PERC(DAYS,M_GR14, SEX1  ); %PERC(DAYS,M_GR15, SEX1  ); %PERC(DAYS,M_GR16, SEX1  ); %PERC(DAYS,M_GR17, SEX1  ); %PERC(DAYS,M_GR18, SEX1  );
%PERC(DAYS,MALC, SEX1 ); %PERC(DAYS,MCARB, SEX1 ); %PERC(DAYS,MENER,SEX1); %PERC(DAYS,MPROT,SEX1); %PERC(DAYS,MFAT,SEX1); 

%PERC(DAYS,M_GR01, AGECAT1  ); %PERC(DAYS,M_GR02, AGECAT1 ); %PERC(DAYS,M_GR03, AGECAT1 ); %PERC(DAYS,M_GR04, AGECAT1 ); %PERC(DAYS,M_GR05, AGECAT1 ); %PERC(DAYS,M_GR06, AGECAT1 );
%PERC(DAYS,M_GR07, AGECAT1 ); %PERC(DAYS,M_GR08, AGECAT1 ); %PERC(DAYS,M_GR09, AGECAT1 ); %PERC(DAYS,M_GR10, AGECAT1 ); %PERC(DAYS,M_GR11, AGECAT1 ); %PERC(DAYS,M_GR12, AGECAT1 );
%PERC(DAYS,M_GR13, AGECAT1 ); %PERC(DAYS,M_GR14, AGECAT1 ); %PERC(DAYS,M_GR15, AGECAT1 ); %PERC(DAYS,M_GR16, AGECAT1 ); %PERC(DAYS,M_GR17, AGECAT1 ); %PERC(DAYS,M_GR18, AGECAT1 );
%PERC(DAYS,MALC, AGECAT1 ); %PERC(DAYS,MCARB, AGECAT1 ); %PERC(DAYS,MENER,AGECAT1); %PERC(DAYS,MPROT,AGECAT1); %PERC(DAYS,MFAT,AGECAT1);
*/


/*calcul ARITHMETIC mean of the means*/
 ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ArithmeticFoodgroupsMeans.rtf';
*unweighted;
DATA DBO ; SET _NULL_; RUN ;
%PERC(DAYS,M_GR01, SEX1  AGECL);
%PERC(DAYS,M_GR02, SEX1  AGECL);
%PERC(DAYS,M_GR03, SEX1  AGECL);
%PERC(DAYS,M_GR04, SEX1  AGECL);
%PERC(DAYS,M_GR05, SEX1  AGECL);
%PERC(DAYS,M_GR06, SEX1  AGECL);
%PERC(DAYS,M_GR07, SEX1  AGECL);
%PERC(DAYS,M_GR08, SEX1  AGECL);
%PERC(DAYS,M_GR09, SEX1  AGECL);
%PERC(DAYS,M_GR10, SEX1  AGECL);
%PERC(DAYS,M_GR11, SEX1  AGECL);
%PERC(DAYS,M_GR12, SEX1  AGECL);
%PERC(DAYS,M_GR13, SEX1  AGECL);
%PERC(DAYS,M_GR14, SEX1  AGECL);
%PERC(DAYS,M_GR15, SEX1  AGECL);
%PERC(DAYS,M_GR16, SEX1  AGECL);
%PERC(DAYS,M_GR17, SEX1  AGECL);
%PERC(DAYS,M_GR18, SEX1  AGECL);
%PERC(DAYS,MALC, SEX1 AGECL);
%PERC(DAYS,MCARB, SEX1 AGECL );
%PERC(DAYS,MENER,SEX1 AGECL);
%PERC(DAYS,MPROT,SEX1 AGECL);
%PERC(DAYS,MFAT,SEX1 AGECL);

DATA TableNC ; SET _NULL_; RUN ;
%CALNC(DAYS,M_GR01, SEX1 AGECL);
%CALNC(DAYS,M_GR02, SEX1 AGECL);
%CALNC(DAYS,M_GR03, SEX1 AGECL);
%CALNC(DAYS,M_GR04, SEX1 AGECL);
%CALNC(DAYS,M_GR05, SEX1 AGECL);
%CALNC(DAYS,M_GR06, SEX1 AGECL);
%CALNC(DAYS,M_GR07, SEX1 AGECL);
%CALNC(DAYS,M_GR08, SEX1 AGECL);
%CALNC(DAYS,M_GR09, SEX1 AGECL);
%CALNC(DAYS,M_GR10, SEX1 AGECL);
%CALNC(DAYS,M_GR11, SEX1 AGECL);
%CALNC(DAYS,M_GR12, SEX1 AGECL);
%CALNC(DAYS,M_GR13, SEX1 AGECL);
%CALNC(DAYS,M_GR14, SEX1 AGECL);
%CALNC(DAYS,M_GR15, SEX1 AGECL);
%CALNC(DAYS,M_GR16, SEX1 AGECL);
%CALNC(DAYS,M_GR17, SEX1 AGECL);
%CALNC(DAYS,M_GR18, SEX1 AGECL);
%CALNC(DAYS,MALC, SEX1 AGECL);
%CALNC(DAYS,MCARB, SEX1 AGECL);
%CALNC(DAYS,MENER,SEX1 AGECL);
%CALNC(DAYS,MPROT,SEX1 AGECL);
%CALNC(DAYS,MFAT,SEX1 AGECL);

PROC SORT DATA=DBO; BY LVAR _TYPE_;RUN;
PROC SORT DATA=Tablenc; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO TABLENC;BY LVAR _TYPE_;RUN;
title 'Food groups means';
PROC PRINT DATA=ARITHM;RUN;

*weighted;
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(DAYS,M_GR01, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR02, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR03, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR04, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR05, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR06, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR07, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR08, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR09, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR10, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR11, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR12, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR13, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR14, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR15, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR16, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR17, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,M_GR18, SEX1  AGECL,sampleweight);
%PERC_WT(DAYS,MALC, SEX1 AGECL,sampleweight);
%PERC_WT(DAYS,MCARB, SEX1 AGECL ,sampleweight);
%PERC_WT(DAYS,MENER,SEX1 AGECL ,sampleweight);
%PERC_WT(DAYS,MPROT,SEX1 AGECL ,sampleweight);
%PERC_WT(DAYS,MFAT,SEX1 AGECL ,sampleweight);

DATA TableNC ; SET _NULL_; RUN ;
%CALNC(DAYS,M_GR01, SEX1 AGECL);
%CALNC(DAYS,M_GR02, SEX1 AGECL);
%CALNC(DAYS,M_GR03, SEX1 AGECL);
%CALNC(DAYS,M_GR04, SEX1 AGECL);
%CALNC(DAYS,M_GR05, SEX1 AGECL);
%CALNC(DAYS,M_GR06, SEX1 AGECL);
%CALNC(DAYS,M_GR07, SEX1 AGECL);
%CALNC(DAYS,M_GR08, SEX1 AGECL);
%CALNC(DAYS,M_GR09, SEX1 AGECL);
%CALNC(DAYS,M_GR10, SEX1 AGECL);
%CALNC(DAYS,M_GR11, SEX1 AGECL);
%CALNC(DAYS,M_GR12, SEX1 AGECL);
%CALNC(DAYS,M_GR13, SEX1 AGECL);
%CALNC(DAYS,M_GR14, SEX1 AGECL);
%CALNC(DAYS,M_GR15, SEX1 AGECL);
%CALNC(DAYS,M_GR16, SEX1 AGECL);
%CALNC(DAYS,M_GR17, SEX1 AGECL);
%CALNC(DAYS,M_GR18, SEX1 AGECL);
%CALNC(DAYS,MALC, SEX1 AGECL);
%CALNC(DAYS,MCARB, SEX1 AGECL);
%CALNC(DAYS,MENER,SEX1 AGECL);
%CALNC(DAYS,MPROT,SEX1 AGECL);
%CALNC(DAYS,MFAT,SEX1 AGECL);

PROC SORT DATA=DBO_WT; BY LVAR _TYPE_;RUN;
PROC SORT DATA=Tablenc; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO_WT TABLENC;BY LVAR _TYPE_;RUN;
title 'Food groups means - weighted';
PROC PRINT DATA=ARITHM;RUN;
ods rtf close;

/*calcul GEOMETRIC mean of the means*/
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\GeometricFoodgroupsMeans.rtf';
DATA DBO ; SET _NULL_; RUN ;
/*%PERC(DAYS,LOGM_GR01,  ); %PERC(DAYS,LOGM_GR02,  ); %PERC(DAYS,LOGM_GR03,  ); %PERC(DAYS,LOGM_GR04,  ); %PERC(DAYS,LOGM_GR05,  ); %PERC(DAYS,LOGM_GR06,  ); %PERC(DAYS,LOGM_GR07,  );
%PERC(DAYS,LOGM_GR08,  ); %PERC(DAYS,LOGM_GR09,  ); %PERC(DAYS,LOGM_GR10,  ); %PERC(DAYS,LOGM_GR11,  ); %PERC(DAYS,LOGM_GR12,  ); %PERC(DAYS,LOGM_GR13,  ); %PERC(DAYS,LOGM_GR14,  );
%PERC(DAYS,LOGM_GR15,  ); %PERC(DAYS,LOGM_GR16,  ); %PERC(DAYS,LOGM_GR17,  );,  %PERC(DAYS,LOGM_GR18,  ); %PERC(DAYS,LOGMALC,  ); %PERC(DAYS,LOGMCARB,  ); %PERC(DAYS,LOGMENER,  );
%PERC(DAYS,LOGMPROT,  ); %PERC(DAYS,LOGMFAT,  );

%PERC(DAYS,LOGM_GR01, SEX1 ); %PERC(DAYS,LOGM_GR02, SEX1 ); %PERC(DAYS,LOGM_GR03, SEX1 ); %PERC(DAYS,LOGM_GR04, SEX1 ); %PERC(DAYS,LOGM_GR05, SEX1 ); %PERC(DAYS,LOGM_GR06, SEX1 );
%PERC(DAYS,LOGM_GR07, SEX1 ); %PERC(DAYS,LOGM_GR08, SEX1 ); %PERC(DAYS,LOGM_GR09, SEX1 ); %PERC(DAYS,LOGM_GR10, SEX1 ); %PERC(DAYS,LOGM_GR11, SEX1 ); %PERC(DAYS,LOGM_GR12, SEX1 );
%PERC(DAYS,LOGM_GR13, SEX1 ); %PERC(DAYS,LOGM_GR14, SEX1 ); %PERC(DAYS,LOGM_GR15, SEX1 ); %PERC(DAYS,LOGM_GR16, SEX1 ); %PERC(DAYS,LOGM_GR17, SEX1 ); %PERC(DAYS,LOGM_GR18, SEX1 );
%PERC(DAYS,LOGMALC, SEX1 ); %PERC(DAYS,LOGMCARB,SEX1  ); %PERC(DAYS,LOGMENER,SEX1  ); %PERC(DAYS,LOGMPROT,SEX1  ); %PERC(DAYS,LOGMFAT, SEX1 );
 
%PERC(DAYS,LOGM_GR01, AGECAT1 ); %PERC(DAYS,LOGM_GR02, AGECAT1 ); %PERC(DAYS,LOGM_GR03, AGECAT1 ); %PERC(DAYS,LOGM_GR04, AGECAT1 ); %PERC(DAYS,LOGM_GR05, AGECAT1 );
%PERC(DAYS,LOGM_GR06, AGECAT1 ); %PERC(DAYS,LOGM_GR07, AGECAT1 ); %PERC(DAYS,LOGM_GR08, AGECAT1 ); %PERC(DAYS,LOGM_GR09, AGECAT1 ); %PERC(DAYS,LOGM_GR10, AGECAT1 );
%PERC(DAYS,LOGM_GR11, AGECAT1 ); %PERC(DAYS,LOGM_GR12, AGECAT1 ); %PERC(DAYS,LOGM_GR13, AGECAT1 ); %PERC(DAYS,LOGM_GR14, AGECAT1 ); %PERC(DAYS,LOGM_GR15, AGECAT1 );
%PERC(DAYS,LOGM_GR16, AGECAT1 ); %PERC(DAYS,LOGM_GR17, AGECAT1 ); %PERC(DAYS,LOGM_GR18, AGECAT1 ); %PERC(DAYS,LOGMALC, AGECAT1 ); %PERC(DAYS,LOGMCARB,AGECAT1  );
%PERC(DAYS,LOGMENER,AGECAT1  ); %PERC(DAYS,LOGMPROT,AGECAT1  ); %PERC(DAYS,LOGMFAT, AGECAT1 );*/

%PERC(DAYS,LOGM_GR01, SEX1 AGECL );
%PERC(DAYS,LOGM_GR02, SEX1 AGECL );
%PERC(DAYS,LOGM_GR03, SEX1 AGECL );
%PERC(DAYS,LOGM_GR04, SEX1 AGECL );
%PERC(DAYS,LOGM_GR05, SEX1 AGECL );
%PERC(DAYS,LOGM_GR06, SEX1 AGECL );
%PERC(DAYS,LOGM_GR07, SEX1 AGECL );
%PERC(DAYS,LOGM_GR08, SEX1 AGECL );
%PERC(DAYS,LOGM_GR09, SEX1 AGECL );
%PERC(DAYS,LOGM_GR10, SEX1 AGECL );
%PERC(DAYS,LOGM_GR11, SEX1 AGECL );
%PERC(DAYS,LOGM_GR12, SEX1 AGECL );
%PERC(DAYS,LOGM_GR13, SEX1 AGECL );
%PERC(DAYS,LOGM_GR14, SEX1 AGECL );
%PERC(DAYS,LOGM_GR15, SEX1 AGECL );
%PERC(DAYS,LOGM_GR16, SEX1 AGECL );
%PERC(DAYS,LOGM_GR17, SEX1 AGECL );
%PERC(DAYS,LOGM_GR18, SEX1 AGECL );
%PERC(DAYS,LOGMALC, SEX1 AGECL );
%PERC(DAYS,LOGMCARB,SEX1 AGECL  );
%PERC(DAYS,LOGMENER,SEX1 AGECL  );
%PERC(DAYS,LOGMPROT,SEX1 AGECL  );
%PERC(DAYS,LOGMFAT, SEX1 AGECL );

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO; 
GEOMIN=EXP(MIN)-1;
GEOMP1=EXP(P1)-1;
GEOMP5=EXP(P5)-1;
GEOMP10=EXP(P10)-1;
GEOMP25=EXP(P25)-1;
GEOMEAN=EXP(MEAN)-1;
GEOMSTD=EXP(STD)-1;
GEOMP50=EXP(P50)-1;
GEOMP75=EXP(P75)-1;
GEOMP90=EXP(P90)-1;
GEOMP95=EXP(P95)-1;
GEOMP99=EXP(P99)-1;
GEOMAX=EXP(MAX)-1;
RUN;
title 'Food groups geometric means';
PROC PRINT DATA=GEOM;RUN;


DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(DAYS,LOGM_GR01, SEX1 AGECL ,sampleweight );
%PERC_WT(DAYS,LOGM_GR02, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR03, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR04, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR05, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR06, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR07, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR08, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR09, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR10, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR11, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR12, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR13, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR14, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR15, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR16, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR17, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGM_GR18, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGMALC, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,LOGMCARB,SEX1 AGECL  ,sampleweight );
%PERC_WT(DAYS,LOGMENER,SEX1 AGECL  ,sampleweight );
%PERC_WT(DAYS,LOGMPROT,SEX1 AGECL  ,sampleweight );
%PERC_WT(DAYS,LOGMFAT, SEX1 AGECL  ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
GEOMIN=EXP(MIN)-1;
GEOMP1=EXP(P1)-1;
GEOMP5=EXP(P5)-1;
GEOMP10=EXP(P10)-1;
GEOMP25=EXP(P25)-1;
GEOMEAN=EXP(MEAN)-1;
GEOMSTD=EXP(STD)-1;
GEOMP50=EXP(P50)-1;
GEOMP75=EXP(P75)-1;
GEOMP90=EXP(P90)-1;
GEOMP95=EXP(P95)-1;
GEOMP99=EXP(P99)-1;
GEOMAX=EXP(MAX)-1;
RUN;
title 'Food groups geometric means - weighted';
PROC PRINT DATA=GEOM;RUN;

ods rtf close;







/*-------------------------------------------------------------------------------------------------------*/
/*CALCULATION OF ARITHM AND GEOMEAN AMONG CONSUMERS ONLY*/

*weighted;
DATA DBO_WT ; SET _NULL_; RUN ;
DATA D; SET DAYS; IF M_GR01 ne 0; RUN; %PERC_WT(D,M_GR01, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR02 ne 0; RUN; %PERC_WT(D,M_GR02, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR03 ne 0; RUN; %PERC_WT(D,M_GR03, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR04 ne 0; RUN; %PERC_WT(D,M_GR04, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR05 ne 0; RUN; %PERC_WT(D,M_GR05, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR06 ne 0; RUN; %PERC_WT(D,M_GR06, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR07 ne 0; RUN; %PERC_WT(D,M_GR07, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR08 ne 0; RUN; %PERC_WT(D,M_GR08, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR09 ne 0; RUN; %PERC_WT(D,M_GR09, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR10 ne 0; RUN; %PERC_WT(D,M_GR10, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR11 ne 0; RUN; %PERC_WT(D,M_GR11, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR12 ne 0; RUN; %PERC_WT(D,M_GR12, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR13 ne 0; RUN; %PERC_WT(D,M_GR13, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR14 ne 0; RUN; %PERC_WT(D,M_GR14, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR15 ne 0; RUN; %PERC_WT(D,M_GR15, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR16 ne 0; RUN; %PERC_WT(D,M_GR16, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR17 ne 0; RUN; %PERC_WT(D,M_GR17, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF M_GR18 ne 0; RUN; %PERC_WT(D,M_GR18, SEX1  AGECL,sampleweight);
DATA D; SET DAYS; IF MALC ne 0; RUN;   %PERC_WT(D,MALC, SEX1 AGECL,sampleweight);
DATA D; SET DAYS; IF MCARB ne 0; RUN;  %PERC_WT(D,MCARB, SEX1 AGECL ,sampleweight);
DATA D; SET DAYS; IF MENER ne 0; RUN;  %PERC_WT(D,MENER,SEX1 AGECL ,sampleweight);
DATA D; SET DAYS; IF MPROT ne 0; RUN;  %PERC_WT(D,MPROT,SEX1 AGECL ,sampleweight);
DATA D; SET DAYS; IF MFAT ne 0; RUN;   %PERC_WT(D,MFAT,SEX1 AGECL ,sampleweight);

 ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ArithmeticFGmeans_amongConsumersWeighted.rtf';
PROC PRINT DATA=DBO_WT;RUN;
ods rtf close;

DATA DBO_WT ; SET _NULL_; RUN ;
DATA D; SET DAYS; IF M_GR01 ne 0; RUN; %PERC_WT(D,LOGM_GR01, SEX1 AGECL ,sampleweight );
DATA D; SET DAYS; IF M_GR02 ne 0; RUN; %PERC_WT(D,LOGM_GR02, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR03 ne 0; RUN; %PERC_WT(D,LOGM_GR03, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR04 ne 0; RUN; %PERC_WT(D,LOGM_GR04, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR05 ne 0; RUN; %PERC_WT(D,LOGM_GR05, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR06 ne 0; RUN; %PERC_WT(D,LOGM_GR06, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR07 ne 0; RUN; %PERC_WT(D,LOGM_GR07, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR08 ne 0; RUN; %PERC_WT(D,LOGM_GR08, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR09 ne 0; RUN; %PERC_WT(D,LOGM_GR09, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR10 ne 0; RUN; %PERC_WT(D,LOGM_GR10, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR11 ne 0; RUN; %PERC_WT(D,LOGM_GR11, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR12 ne 0; RUN; %PERC_WT(D,LOGM_GR12, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR13 ne 0; RUN; %PERC_WT(D,LOGM_GR13, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR14 ne 0; RUN; %PERC_WT(D,LOGM_GR14, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR15 ne 0; RUN; %PERC_WT(D,LOGM_GR15, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR16 ne 0; RUN; %PERC_WT(D,LOGM_GR16, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR17 ne 0; RUN; %PERC_WT(D,LOGM_GR17, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_GR18 ne 0; RUN; %PERC_WT(D,LOGM_GR18, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF MALC ne 0; RUN;   %PERC_WT(D,LOGMALC, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF MCARB ne 0; RUN;  %PERC_WT(D,LOGMCARB,SEX1 AGECL  ,sampleweight );
DATA D; SET DAYS; IF MENER ne 0; RUN;  %PERC_WT(D,LOGMENER,SEX1 AGECL  ,sampleweight );
DATA D; SET DAYS; IF MPROT ne 0; RUN;  %PERC_WT(D,LOGMPROT,SEX1 AGECL  ,sampleweight );
DATA D; SET DAYS; IF MFAT ne 0; RUN;   %PERC_WT(D,LOGMFAT, SEX1 AGECL  ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
GEOMIN=EXP(MIN)-1;
GEOMP1=EXP(P1)-1;
GEOMP5=EXP(P5)-1;
GEOMP10=EXP(P10)-1;
GEOMP25=EXP(P25)-1;
GEOMEAN=EXP(MEAN)-1;
GEOMSTD=EXP(STD)-1;
GEOMP50=EXP(P50)-1;
GEOMP75=EXP(P75)-1;
GEOMP90=EXP(P90)-1;
GEOMP95=EXP(P95)-1;
GEOMP99=EXP(P99)-1;
GEOMAX=EXP(MAX)-1;
RUN;

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\GeometricFGmeans_amongConsumersWeighted.rtf';
PROC PRINT DATA=GEOM;RUN;
ods rtf close;




/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*CALCULATION OF ICC*/
/*MACRO CALICC : 
use FILE with duplicate measurements and performs ICC calculation (2 lines per subjects)
id = name of the ID variable
logvar = name of the parameter measured in duplicate (var in log)*/
%macro CALICC(db,var,adj,id, wht, byvar) ;
proc mixed data=&db asycov;
class id_num ;
model &var= &adj;
random /*int/subject=*/id_num;
by &byvar;
ods output covparms=est asycov=vc;
weight &wht;
run;
data est; set est; var="&var"; 
data vc; set vc; var="&var";run;

proc sort data=est; by &byvar var; run;
PROC TRANSPOSE DATA=est OUT=e;
VAR estimate;
ID covparm;
BY &byvar;
RUN;

data e;set e;corintra=(ID_NUM/(ID_NUM+residual)); var="&var"; run;
ods select all;
title "Intra-class correlation - &var.";
proc print data=e noobs;var &byvar var corintra;  run;

data exp;set e;keep &byvar var corintra label;format label $50.;label="Intra-class correlation - &var.";run;
PROC SORT DATA=exp ; BY &byvar VAR ; RUN ;
DATA TableICC ; SET TableICC exp ; RUN ;

* You have to run the following two lines to start the procedure all over again.;
*DO NOT FORGET TO PROC DELETE;
/*proc delete data=e; run;
proc delete data=est; run;
proc delete data=vc; run;*/
%mend CALICC;

data ALL; set ALL;wt=1; RUN;*simul weight option;
PROC SORT DATA=ALL; by sex;RUN;

*essai;
/*DATA TableICC ; SET _NULL_; RUN ;
PROC SORT DATA=ALL; by sex;RUN;
ods rtf file='D:\Aurelie\EU-consortium\MaltaSurvey\ICC_Est.rtf';
%CALICC(ALL,LOGGR01, ,id_num, sampleweight, sex) ; proc print data=E;run; %CALICC(ALL,LOGGR01, ,id_num, wt , sex) ; proc print data=E;run;
%CALICC(ALL,LOGGR02, ,id_num, sampleweight, sex) ; proc print data=E;run; %CALICC(ALL,LOGGR02, ,id_num, wt , sex) ; proc print data=E;run;
ods rtf close;*/
/*
DATA TableICC ; SET _NULL_; RUN ;
PROC SORT DATA=ALL; by sex;RUN;

%CALICC(ALL,LOGGR01, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR02, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR03, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR04, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR05, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR06, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR07, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR08, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR09, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR10, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR11, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR12, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR13, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR14, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR15, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR16, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR17, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGGR18, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGALC, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGCARB, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGENER, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGPROT, ,id_num, sampleweight, sex) ; 
%CALICC(ALL,LOGFAT, ,id_num, sampleweight, sex) ; 
ods rtf file='D:\Aurelie\EU-consortium\MaltaSurvey\ICC1.rtf';
proc print data=TableICC;run;
ods rtf close;

DATA TableICC ; SET _NULL_; RUN ;
PROC SORT DATA=ALL; by sex AGECAT;RUN;
%CALICC(ALL,LOGGR01, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR02, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR03, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR04, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR05, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR06, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR07, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR08, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR09, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR10, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR11, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR12, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR13, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR14, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR15, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR16, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR17, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGGR18, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGALC, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGCARB, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGENER, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGPROT, ,id_num, sampleweight, sex AGECAT) ; 
%CALICC(ALL,LOGFAT, ,id_num, sampleweight, sex AGECAT) ; 
ods rtf file='D:\Aurelie\EU-consortium\MaltaSurvey\ICC2.rtf';
proc print data=TableICC;run;
ods rtf close;*/

data ALL; set ALL;wt=1; RUN;*simul weight option;
PROC SORT DATA=ALL; by sex;RUN;
DATA TableICC ; SET _NULL_; RUN ;
%CALICC(ALL,LOGGR01, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR02, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR03, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR04, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR05, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR06, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR07, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR08, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR09, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR10, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR11, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR12, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR13, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR14, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR15, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR16, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR17, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGGR18, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGALC, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGCARB, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGENER, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGPROT, ,id_num, wt, sex) ; 
%CALICC(ALL,LOGFAT, ,id_num, wt, sex) ; 

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ICCwithoutWeights1.rtf';
proc print data=TableICC;run;
ods rtf close;
PROC SORT DATA=ALL; by sex AGECL;RUN;
DATA TableICC ; SET _NULL_; RUN ;
%CALICC(ALL,LOGGR01, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR02, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR03, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR04, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR05, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR06, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR07, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR08, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR09, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR10, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR11, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR12, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR13, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR14, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR15, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR16, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR17, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGGR18, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGALC, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGCARB, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGENER, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGPROT, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,LOGFAT, ,id_num, wt, sex AGECL) ; 


ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ICCwithoutWeights2.rtf';
proc print data=TableICC;run;
ods rtf close;



/*ICC AMONG CONSUMERS ONLY*/

Data D (KEEP=id_num M_GR01 M_GR02 M_GR03 M_GR04 M_GR05 M_GR06 M_GR07 M_GR08 M_GR09 M_GR10 M_GR11 M_GR12 M_GR13 M_GR14 M_GR15 M_GR16 M_GR17 M_GR18 MALC MCARB MENER  MPROT MFAT);
SET DAYS;run;
PROC SORT DATA=D; bY ID_NUM;RUN;
PROC SORT DATA=ALL; BY ID_NUM;RUN;
DATA A; MERGE ALL (IN=A) D (IN=B); BY ID_NUM; if a; RUN;


PROC SORT DATA=A; by sex;RUN;
DATA TableICC ; SET _NULL_; RUN ;
DATA B; SET A; IF M_GR01 ne 0; RUN; %CALICC(B,LOGGR01, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR02 ne 0; RUN; %CALICC(B,LOGGR02, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR03 ne 0; RUN; %CALICC(B,LOGGR03, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR04 ne 0; RUN; %CALICC(B,LOGGR04, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR05 ne 0; RUN; %CALICC(B,LOGGR05, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR06 ne 0; RUN; %CALICC(B,LOGGR06, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR07 ne 0; RUN; %CALICC(B,LOGGR07, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR08 ne 0; RUN; %CALICC(B,LOGGR08, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR09 ne 0; RUN; %CALICC(B,LOGGR09, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR10 ne 0; RUN; %CALICC(B,LOGGR10, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR11 ne 0; RUN; %CALICC(B,LOGGR11, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR12 ne 0; RUN; %CALICC(B,LOGGR12, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR13 ne 0; RUN; %CALICC(B,LOGGR13, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR14 ne 0; RUN; %CALICC(B,LOGGR14, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR15 ne 0; RUN; %CALICC(B,LOGGR15, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR16 ne 0; RUN; %CALICC(B,LOGGR16, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR17 ne 0; RUN; %CALICC(B,LOGGR17, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_GR18 ne 0; RUN; %CALICC(B,LOGGR18, ,id_num, wt, sex) ; 
DATA B; SET A; IF MALC ne 0; RUN;   %CALICC(B,LOGALC, ,id_num, wt, sex) ; 
DATA B; SET A; IF MCARB ne 0; RUN;  %CALICC(B,LOGCARB, ,id_num, wt, sex) ; 
DATA B; SET A; IF MENER ne 0; RUN;  %CALICC(B,LOGENER, ,id_num, wt, sex) ; 
DATA B; SET A; IF MPROT ne 0; RUN;  %CALICC(B,LOGPROT, ,id_num, wt, sex) ; 
DATA B; SET A; IF MFAT ne 0; RUN;   %CALICC(B,LOGFAT, ,id_num, wt, sex) ; 

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ICCwithoutWeights1_amongconsumers.rtf';
proc print data=TableICC;run;
ods rtf close;
PROC SORT DATA=A; by sex AGECL;RUN;
DATA TableICC ; SET _NULL_; RUN ;
DATA B; SET A; IF M_GR01 ne 0; RUN; %CALICC(B,LOGGR01, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR02 ne 0; RUN; %CALICC(B,LOGGR02, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR03 ne 0; RUN; %CALICC(B,LOGGR03, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR04 ne 0; RUN; %CALICC(B,LOGGR04, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR05 ne 0; RUN; %CALICC(B,LOGGR05, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR06 ne 0; RUN; %CALICC(B,LOGGR06, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR07 ne 0; RUN; %CALICC(B,LOGGR07, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR08 ne 0; RUN; %CALICC(B,LOGGR08, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR09 ne 0; RUN; %CALICC(B,LOGGR09, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR10 ne 0; RUN; %CALICC(B,LOGGR10, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR11 ne 0; RUN; %CALICC(B,LOGGR11, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR12 ne 0; RUN; %CALICC(B,LOGGR12, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR13 ne 0; RUN; %CALICC(B,LOGGR13, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR14 ne 0; RUN; %CALICC(B,LOGGR14, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR15 ne 0; RUN; %CALICC(B,LOGGR15, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR16 ne 0; RUN; %CALICC(B, LOGGR16, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR17 ne 0; RUN; %CALICC(B,LOGGR17, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_GR18 ne 0; RUN; %CALICC(B,LOGGR18, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF MALC ne 0; RUN;   %CALICC(B,LOGALC, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF MCARB ne 0; RUN;  %CALICC(B,LOGCARB, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF MENER ne 0; RUN;  %CALICC(B,LOGENER, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF MPROT ne 0; RUN;  %CALICC(B,LOGPROT, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF MFAT ne 0; RUN;   %CALICC(B,LOGFAT, ,id_num, wt, sex AGECL) ; 


ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ICCwithoutWeights2_amongconsumers.rtf';
proc print data=TableICC;run;
ods rtf close;





/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*BREAKING THE MATCHING TO SEE EFFECT OF SEASON & DAY*/
/*WORK ON INTERVIEW DATA*/
/*Seasons2 
    1 = "Spring/Summer"
    2 = "Automn/Winter" ;
Seasons4
    1 = "Spring"
    2 = "Summer"
    3 = "Automn"
    4 = "Winter" ;
DayCL
    1 = "Monday -> Thursday"
    2 = "Friday -> Sunday" ;*/

/*check the distribution of interviews by season and day*/
proc freq data=ALL; Tables SEX*(DAY_CL SEASONS4);RUN;

/*UNWEIGHTED*/
*Arithmetic mean;
 /*DATA DBO ; SET _NULL_; RUN ;
%PERC(ALL,GR01, SEX  DAY_CL);
%PERC(ALL,GR02, SEX  DAY_CL);
%PERC(ALL,GR03, SEX  DAY_CL);
%PERC(ALL,GR04, SEX  DAY_CL);
%PERC(ALL,GR05, SEX  DAY_CL);
%PERC(ALL,GR06, SEX  DAY_CL);
%PERC(ALL,GR07, SEX  DAY_CL);
%PERC(ALL,GR08, SEX  DAY_CL);
%PERC(ALL,GR09, SEX  DAY_CL);
%PERC(ALL,GR10, SEX  DAY_CL);
%PERC(ALL,GR11, SEX  DAY_CL);
%PERC(ALL,GR12, SEX  DAY_CL);
%PERC(ALL,GR13, SEX  DAY_CL);
%PERC(ALL,GR14, SEX  DAY_CL);
%PERC(ALL,GR15, SEX  DAY_CL);
%PERC(ALL,GR16, SEX  DAY_CL);
%PERC(ALL,GR17, SEX  DAY_CL);
%PERC(ALL,GR18, SEX  DAY_CL);
%PERC(ALL,RALCOHOL, SEX  DAY_CL);
%PERC(ALL,RCARB, SEX  DAY_CL);
%PERC(ALL,RENERGY, SEX  DAY_CL);
%PERC(ALL,RPROTEIN, SEX  DAY_CL);
%PERC(ALL,RTOTFAT, SEX  DAY_CL);

%PERC(ALL,GR01, SEX  SEASONS2);
%PERC(ALL,GR02, SEX  SEASONS2);
%PERC(ALL,GR03, SEX  SEASONS2);
%PERC(ALL,GR04, SEX  SEASONS2);
%PERC(ALL,GR05, SEX  SEASONS2);
%PERC(ALL,GR06, SEX  SEASONS2);
%PERC(ALL,GR07, SEX  SEASONS2);
%PERC(ALL,GR08, SEX  SEASONS2);
%PERC(ALL,GR09, SEX  SEASONS2);
%PERC(ALL,GR10, SEX  SEASONS2);
%PERC(ALL,GR11, SEX  SEASONS2);
%PERC(ALL,GR12, SEX  SEASONS2);
%PERC(ALL,GR13, SEX  SEASONS2);
%PERC(ALL,GR14, SEX  SEASONS2);
%PERC(ALL,GR15, SEX  SEASONS2);
%PERC(ALL,GR16, SEX  SEASONS2);
%PERC(ALL,GR17, SEX  SEASONS2);
%PERC(ALL,GR18, SEX  SEASONS2);
%PERC(ALL,RALCOHOL, SEX SEASONS2);
%PERC(ALL,RCARB, SEX SEASONS2);
%PERC(ALL,RENERGY, SEX SEASONS2);
%PERC(ALL,RPROTEIN, SEX SEASONS2);
%PERC(ALL,RTOTFAT, SEX SEASONS2);

%PERC(ALL,GR01, SEX  SEASONS4);
%PERC(ALL,GR02, SEX  SEASONS4);
%PERC(ALL,GR03, SEX  SEASONS4);
%PERC(ALL,GR04, SEX  SEASONS4);
%PERC(ALL,GR05, SEX  SEASONS4);
%PERC(ALL,GR06, SEX  SEASONS4);
%PERC(ALL,GR07, SEX  SEASONS4);
%PERC(ALL,GR08, SEX  SEASONS4);
%PERC(ALL,GR09, SEX  SEASONS4);
%PERC(ALL,GR10, SEX  SEASONS4);
%PERC(ALL,GR11, SEX  SEASONS4);
%PERC(ALL,GR12, SEX  SEASONS4);
%PERC(ALL,GR13, SEX  SEASONS4);
%PERC(ALL,GR14, SEX  SEASONS4);
%PERC(ALL,GR15, SEX  SEASONS4);
%PERC(ALL,GR16, SEX  SEASONS4);
%PERC(ALL,GR17, SEX  SEASONS4);
%PERC(ALL,GR18, SEX  SEASONS4);
%PERC(ALL,RALCOHOL, SEX SEASONS4);
%PERC(ALL,RCARB, SEX SEASONS4);
%PERC(ALL,RENERGY, SEX SEASONS4);
%PERC(ALL,RPROTEIN, SEX SEASONS4);
%PERC(ALL,RTOTFAT, SEX SEASONS4);

*calculation of NC;
DATA TableNC ; SET _NULL_; RUN ;
%CALNC(ALL,RALCOHOL, SEX  DAY_CL);
%CALNC(ALL,RCARB, SEX  DAY_CL);
%CALNC(ALL,RENERGY, SEX  DAY_CL);
%CALNC(ALL,RPROTEIN, SEX  DAY_CL);
%CALNC(ALL,RTOTFAT, SEX  DAY_CL);
%CALNC(ALL,GR01, SEX  DAY_CL);
%CALNC(ALL,GR02, SEX  DAY_CL);
%CALNC(ALL,GR03, SEX  DAY_CL);
%CALNC(ALL,GR04, SEX  DAY_CL);
%CALNC(ALL,GR05, SEX  DAY_CL);
%CALNC(ALL,GR06, SEX  DAY_CL);
%CALNC(ALL,GR07, SEX  DAY_CL);
%CALNC(ALL,GR08, SEX  DAY_CL);
%CALNC(ALL,GR09, SEX  DAY_CL);
%CALNC(ALL,GR10, SEX  DAY_CL);
%CALNC(ALL,GR11, SEX  DAY_CL);
%CALNC(ALL,GR12, SEX  DAY_CL);
%CALNC(ALL,GR13, SEX  DAY_CL);
%CALNC(ALL,GR14, SEX  DAY_CL);
%CALNC(ALL,GR15, SEX  DAY_CL);
%CALNC(ALL,GR16, SEX  DAY_CL);
%CALNC(ALL,GR17, SEX  DAY_CL);
%CALNC(ALL,GR18, SEX  DAY_CL);

%CALNC(ALL,RALCOHOL, SEX  SEASONS2);
%CALNC(ALL,RCARB, SEX  SEASONS2);
%CALNC(ALL,RENERGY, SEX  SEASONS2);
%CALNC(ALL,RPROTEIN, SEX  SEASONS2);
%CALNC(ALL,RTOTFAT, SEX  SEASONS2);
%CALNC(ALL,GR01, SEX  SEASONS2);
%CALNC(ALL,GR02, SEX  SEASONS2);
%CALNC(ALL,GR03, SEX  SEASONS2);
%CALNC(ALL,GR04, SEX  SEASONS2);
%CALNC(ALL,GR05, SEX  SEASONS2);
%CALNC(ALL,GR06, SEX  SEASONS2);
%CALNC(ALL,GR07, SEX  SEASONS2);
%CALNC(ALL,GR08, SEX  SEASONS2);
%CALNC(ALL,GR09, SEX  SEASONS2);
%CALNC(ALL,GR10, SEX  SEASONS2);
%CALNC(ALL,GR11, SEX  SEASONS2);
%CALNC(ALL,GR12, SEX  SEASONS2);
%CALNC(ALL,GR13, SEX  SEASONS2);
%CALNC(ALL,GR14, SEX  SEASONS2);
%CALNC(ALL,GR15, SEX  SEASONS2);
%CALNC(ALL,GR16, SEX  SEASONS2);
%CALNC(ALL,GR17, SEX  SEASONS2);
%CALNC(ALL,GR18, SEX  SEASONS2);

%CALNC(ALL,RALCOHOL, SEX  SEASONS4);
%CALNC(ALL,RCARB, SEX  SEASONS4);
%CALNC(ALL,RENERGY, SEX  SEASONS4);
%CALNC(ALL,RPROTEIN, SEX  SEASONS4);
%CALNC(ALL,RTOTFAT, SEX  SEASONS4);
%CALNC(ALL,GR01, SEX  SEASONS4);
%CALNC(ALL,GR02, SEX  SEASONS4);
%CALNC(ALL,GR03, SEX  SEASONS4);
%CALNC(ALL,GR04, SEX  SEASONS4);
%CALNC(ALL,GR05, SEX  SEASONS4);
%CALNC(ALL,GR06, SEX  SEASONS4);
%CALNC(ALL,GR07, SEX  SEASONS4);
%CALNC(ALL,GR08, SEX  SEASONS4);
%CALNC(ALL,GR09, SEX  SEASONS4);
%CALNC(ALL,GR10, SEX  SEASONS4);
%CALNC(ALL,GR11, SEX  SEASONS4);
%CALNC(ALL,GR12, SEX  SEASONS4);
%CALNC(ALL,GR13, SEX  SEASONS4);
%CALNC(ALL,GR14, SEX  SEASONS4);
%CALNC(ALL,GR15, SEX  SEASONS4);
%CALNC(ALL,GR16, SEX  SEASONS4);
%CALNC(ALL,GR17, SEX  SEASONS4);
%CALNC(ALL,GR18, SEX  SEASONS4);

PROC SORT DATA=DBO; BY LVAR _TYPE_;RUN;
PROC SORT DATA=TABLENC; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO TABLENC;BY LVAR _TYPE_;RUN;
ods rtf file='D:\Aurelie\EU-consortium\MaltaSurvey\ArithmMeanByseasonDays_Unweighted.rtf';
proc print data=ARITHM;run;
ods rtf close;

*geometric means;
DATA DBO ; SET _NULL_; RUN ;
%PERC(ALL,LOGGR01, SEX DAY_CL );
%PERC(ALL,LOGGR02, SEX DAY_CL );
%PERC(ALL,LOGGR03, SEX DAY_CL );
%PERC(ALL,LOGGR04, SEX DAY_CL );
%PERC(ALL,LOGGR05, SEX DAY_CL );
%PERC(ALL,LOGGR06, SEX DAY_CL );
%PERC(ALL,LOGGR07, SEX DAY_CL );
%PERC(ALL,LOGGR08, SEX DAY_CL );
%PERC(ALL,LOGGR09, SEX DAY_CL );
%PERC(ALL,LOGGR10, SEX DAY_CL );
%PERC(ALL,LOGGR11, SEX DAY_CL );
%PERC(ALL,LOGGR12, SEX DAY_CL );
%PERC(ALL,LOGGR13, SEX DAY_CL );
%PERC(ALL,LOGGR14, SEX DAY_CL );
%PERC(ALL,LOGGR15, SEX DAY_CL );
%PERC(ALL,LOGGR16, SEX DAY_CL );
%PERC(ALL,LOGGR17, SEX DAY_CL );
%PERC(ALL,LOGGR18, SEX DAY_CL );
%PERC(ALL,LOGALC, 	SEX DAY_CL);
%PERC(ALL,LOGCARB, 	SEX DAY_CL);
%PERC(ALL,LOGENER, 	SEX DAY_CL);
%PERC(ALL,LOGPROT, 	SEX DAY_CL);
%PERC(ALL,LOGFAT, 	SEX DAY_CL);

%PERC(ALL,LOGGR01, SEX SEASONS2 );
%PERC(ALL,LOGGR02, SEX SEASONS2 );
%PERC(ALL,LOGGR03, SEX SEASONS2 );
%PERC(ALL,LOGGR04, SEX SEASONS2 );
%PERC(ALL,LOGGR05, SEX SEASONS2 );
%PERC(ALL,LOGGR06, SEX SEASONS2 );
%PERC(ALL,LOGGR07, SEX SEASONS2 );
%PERC(ALL,LOGGR08, SEX SEASONS2 );
%PERC(ALL,LOGGR09, SEX SEASONS2 );
%PERC(ALL,LOGGR10, SEX SEASONS2 );
%PERC(ALL,LOGGR11, SEX SEASONS2 );
%PERC(ALL,LOGGR12, SEX SEASONS2 );
%PERC(ALL,LOGGR13, SEX SEASONS2 );
%PERC(ALL,LOGGR14, SEX SEASONS2 );
%PERC(ALL,LOGGR15, SEX SEASONS2 );
%PERC(ALL,LOGGR16, SEX SEASONS2 );
%PERC(ALL,LOGGR17, SEX SEASONS2 );
%PERC(ALL,LOGGR18, SEX SEASONS2 );
%PERC(ALL,LOGALC, 	SEX SEASONS2);
%PERC(ALL,LOGCARB, 	SEX SEASONS2);
%PERC(ALL,LOGENER, 	SEX SEASONS2);
%PERC(ALL,LOGPROT, 	SEX SEASONS2);
%PERC(ALL,LOGFAT, 	SEX SEASONS2);

%PERC(ALL,LOGGR01, SEX SEASONS4 );
%PERC(ALL,LOGGR02, SEX SEASONS4 );
%PERC(ALL,LOGGR03, SEX SEASONS4 );
%PERC(ALL,LOGGR04, SEX SEASONS4 );
%PERC(ALL,LOGGR05, SEX SEASONS4 );
%PERC(ALL,LOGGR06, SEX SEASONS4 );
%PERC(ALL,LOGGR07, SEX SEASONS4 );
%PERC(ALL,LOGGR08, SEX SEASONS4 );
%PERC(ALL,LOGGR09, SEX SEASONS4 );
%PERC(ALL,LOGGR10, SEX SEASONS4 );
%PERC(ALL,LOGGR11, SEX SEASONS4 );
%PERC(ALL,LOGGR12, SEX SEASONS4 );
%PERC(ALL,LOGGR13, SEX SEASONS4 );
%PERC(ALL,LOGGR14, SEX SEASONS4 );
%PERC(ALL,LOGGR15, SEX SEASONS4 );
%PERC(ALL,LOGGR16, SEX SEASONS4 );
%PERC(ALL,LOGGR17, SEX SEASONS4 );
%PERC(ALL,LOGGR18, SEX SEASONS4 );
%PERC(ALL,LOGALC, SEX SEASONS4);
%PERC(ALL,LOGCARB,SEX SEASONS4);
%PERC(ALL,LOGENER,SEX SEASONS4);
%PERC(ALL,LOGPROT,SEX SEASONS4);
%PERC(ALL,LOGFAT, SEX SEASONS4);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO; 
GEOMIN=EXP(MIN);
GEOMP1=EXP(P1);
GEOMP5=EXP(P5);
GEOMP10=EXP(P10);
GEOMP25=EXP(P25);
GEOMEAN=EXP(MEAN);
GEOMSTD=EXP(STD);
GEOMP50=EXP(P50);
GEOMP75=EXP(P75);
GEOMP90=EXP(P90);
GEOMP95=EXP(P95);
GEOMP99=EXP(P99);
GEOMAX=EXP(MAX);
RUN;

ods rtf file='D:\Aurelie\EU-consortium\MaltaSurvey\GeoMeanByseasonDays_Unweighted.rtf';
proc print data=GEOM;run;
ods rtf close;
*/










/*WEIGHTED MEANS*/
*ARITHMETIC MEANS ALL SUBJECTS;
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(ALL,GR01, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR02, SEX  DAY_CL,sampleweight );
%PERC_WT(ALL,GR03, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR04, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR05, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR06, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR07, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR08, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR09, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR10, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR11, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR12, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR13, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR14, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR15, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR16, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR17, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,GR18, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,RALCOHOL, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,RCARBOHYDRATE, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,RENERGY, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,RPROTEIN, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,RTOTFAT, SEX  DAY_CL,sampleweight);

%PERC_WT(ALL,GR01, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR02, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR03, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR04, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR05, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR06, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR07, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR08, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR09, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR10, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR11, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR12, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR13, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR14, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR15, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR16, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR17, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,GR18, SEX  SEASONS4,sampleweight);
%PERC_WT(ALL,RALCOHOL, SEX SEASONS4,sampleweight);
%PERC_WT(ALL,RCARBOHYDRATE, SEX SEASONS4,sampleweight);
%PERC_WT(ALL,RENERGY, SEX SEASONS4,sampleweight);
%PERC_WT(ALL,RPROTEIN, SEX SEASONS4,sampleweight);
%PERC_WT(ALL,RTOTFAT, SEX SEASONS4,sampleweight);

*calculation of NC;
DATA TableNC ; SET _NULL_; RUN ;
%CALNC(ALL,RALCOHOL, SEX  DAY_CL);
%CALNC(ALL,RCARBOHYDRATE, SEX  DAY_CL);
%CALNC(ALL,RENERGY, SEX  DAY_CL);
%CALNC(ALL,RPROTEIN, SEX  DAY_CL);
%CALNC(ALL,RTOTFAT, SEX  DAY_CL);
%CALNC(ALL,GR01, SEX  DAY_CL);
%CALNC(ALL,GR02, SEX  DAY_CL);
%CALNC(ALL,GR03, SEX  DAY_CL);
%CALNC(ALL,GR04, SEX  DAY_CL);
%CALNC(ALL,GR05, SEX  DAY_CL);
%CALNC(ALL,GR06, SEX  DAY_CL);
%CALNC(ALL,GR07, SEX  DAY_CL);
%CALNC(ALL,GR08, SEX  DAY_CL);
%CALNC(ALL,GR09, SEX  DAY_CL);
%CALNC(ALL,GR10, SEX  DAY_CL);
%CALNC(ALL,GR11, SEX  DAY_CL);
%CALNC(ALL,GR12, SEX  DAY_CL);
%CALNC(ALL,GR13, SEX  DAY_CL);
%CALNC(ALL,GR14, SEX  DAY_CL);
%CALNC(ALL,GR15, SEX  DAY_CL);
%CALNC(ALL,GR16, SEX  DAY_CL);
%CALNC(ALL,GR17, SEX  DAY_CL);
%CALNC(ALL,GR18, SEX  DAY_CL);

%CALNC(ALL,RALCOHOL, SEX  SEASONS4);
%CALNC(ALL,RCARBOHYDRATE, SEX  SEASONS4);
%CALNC(ALL,RENERGY, SEX  SEASONS4);
%CALNC(ALL,RPROTEIN, SEX  SEASONS4);
%CALNC(ALL,RTOTFAT, SEX  SEASONS4);
%CALNC(ALL,GR01, SEX  SEASONS4);
%CALNC(ALL,GR02, SEX  SEASONS4);
%CALNC(ALL,GR03, SEX  SEASONS4);
%CALNC(ALL,GR04, SEX  SEASONS4);
%CALNC(ALL,GR05, SEX  SEASONS4);
%CALNC(ALL,GR06, SEX  SEASONS4);
%CALNC(ALL,GR07, SEX  SEASONS4);
%CALNC(ALL,GR08, SEX  SEASONS4);
%CALNC(ALL,GR09, SEX  SEASONS4);
%CALNC(ALL,GR10, SEX  SEASONS4);
%CALNC(ALL,GR11, SEX  SEASONS4);
%CALNC(ALL,GR12, SEX  SEASONS4);
%CALNC(ALL,GR13, SEX  SEASONS4);
%CALNC(ALL,GR14, SEX  SEASONS4);
%CALNC(ALL,GR15, SEX  SEASONS4);
%CALNC(ALL,GR16, SEX  SEASONS4);
%CALNC(ALL,GR17, SEX  SEASONS4);
%CALNC(ALL,GR18, SEX  SEASONS4);

PROC SORT DATA=DBO_WT; BY LVAR _TYPE_;RUN;
PROC SORT DATA=TABLENC; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO_WT TABLENC;BY LVAR _TYPE_;RUN;
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ArithmMeanByseasonDays_weighted.rtf';
proc print data=ARITHM;run;
ods rtf close;


*geometric means weighted for sampling weights among consumers only;
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(ALL,LOGGR01, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR02, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR03, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR04, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR05, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR06, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR07, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR08, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR09, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR10, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR11, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR12, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR13, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR14, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR15, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR16, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR17, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGGR18, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGALC, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGCARB, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGENER, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGPROT, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,LOGFAT, SEX DAY_CL ,sampleweight);

%PERC_WT(ALL,LOGGR01, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR02, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR03, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR04, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR05, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR06, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR07, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR08, SEX SEASONS4 ,sampleweight); 
%PERC_WT(ALL,LOGGR09, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR10, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR11, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR12, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR13, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR14, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR15, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR16, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR17, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGGR18, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGALC, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGCARB,SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGENER,SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGPROT,SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,LOGFAT, SEX SEASONS4 ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
GEOMIN=EXP(MIN)-1;
GEOMP1=EXP(P1)-1;
GEOMP5=EXP(P5)-1;
GEOMP10=EXP(P10)-1;
GEOMP25=EXP(P25)-1;
GEOMEAN=EXP(MEAN)-1;
GEOMSTD=EXP(STD)-1;
GEOMP50=EXP(P50)-1;
GEOMP75=EXP(P75)-1;
GEOMP90=EXP(P90)-1;
GEOMP95=EXP(P95)-1;
GEOMP99=EXP(P99)-1;
GEOMAX=EXP(MAX)-1;
RUN;
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\GeoMeanByseasonDays_weighted.rtf';
proc print data=GEOM;var  _TYPE_ Sex DAY_CL SEASONS4 LVAR N GEOMEAN GEOMP5 GEOMP95 ; run;
ods rtf close;

 
 







*ARITHMETIC MEANS AMONG CONSUMERS ONLY;
*Arithmetic mean among consumers;
DATA DBO_WT ; SET _NULL_; RUN ;
DATA A; SET ALL; IF GR01=0 then delete; run; %PERC_WT(A,GR01, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR02=0 then delete; run; %PERC_WT(A,GR02, SEX  DAY_CL,sampleweight );
DATA A; SET ALL; IF GR03=0 then delete; run; %PERC_WT(A,GR03, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR04=0 then delete; run; %PERC_WT(A,GR04, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR05=0 then delete; run; %PERC_WT(A,GR05, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR06=0 then delete; run; %PERC_WT(A,GR06, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR07=0 then delete; run; %PERC_WT(A,GR07, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR08=0 then delete; run; %PERC_WT(A,GR08, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR09=0 then delete; run; %PERC_WT(A,GR09, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR10=0 then delete; run; %PERC_WT(A,GR10, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR11=0 then delete; run; %PERC_WT(A,GR11, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR12=0 then delete; run; %PERC_WT(A,GR12, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR13=0 then delete; run; %PERC_WT(A,GR13, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR14=0 then delete; run; %PERC_WT(A,GR14, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR15=0 then delete; run; %PERC_WT(A,GR15, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR16=0 then delete; run; %PERC_WT(A,GR16, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR17=0 then delete; run; %PERC_WT(A,GR17, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF GR18=0 then delete; run; %PERC_WT(A,GR18, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF RALCOHOL=0 then delete; run; %PERC_WT(A,RALCOHOL, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF RCARBOHYDRATE=0 then delete; run; %PERC_WT(A,RCARBOHYDRATE, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF RENERGY=0 then delete; run; %PERC_WT(A,RENERGY, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF RPROTEIN=0 then delete; run; %PERC_WT(A,RPROTEIN, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF RTOTFAT=0 then delete; run; %PERC_WT(A,RTOTFAT, SEX  DAY_CL,sampleweight);

/*%PERC_WT(ALL,GR01, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR02, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR03, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR04, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR05, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR06, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR07, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR08, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR09, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR10, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR11, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR12, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR13, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR14, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR15, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR16, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR17, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,GR18, SEX  SEASONS2,sampleweight);
%PERC_WT(ALL,RALCOHOL, SEX SEASONS2,sampleweight);
%PERC_WT(ALL,RCARB, SEX SEASONS2,sampleweight);
%PERC_WT(ALL,RENERGY, SEX SEASONS2,sampleweight);
%PERC_WT(ALL,RPROTEIN, SEX SEASONS2,sampleweight);
%PERC_WT(ALL,RTOTFAT, SEX SEASONS2,sampleweight);*/

DATA A; SET ALL; IF GR01=0 then delete; run;		%PERC_WT(A,GR01, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR02=0 then delete; run;		%PERC_WT(A,GR02, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR03=0 then delete; run;		%PERC_WT(A,GR03, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR04=0 then delete; run;		%PERC_WT(A,GR04, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR05=0 then delete; run;		%PERC_WT(A,GR05, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR06=0 then delete; run;		%PERC_WT(A,GR06, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR07=0 then delete; run;		%PERC_WT(A,GR07, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR08=0 then delete; run;		%PERC_WT(A,GR08, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR09=0 then delete; run;		%PERC_WT(A,GR09, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR10=0 then delete; run;		%PERC_WT(A,GR10, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR11=0 then delete; run;		%PERC_WT(A,GR11, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR12=0 then delete; run;		%PERC_WT(A,GR12, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR13=0 then delete; run;		%PERC_WT(A,GR13, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR14=0 then delete; run;		%PERC_WT(A,GR14, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR15=0 then delete; run;		%PERC_WT(A,GR15, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR16=0 then delete; run;		%PERC_WT(A,GR16, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR17=0 then delete; run;		%PERC_WT(A,GR17, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF GR18=0 then delete; run;		%PERC_WT(A,GR18, SEX  SEASONS4,sampleweight);
DATA A; SET ALL; IF RALCOHOL=0 then delete; run;	%PERC_WT(A,RALCOHOL, SEX SEASONS4,sampleweight);
DATA A; SET ALL; IF RCARBOHYDRATE=0 then delete; run;%PERC_WT(A,RCARBOHYDRATE, SEX SEASONS4,sampleweight);
DATA A; SET ALL; IF RENERGY=0 then delete; run;		%PERC_WT(A,RENERGY, SEX SEASONS4,sampleweight);
DATA A; SET ALL; IF RPROTEIN=0 then delete; run;	%PERC_WT(A,RPROTEIN, SEX SEASONS4,sampleweight);
DATA A; SET ALL; IF RTOTFAT=0 then delete; run;		%PERC_WT(A,RTOTFAT, SEX SEASONS4,sampleweight);

*calculation of NC;
DATA TableNC ; SET _NULL_; RUN ;
%CALNC(ALL,RALCOHOL, SEX  DAY_CL);
%CALNC(ALL,RCARBOHYDRATE, SEX  DAY_CL);
%CALNC(ALL,RENERGY, SEX  DAY_CL);
%CALNC(ALL,RPROTEIN, SEX  DAY_CL);
%CALNC(ALL,RTOTFAT, SEX  DAY_CL);
%CALNC(ALL,GR01, SEX  DAY_CL);
%CALNC(ALL,GR02, SEX  DAY_CL);
%CALNC(ALL,GR03, SEX  DAY_CL);
%CALNC(ALL,GR04, SEX  DAY_CL);
%CALNC(ALL,GR05, SEX  DAY_CL);
%CALNC(ALL,GR06, SEX  DAY_CL);
%CALNC(ALL,GR07, SEX  DAY_CL);
%CALNC(ALL,GR08, SEX  DAY_CL);
%CALNC(ALL,GR09, SEX  DAY_CL);
%CALNC(ALL,GR10, SEX  DAY_CL);
%CALNC(ALL,GR11, SEX  DAY_CL);
%CALNC(ALL,GR12, SEX  DAY_CL);
%CALNC(ALL,GR13, SEX  DAY_CL);
%CALNC(ALL,GR14, SEX  DAY_CL);
%CALNC(ALL,GR15, SEX  DAY_CL);
%CALNC(ALL,GR16, SEX  DAY_CL);
%CALNC(ALL,GR17, SEX  DAY_CL);
%CALNC(ALL,GR18, SEX  DAY_CL);

/*%CALNC(ALL,RALCOHOL, SEX  SEASONS2);
%CALNC(ALL,RCARB, SEX  SEASONS2);
%CALNC(ALL,RENERGY, SEX  SEASONS2);
%CALNC(ALL,RPROTEIN, SEX  SEASONS2);
%CALNC(ALL,RTOTFAT, SEX  SEASONS2);
%CALNC(ALL,GR01, SEX  SEASONS2);
%CALNC(ALL,GR02, SEX  SEASONS2);
%CALNC(ALL,GR03, SEX  SEASONS2);
%CALNC(ALL,GR04, SEX  SEASONS2);
%CALNC(ALL,GR05, SEX  SEASONS2);
%CALNC(ALL,GR06, SEX  SEASONS2);
%CALNC(ALL,GR07, SEX  SEASONS2);
%CALNC(ALL,GR08, SEX  SEASONS2);
%CALNC(ALL,GR09, SEX  SEASONS2);
%CALNC(ALL,GR10, SEX  SEASONS2);
%CALNC(ALL,GR11, SEX  SEASONS2);
%CALNC(ALL,GR12, SEX  SEASONS2);
%CALNC(ALL,GR13, SEX  SEASONS2);
%CALNC(ALL,GR14, SEX  SEASONS2);
%CALNC(ALL,GR15, SEX  SEASONS2);
%CALNC(ALL,GR16, SEX  SEASONS2);
%CALNC(ALL,GR17, SEX  SEASONS2);
%CALNC(ALL,GR18, SEX  SEASONS2);*/

%CALNC(ALL,RALCOHOL, SEX  SEASONS4);
%CALNC(ALL,RCARBOHYDRATE, SEX  SEASONS4);
%CALNC(ALL,RENERGY, SEX  SEASONS4);
%CALNC(ALL,RPROTEIN, SEX  SEASONS4);
%CALNC(ALL,RTOTFAT, SEX  SEASONS4);
%CALNC(ALL,GR01, SEX  SEASONS4);
%CALNC(ALL,GR02, SEX  SEASONS4);
%CALNC(ALL,GR03, SEX  SEASONS4);
%CALNC(ALL,GR04, SEX  SEASONS4);
%CALNC(ALL,GR05, SEX  SEASONS4);
%CALNC(ALL,GR06, SEX  SEASONS4);
%CALNC(ALL,GR07, SEX  SEASONS4);
%CALNC(ALL,GR08, SEX  SEASONS4);
%CALNC(ALL,GR09, SEX  SEASONS4);
%CALNC(ALL,GR10, SEX  SEASONS4);
%CALNC(ALL,GR11, SEX  SEASONS4);
%CALNC(ALL,GR12, SEX  SEASONS4);
%CALNC(ALL,GR13, SEX  SEASONS4);
%CALNC(ALL,GR14, SEX  SEASONS4);
%CALNC(ALL,GR15, SEX  SEASONS4);
%CALNC(ALL,GR16, SEX  SEASONS4);
%CALNC(ALL,GR17, SEX  SEASONS4);
%CALNC(ALL,GR18, SEX  SEASONS4);

PROC SORT DATA=DBO_WT; BY LVAR _TYPE_;RUN;
PROC SORT DATA=TABLENC; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO_WT TABLENC;BY LVAR _TYPE_;RUN;
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ArithmMeanByseasonDays_weighted_amongconsumers.rtf';
proc print data=ARITHM;run;
ods rtf close;


*geometric means weighted for sampling weights among consumers only;
DATA DBO_WT ; SET _NULL_; RUN ;
DATA A; SET ALL; IF GR01=0 then delete; run;		%PERC_WT(A,LOGGR01, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR02=0 then delete; run;		%PERC_WT(A,LOGGR02, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR03=0 then delete; run;		%PERC_WT(A,LOGGR03, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR04=0 then delete; run;		%PERC_WT(A,LOGGR04, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR05=0 then delete; run;		%PERC_WT(A,LOGGR05, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR06=0 then delete; run;		%PERC_WT(A,LOGGR06, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR07=0 then delete; run;		%PERC_WT(A,LOGGR07, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR08=0 then delete; run;		%PERC_WT(A,LOGGR08, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR09=0 then delete; run;		%PERC_WT(A,LOGGR09, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR10=0 then delete; run;		%PERC_WT(A,LOGGR10, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR11=0 then delete; run;		%PERC_WT(A,LOGGR11, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR12=0 then delete; run;		%PERC_WT(A,LOGGR12, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR13=0 then delete; run;		%PERC_WT(A,LOGGR13, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR14=0 then delete; run;		%PERC_WT(A,LOGGR14, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR15=0 then delete; run;		%PERC_WT(A,LOGGR15, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR16=0 then delete; run;		%PERC_WT(A,LOGGR16, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR17=0 then delete; run;		%PERC_WT(A,LOGGR17, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF GR18=0 then delete; run;		%PERC_WT(A,LOGGR18, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF RALCOHOL=0 then delete; run;	 %PERC_WT(A,LOGALC, 	SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF RCARBOHYDRATE=0 then delete; run; %PERC_WT(A,LOGCARB, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF RENERGY=0 then delete; run;		 %PERC_WT(A,LOGENER, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF RPROTEIN=0 then delete; run;	 %PERC_WT(A,LOGPROT, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF RTOTFAT=0 then delete; run;		 %PERC_WT(A,LOGFAT, 	SEX DAY_CL ,sampleweight);

/*%PERC_WT(A,LOGGR01, SEX SEASONS2 );
%PERC_WT(A,LOGGR02, SEX SEASONS2 );
%PERC_WT(A,LOGGR03, SEX SEASONS2 );
%PERC_WT(A,LOGGR04, SEX SEASONS2 );
%PERC_WT(A,LOGGR05, SEX SEASONS2 );
%PERC_WT(A,LOGGR06, SEX SEASONS2 );
%PERC_WT(A,LOGGR07, SEX SEASONS2 );
%PERC_WT(A,LOGGR08, SEX SEASONS2 );
%PERC_WT(A,LOGGR09, SEX SEASONS2 );
%PERC_WT(A,LOGGR10, SEX SEASONS2 );
%PERC_WT(A,LOGGR11, SEX SEASONS2 );
%PERC_WT(A,LOGGR12, SEX SEASONS2 );
%PERC_WT(A,LOGGR13, SEX SEASONS2 );
%PERC_WT(A,LOGGR14, SEX SEASONS2 );
%PERC_WT(A,LOGGR15, SEX SEASONS2 );
%PERC_WT(A,LOGGR16, SEX SEASONS2 );
%PERC_WT(A,LOGGR17, SEX SEASONS2 );
%PERC_WT(A,LOGGR18, SEX SEASONS2 );
%PERC_WT(A,LOGALC, 	SEX SEASONS2);
%PERC_WT(A,LOGCARB, 	SEX SEASONS2);
%PERC_WT(A,LOGENER, 	SEX SEASONS2);
%PERC_WT(A,LOGPROT, 	SEX SEASONS2);
%PERC_WT(A,LOGFAT, 	SEX SEASONS2);
*/

DATA A; SET ALL; IF GR01=0 then delete; run;		%PERC_WT(A,LOGGR01, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR02=0 then delete; run;		%PERC_WT(A,LOGGR02, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR03=0 then delete; run;		%PERC_WT(A,LOGGR03, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR04=0 then delete; run;		%PERC_WT(A,LOGGR04, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR05=0 then delete; run;		%PERC_WT(A,LOGGR05, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR06=0 then delete; run;		%PERC_WT(A,LOGGR06, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR07=0 then delete; run;		%PERC_WT(A,LOGGR07, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR08=0 then delete; run;		%PERC_WT(A,LOGGR08, SEX SEASONS4 ,sampleweight); 
DATA A; SET ALL; IF GR09=0 then delete; run;		%PERC_WT(A,LOGGR09, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR10=0 then delete; run;		%PERC_WT(A,LOGGR10, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR11=0 then delete; run;		%PERC_WT(A,LOGGR11, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR12=0 then delete; run;		%PERC_WT(A,LOGGR12, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR13=0 then delete; run;		%PERC_WT(A,LOGGR13, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR14=0 then delete; run;		%PERC_WT(A,LOGGR14, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR15=0 then delete; run;		%PERC_WT(A,LOGGR15, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR16=0 then delete; run;		%PERC_WT(A,LOGGR16, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR17=0 then delete; run;		%PERC_WT(A,LOGGR17, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF GR18=0 then delete; run;		%PERC_WT(A,LOGGR18, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF RALCOHOL=0 then delete; run; %PERC_WT(A,LOGALC, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF RCARBOHYDRATE=0 then delete; run; %PERC_WT(A,LOGCARB,SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF RENERGY=0 then delete; run;%PERC_WT(A,LOGENER,SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF RPROTEIN=0 then delete; run;%PERC_WT(A,LOGPROT,SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF RTOTFAT=0 then delete; run;%PERC_WT(A,LOGFAT, SEX SEASONS4 ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
GEOMIN=EXP(MIN)-1;
GEOMP1=EXP(P1)-1;
GEOMP5=EXP(P5)-1;
GEOMP10=EXP(P10)-1;
GEOMP25=EXP(P25)-1;
GEOMEAN=EXP(MEAN)-1;
GEOMSTD=EXP(STD)-1;
GEOMP50=EXP(P50)-1;
GEOMP75=EXP(P75)-1;
GEOMP90=EXP(P90)-1;
GEOMP95=EXP(P95)-1;
GEOMP99=EXP(P99)-1;
GEOMAX=EXP(MAX)-1;

RUN;
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\GeoMeanByseasonDays_weighted_amongconsumers.rtf';
proc print data=GEOM;var  _TYPE_ Sex DAY_CL SEASONS4 LVAR N GEOMEAN GEOMP5 GEOMP95 ; run;
ods rtf close;

 


 
Proc sort data=DAYS; BY SEX1; RUN;

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*KRUSKALL WALLIS TEST*/
/*AMONG ADULTS >18 AND LOG VARIABLES*/
 proc npar1way data=days noprint;
	 class AGECL;
var LOGM_GR01 LOGM_GR02 LOGM_GR03 LOGM_GR04 LOGM_GR05 LOGM_GR06 LOGM_GR07 LOGM_GR08 LOGM_GR09 LOGM_GR10 LOGM_GR11 LOGM_GR12 LOGM_GR13 LOGM_GR14 LOGM_GR15 LOGM_GR16 LOGM_GR17
LOGM_GR18 LOGMALC LOGMCARB LOGMENER LOGMPROT LOGMFAT;
	  by SEX1;
	  where AGECL not in (1,2);
	  output out=KW_4ADULTS_LOG wilcoxon;
	run;
/*AMONG THE 6 CAT AND LOG VARIABLES*/
 proc npar1way data=days noprint;
	 class AGECL;
var LOGM_GR01 LOGM_GR02 LOGM_GR03 LOGM_GR04 LOGM_GR05 LOGM_GR06 LOGM_GR07 LOGM_GR08 LOGM_GR09 LOGM_GR10 LOGM_GR11 LOGM_GR12 LOGM_GR13 LOGM_GR14 LOGM_GR15 LOGM_GR16 LOGM_GR17
LOGM_GR18 LOGMALC LOGMCARB LOGMENER LOGMPROT LOGMFAT;
	  by SEX1;
	  output out=KW_6ADULTS_LOG wilcoxon;
	run;
*based on log var or not, does not change the kruskall wallis test as it is non param test;
/*AMONG ADULTS >18; */
 proc npar1way data=days noprint;
	 class AGECL;
var M_GR01 M_GR02 M_GR03 M_GR04 M_GR05 M_GR06 M_GR07 M_GR08 M_GR09 M_GR10 M_GR11 M_GR12 M_GR13 M_GR14 M_GR15 M_GR16 M_GR17 M_GR18 MALC MCARB MENER MPROT MFAT;
	  by SEX1;
	  where AGECL not in (1,2);
	  output out=KW_4ADULTS wilcoxon;
	run;
/*AMONG THE 6 AGE CAT */
 proc npar1way data=days noprint;
	 class AGECL;
var M_GR01 M_GR02 M_GR03 M_GR04 M_GR05 M_GR06 M_GR07 M_GR08 M_GR09 M_GR10 M_GR11 M_GR12 M_GR13 M_GR14 M_GR15 M_GR16 M_GR17 M_GR18 MALC MCARB MENER MPROT MFAT;
	  by SEX1;
	  output out=KW_6ADULTS wilcoxon;
	run;
PROC CONTENTS DATA=KW_4ADULTS_LOG;RUN;
dATA KW_4ADULTS_LOG (KEEP= SEX1 _VAR_ _KW_ P_KW); set KW_4ADULTS_LOG;run;
data KW_6ADULTS_LOG (KEEP= SEX1 _VAR_ _KW_ P_KW); set KW_6ADULTS_LOG;run;

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\KWtests.rtf';
title 'KW -Adults only';
PROC PRINT DATA=KW_4ADULTS_LOG;RUN;
title 'KW -6 categories';
PROC PRINT DATA=KW_6ADULTS_LOG;RUN;
title;
ods rtf close;

/*AMONG NON-CONSUMERS*/
/*MACRO Kruskall wallis among consumers*/

%macro KW(db,var, outab) ;
 proc npar1way data=&db noprint;
	 class AGECL;
var &var; 
	  by SEX1;
	  where AGECL not in (1,2);
	  output out=&outab wilcoxon;
	run;
	DATA &outab (KEEP= SEX1 _VAR_ _KW_ P_KW); set &outab; RUN;
%mend KW;
DATA B; SET DAYS; IF M_GR01 ne 0; RUN; %KW(B,LOGM_GR01,KW_GR01) ; 
DATA B; SET DAYS; IF M_GR02 ne 0; RUN; %KW(B,LOGM_GR02,KW_GR02) ; 
DATA B; SET DAYS; IF M_GR03 ne 0; RUN; %KW(B,LOGM_GR03,KW_GR03) ; 
DATA B; SET DAYS; IF M_GR04 ne 0; RUN; %KW(B,LOGM_GR04,KW_GR04) ; 
DATA B; SET DAYS; IF M_GR05 ne 0; RUN; %KW(B,LOGM_GR05,KW_GR05) ; 
DATA B; SET DAYS; IF M_GR06 ne 0; RUN; %KW(B,LOGM_GR06,KW_GR06) ; 
DATA B; SET DAYS; IF M_GR07 ne 0; RUN; %KW(B,LOGM_GR07,KW_GR07) ; 
DATA B; SET DAYS; IF M_GR08 ne 0; RUN; %KW(B,LOGM_GR08,KW_GR08) ; 
DATA B; SET DAYS; IF M_GR09 ne 0; RUN; %KW(B,LOGM_GR09,KW_GR09) ; 
DATA B; SET DAYS; IF M_GR10 ne 0; RUN; %KW(B,LOGM_GR10,KW_GR10) ; 
DATA B; SET DAYS; IF M_GR11 ne 0; RUN; %KW(B,LOGM_GR11,KW_GR11) ; 
DATA B; SET DAYS; IF M_GR12 ne 0; RUN; %KW(B,LOGM_GR12,KW_GR12) ; 
DATA B; SET DAYS; IF M_GR13 ne 0; RUN; %KW(B,LOGM_GR13,KW_GR13) ; 
DATA B; SET DAYS; IF M_GR14 ne 0; RUN; %KW(B,LOGM_GR14,KW_GR14) ; 
DATA B; SET DAYS; IF M_GR15 ne 0; RUN; %KW(B,LOGM_GR15,KW_GR15) ; 
DATA B; SET DAYS; IF M_GR16 ne 0; RUN; %KW(B,LOGM_GR16,KW_GR16) ; 
DATA B; SET DAYS; IF M_GR17 ne 0; RUN; %KW(B,LOGM_GR17,KW_GR17) ; 
DATA B; SET DAYS; IF M_GR18 ne 0; RUN; %KW(B,LOGM_GR18,KW_GR18) ; 
DATA B; SET DAYS; IF MALC ne 0; RUN;  %KW(B,MALC,KW_ALC) ; 
DATA B; SET DAYS; IF MCARB ne 0; RUN; %KW(B,MCARB,KW_CARB) ; 
DATA B; SET DAYS; IF MENER ne 0; RUN; %KW(B,MENER,KW_ENER) ; 
DATA B; SET DAYS; IF MPROT ne 0; RUN; %KW(B,MPROT,KW_PROT) ; 
DATA B; SET DAYS; IF MFAT ne 0; RUN;  %KW(B,MFAT,KW_FAT) ; 

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\KW_amongconsumers.rtf';
Data ALL; SET 
KW_GR01 KW_GR02 KW_GR03 KW_GR04 KW_GR05 KW_GR06 KW_GR07 KW_GR08 KW_GR09 KW_GR10 KW_GR11 KW_GR12 KW_GR13 KW_GR14 KW_GR15 KW_GR16 KW_GR17 KW_GR18 KW_ALC KW_CARB KW_ENER KW_PROT KW_FAT;run;
PROC PRINT DATA=ALL;RUN;
ods rtf close;





/*Without breaking the matching*/
*indicator on number of weekdays;
DATA DAYS; SET DAYS; 
*weekdays;
sumdays=DAYCL1+DAYCL2;
Nweekdays=0;
if sumdays=2 then Nweekdays=0; else if sumdays=3 then Nweekdays=1; else if sumdays=4 then Nweekdays=2; 
RUN;
/*PROC FREQ data=DAYS; table sumdays Nweekdays SEAS1_2 SEAS1_4 SEAS2_2 SEAS2_4;run;
PROC FREQ data=DAYS; table SEAS1_4*SEAS2_4;run;*/


/*calcul ARITHMETIC mean of the means*/
DATA DBO ; SET _NULL_; RUN ;
%PERC(DAYS,M_GR01, SEX1  Nweekdays);
%PERC(DAYS,M_GR02, SEX1  Nweekdays);
%PERC(DAYS,M_GR03, SEX1  Nweekdays);
%PERC(DAYS,M_GR04, SEX1  Nweekdays);
%PERC(DAYS,M_GR05, SEX1  Nweekdays);
%PERC(DAYS,M_GR06, SEX1  Nweekdays);
%PERC(DAYS,M_GR07, SEX1  Nweekdays);
%PERC(DAYS,M_GR08, SEX1  Nweekdays);
%PERC(DAYS,M_GR09, SEX1  Nweekdays);
%PERC(DAYS,M_GR10, SEX1  Nweekdays);
%PERC(DAYS,M_GR11, SEX1  Nweekdays);
%PERC(DAYS,M_GR12, SEX1  Nweekdays);
%PERC(DAYS,M_GR13, SEX1  Nweekdays);
%PERC(DAYS,M_GR14, SEX1  Nweekdays);
%PERC(DAYS,M_GR15, SEX1  Nweekdays);
%PERC(DAYS,M_GR16, SEX1  Nweekdays);
%PERC(DAYS,M_GR17, SEX1  Nweekdays);
%PERC(DAYS,M_GR18, SEX1  Nweekdays);
%PERC(DAYS,MALC, SEX1 Nweekdays);
%PERC(DAYS,MCARB, SEX1 Nweekdays );
%PERC(DAYS,MENER,SEX1 Nweekdays);
%PERC(DAYS,MPROT,SEX1 Nweekdays);
%PERC(DAYS,MFAT,SEX1 Nweekdays);

DATA TableNC ; SET _NULL_; RUN ;
%CALNC(DAYS,M_GR01, SEX1 Nweekdays);
%CALNC(DAYS,M_GR02, SEX1 Nweekdays);
%CALNC(DAYS,M_GR03, SEX1 Nweekdays);
%CALNC(DAYS,M_GR04, SEX1 Nweekdays);
%CALNC(DAYS,M_GR05, SEX1 Nweekdays);
%CALNC(DAYS,M_GR06, SEX1 Nweekdays);
%CALNC(DAYS,M_GR07, SEX1 Nweekdays);
%CALNC(DAYS,M_GR08, SEX1 Nweekdays);
%CALNC(DAYS,M_GR09, SEX1 Nweekdays);
%CALNC(DAYS,M_GR10, SEX1 Nweekdays);
%CALNC(DAYS,M_GR11, SEX1 Nweekdays);
%CALNC(DAYS,M_GR12, SEX1 Nweekdays);
%CALNC(DAYS,M_GR13, SEX1 Nweekdays);
%CALNC(DAYS,M_GR14, SEX1 Nweekdays);
%CALNC(DAYS,M_GR15, SEX1 Nweekdays);
%CALNC(DAYS,M_GR16, SEX1 Nweekdays);
%CALNC(DAYS,M_GR17, SEX1 Nweekdays);
%CALNC(DAYS,M_GR18, SEX1 Nweekdays);
%CALNC(DAYS,MALC, SEX1 Nweekdays);
%CALNC(DAYS,MCARB, SEX1 Nweekdays);
%CALNC(DAYS,MENER,SEX1 Nweekdays);
%CALNC(DAYS,MPROT,SEX1 Nweekdays);
%CALNC(DAYS,MFAT,SEX1 Nweekdays);

PROC SORT DATA=DBO; BY LVAR _TYPE_;RUN;
PROC SORT DATA=Tablenc; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO TABLENC;BY LVAR _TYPE_;RUN;

/*calcul GEOMETRIC mean of the means*/
DATA DBO ; SET _NULL_; RUN ;
%PERC(DAYS,LOGM_GR01, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR02, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR03, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR04, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR05, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR06, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR07, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR08, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR09, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR10, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR11, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR12, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR13, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR14, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR15, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR16, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR17, SEX1 Nweekdays );
%PERC(DAYS,LOGM_GR18, SEX1 Nweekdays );
%PERC(DAYS,LOGMALC, SEX1 Nweekdays );
%PERC(DAYS,LOGMCARB,SEX1 Nweekdays  );
%PERC(DAYS,LOGMENER,SEX1 Nweekdays  );
%PERC(DAYS,LOGMPROT,SEX1 Nweekdays  );
%PERC(DAYS,LOGMFAT, SEX1 Nweekdays );

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO; 
GEOMIN=EXP(MIN);
GEOMP1=EXP(P1);
GEOMP5=EXP(P5);
GEOMP10=EXP(P10);
GEOMP25=EXP(P25);
GEOMEAN=EXP(MEAN);
GEOMSTD=EXP(STD);
GEOMP50=EXP(P50);
GEOMP75=EXP(P75);
GEOMP90=EXP(P90);
GEOMP95=EXP(P95);
GEOMP99=EXP(P99);
GEOMAX=EXP(MAX);
RUN;

