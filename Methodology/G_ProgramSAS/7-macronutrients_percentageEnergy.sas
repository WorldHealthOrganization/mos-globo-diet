/*---------------------------------*/
/*STATISTICAL ANALYSES*/
/*MACRO NUT EXPRESSED IN % OF ENERGY*/



/*prog by AM - sept 2016 updated in oct 2017*/
OPTION LINESIZE=256 PAGESIZE=1000 COMPRESS=BINARY NOCENTER ;
LIBNAME A       '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses';
LIBNAME library '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses';
%include "\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses\0-Formats.sas";


DATA DAYS; SET A.DAYS; RUN;
DATA ALL; SET A.ALL; RUN;
/*KEEP ONLY SUBJECTS WITH 2 24HDR & QUEST*/
/*DATA ALL; set ALL; if lang='' then delete; run;
DATA DAYS; set DAYS;if lang='' then delete; run;
*/

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



/*calcul ARITHMETIC mean of the means*/
 ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ArithmeticMeans_PERCENT_ENERGY.rtf';
title 'unweighted analyses';
 *unweighted;
/*DATA DBO ; SET _NULL_; RUN ;

%PERC(DAYS,M_PER_PROT,SEX1 AGECAT1);
%PERC(DAYS,M_PER_CARB, SEX1 AGECAT1 );
%PERC(DAYS,M_PER_FAT,SEX1 AGECAT1);
%PERC(DAYS,M_PER_ALC, SEX1 AGECAT1);

DATA TableNC ; SET _NULL_; RUN ;
%CALNC(DAYS,M_PER_PROT, SEX1 AGECAT1);
%CALNC(DAYS,M_PER_CARB, SEX1 AGECAT1);
%CALNC(DAYS,M_PER_FAT,SEX1 AGECAT1);
%CALNC(DAYS,M_PER_ALC,SEX1 AGECAT1);

PROC SORT DATA=DBO; BY LVAR _TYPE_;RUN;
PROC SORT DATA=Tablenc; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO TABLENC;BY LVAR _TYPE_;RUN;
PROC PRINT DATA=ARITHM;RUN;
*/
title 'weighted analyses';
*weighted;
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(DAYS,M_PER_PROT,SEX1 AGECL ,sampleweight);
%PERC_WT(DAYS,M_PER_CARB, SEX1 AGECL ,sampleweight);
%PERC_WT(DAYS,M_PER_FAT,SEX1 AGECL ,sampleweight);
%PERC_WT(DAYS,M_PER_ALC, SEX1 AGECL,sampleweight);

DATA TableNC ; SET _NULL_; RUN ;
%CALNC(DAYS,M_PER_PROT, SEX1 AGECL);
%CALNC(DAYS,M_PER_CARB, SEX1 AGECL);
%CALNC(DAYS,M_PER_FAT,SEX1 AGECL);
%CALNC(DAYS,M_PER_ALC,SEX1 AGECL);

PROC SORT DATA=DBO_WT; BY LVAR _TYPE_;RUN;
PROC SORT DATA=Tablenc; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO_WT TABLENC;BY LVAR _TYPE_;RUN;
PROC PRINT DATA=ARITHM;RUN;
ods rtf close;

/*calcul GEOMETRIC mean of the means*/
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\GeometricMeans_PERCENT_ENERGY.rtf';
/*title 'unweighted analyses';
DATA DBO ; SET _NULL_; RUN ;
%PERC(DAYS,M_L_PER_ALC, SEX1 AGECAT1 );
%PERC(DAYS,M_L_PER_CARB,SEX1 AGECAT1  );
%PERC(DAYS,M_L_PER_PROT,SEX1 AGECAT1  );
%PERC(DAYS,M_L_PER_FAT, SEX1 AGECAT1 );

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
PROC PRINT DATA=GEOM;RUN;
*/
title 'weighted analyses';
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(DAYS,M_L_PER_ALC, SEX1 AGECL  ,sampleweight);
%PERC_WT(DAYS,M_L_PER_CARB,SEX1 AGECL  ,sampleweight );
%PERC_WT(DAYS,M_L_PER_PROT,SEX1 AGECL  ,sampleweight );
%PERC_WT(DAYS,M_L_PER_FAT, SEX1 AGECL  ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
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
PROC PRINT DATA=GEOM;RUN;
ods rtf close;



/*-------------------------------------------------------------------------------------------------------*/
/*CALCULATION OF ARITHM AND GEOMEAN AMONG CONSUMERS ONLY*/
*weighted;
DATA DBO_WT ; SET _NULL_; RUN ;
DATA D; SET DAYS; IF M_PER_PROT ne 0; RUN;   %PERC_WT(D,M_PER_PROT, SEX1 AGECL,sampleweight);
DATA D; SET DAYS; IF M_PER_CARB ne 0; RUN;  %PERC_WT(D,M_PER_CARB, SEX1 AGECL ,sampleweight);
DATA D; SET DAYS; IF M_PER_FAT ne 0; RUN;  %PERC_WT(D,M_PER_FAT,SEX1 AGECL ,sampleweight);
DATA D; SET DAYS; IF M_PER_ALC ne 0; RUN;   %PERC_WT(D,M_PER_ALC,SEX1 AGECL ,sampleweight);

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ArithmeticMeans_PERCENT_ENERGY_amongConsumersWeighted.rtf';
PROC PRINT DATA=DBO_WT;RUN;
ods rtf close;

DATA DBO_WT ; SET _NULL_; RUN ;
DATA D; SET DAYS; IF M_PER_PROT ne 0; RUN;  %PERC_WT(D,M_L_PER_PROT, SEX1 AGECL  ,sampleweight);
DATA D; SET DAYS; IF M_PER_CARB ne 0; RUN;  %PERC_WT(D,M_L_PER_CARB,SEX1 AGECL  ,sampleweight );
DATA D; SET DAYS; IF M_PER_FAT ne 0; RUN;   %PERC_WT(D,M_L_PER_FAT,SEX1 AGECL  ,sampleweight );
DATA D; SET DAYS; IF M_PER_ALC ne 0; RUN;   %PERC_WT(D,M_L_PER_ALC, SEX1 AGECL  ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
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

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\GeometricMeans_PERCENT_ENERGY_amongConsumersWeighted.rtf';
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

%mend CALICC;

data ALL; set ALL;wt=1; RUN;*simul weight option;
PROC SORT DATA=ALL; by sex;RUN;
DATA TableICC ; SET _NULL_; RUN ;

%CALICC(ALL,L_P_EN_ALC, ,id_num, wt, sex) ; 
%CALICC(ALL,L_P_EN_CARB, ,id_num, wt, sex) ; 
%CALICC(ALL,L_P_EN_PROT, ,id_num, wt, sex) ; 
%CALICC(ALL,L_P_EN_FAT, ,id_num, wt, sex) ; 

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ICCwithoutWeights1_PER_ENER.rtf';
proc print data=TableICC;run;
ods rtf close;


PROC SORT DATA=ALL; by sex AGECL;RUN;
DATA TableICC ; SET _NULL_; RUN ;
%CALICC(ALL,L_P_EN_ALC, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,L_P_EN_CARB, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,L_P_EN_PROT, ,id_num, wt, sex AGECL) ; 
%CALICC(ALL,L_P_EN_FAT, ,id_num, wt, sex AGECL) ; 

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ICCwithoutWeights2_PER_ENER.rtf';
proc print data=TableICC;run;
ods rtf close;





/*ICC AMONG CONSUMERS ONLY*/
Data D (KEEP=id_num M_PER_PROT M_PER_CARB M_PER_FAT M_PER_ALC);
SET DAYS;run;
PROC SORT DATA=D; bY ID_NUM;RUN;
PROC SORT DATA=ALL; BY ID_NUM;RUN;
DATA A; MERGE ALL (IN=A) D (IN=B); BY ID_NUM; if a; RUN;


PROC SORT DATA=A; by sex;RUN;
DATA TableICC ; SET _NULL_; RUN ;
DATA B; SET A; IF M_PER_ALC ne 0; RUN;   %CALICC(B,L_P_EN_ALC, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_PER_CARB ne 0; RUN;  %CALICC(B,L_P_EN_CARB, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_PER_PROT ne 0; RUN;  %CALICC(B,L_P_EN_PROT, ,id_num, wt, sex) ; 
DATA B; SET A; IF M_PER_FAT ne 0; RUN;   %CALICC(B,L_P_EN_FAT, ,id_num, wt, sex) ; 

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ICCwithoutWeights1_PER_ENER_amongconsumers.rtf';
proc print data=TableICC;run;
ods rtf close;

PROC SORT DATA=A; by sex AGECL;RUN;
DATA TableICC ; SET _NULL_; RUN ;
DATA B; SET A; IF M_PER_ALC ne 0; RUN;   %CALICC(B,L_P_EN_ALC, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_PER_CARB ne 0; RUN;  %CALICC(B,L_P_EN_CARB, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_PER_PROT ne 0; RUN;  %CALICC(B,L_P_EN_PROT, ,id_num, wt, sex AGECL) ; 
DATA B; SET A; IF M_PER_FAT ne 0; RUN;   %CALICC(B,L_P_EN_FAT, ,id_num, wt, sex AGECL) ; 


ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ICCwithoutWeights2_PER_ENER_amongconsumers.rtf';
proc print data=TableICC;run;
ods rtf close;











/*ANALYSES BY SEASON AND DAYS*/

/*WEIGHTED MEANS*/
*ARITHMETIC MEANS ALL SUBJECTS;
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(ALL,P_EN_ALC, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,P_EN_CARB, SEX DAY_CL,sampleweight);
%PERC_WT(ALL,P_EN_PROT, SEX  DAY_CL,sampleweight);
%PERC_WT(ALL,P_EN_FAT, SEX DAY_CL,sampleweight);

%PERC_WT(ALL,P_EN_ALC, SEX SEASONS4,sampleweight);
%PERC_WT(ALL,P_EN_CARB, SEX SEASONS4,sampleweight);
%PERC_WT(ALL,P_EN_PROT, SEX SEASONS4,sampleweight);
%PERC_WT(ALL,P_EN_FAT, SEX SEASONS4,sampleweight);

*calculation of NC;
DATA TableNC ; SET _NULL_; RUN ;
%CALNC(ALL,P_EN_ALC, SEX  DAY_CL);
%CALNC(ALL,P_EN_CARB, SEX  DAY_CL);
%CALNC(ALL,P_EN_PROT, SEX  DAY_CL);
%CALNC(ALL,P_EN_FAT, SEX  DAY_CL);

%CALNC(ALL,P_EN_ALC, SEX  SEASONS4);
%CALNC(ALL,P_EN_CARB,SEX  SEASONS4);
%CALNC(ALL,P_EN_PROT,SEX  SEASONS4);
%CALNC(ALL,P_EN_FAT, SEX  SEASONS4);


PROC SORT DATA=DBO_WT; BY LVAR _TYPE_;RUN;
PROC SORT DATA=TABLENC; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO_WT TABLENC;BY LVAR _TYPE_;RUN;
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ArithmMeanByseasonDays_PERCENT_ENERGY_weighted.rtf';
proc print data=ARITHM;run;
ods rtf close;


*geometric means weighted for sampling weights among consumers only;
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(ALL,L_P_EN_ALC, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,L_P_EN_PROT, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,L_P_EN_CARB, SEX DAY_CL ,sampleweight);
%PERC_WT(ALL,L_P_EN_FAT, SEX DAY_CL ,sampleweight);

%PERC_WT(ALL,L_P_EN_ALC, SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,L_P_EN_PROT,SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,L_P_EN_CARB,SEX SEASONS4 ,sampleweight);
%PERC_WT(ALL,L_P_EN_FAT, SEX SEASONS4 ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
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
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\GeoMeanByseasonDays_PERCENT_ENERGY_weighted.rtf';
proc print data=GEOM;var _TYPE_ Sex DAY_CL SEASONS4 LVAR N GEOMEAN GEOMP25 GEOMP75 ; run;
ods rtf close;

 




*ARITHMETIC MEANS AMONG CONSUMERS ONLY;
*Arithmetic mean among consumers;
DATA DBO_WT ; SET _NULL_; RUN ;
DATA A; SET ALL; IF P_EN_ALC=0 then delete; run; %PERC_WT(A,P_EN_ALC, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF P_EN_CARB=0 then delete; run; %PERC_WT(A,P_EN_CARB, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF P_EN_PROT=0 then delete; run; %PERC_WT(A,P_EN_PROT, SEX  DAY_CL,sampleweight);
DATA A; SET ALL; IF P_EN_FAT=0 then delete; run; %PERC_WT(A,P_EN_FAT, SEX  DAY_CL,sampleweight);

DATA A; SET ALL; IF P_EN_ALC=0 then delete; run;	%PERC_WT(A,P_EN_ALC, SEX SEASONS4,sampleweight);
DATA A; SET ALL; IF P_EN_CARB=0 then delete; run;%PERC_WT(A,P_EN_CARB, SEX SEASONS4,sampleweight);
DATA A; SET ALL; IF P_EN_PROT=0 then delete; run;	%PERC_WT(A,P_EN_PROT, SEX SEASONS4,sampleweight);
DATA A; SET ALL; IF P_EN_FAT=0 then delete; run;		%PERC_WT(A,P_EN_FAT, SEX SEASONS4,sampleweight);

*calculation of NC;
DATA TableNC ; SET _NULL_; RUN ;
%CALNC(ALL,P_EN_ALC, SEX  DAY_CL);
%CALNC(ALL,P_EN_CARB, SEX  DAY_CL);
%CALNC(ALL,P_EN_PROT, SEX  DAY_CL);
%CALNC(ALL,P_EN_FAT, SEX  DAY_CL);

%CALNC(ALL,P_EN_ALC, SEX  SEASONS4);
%CALNC(ALL,P_EN_CARB, SEX  SEASONS4);
%CALNC(ALL,P_EN_PROT, SEX  SEASONS4);
%CALNC(ALL,P_EN_FAT, SEX  SEASONS4);


PROC SORT DATA=DBO_WT; BY LVAR _TYPE_;RUN;
PROC SORT DATA=TABLENC; BY LVAR _TYPE_;RUN;
DATA ARITHM ; MERGE DBO_WT TABLENC;BY LVAR _TYPE_;RUN;
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\ArithmMeanByseasonDays_PERCENT_ENERGY_weighted_amongconsumers.rtf';
proc print data=ARITHM;run;
ods rtf close;


*geometric means weighted for sampling weights among consumers only;
DATA DBO_WT ; SET _NULL_; RUN ;

DATA A; SET ALL; IF P_EN_ALC=0 then delete; run;	 %PERC_WT(A,L_P_EN_ALC, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF P_EN_CARB=0 then delete; run;	 %PERC_WT(A,L_P_EN_CARB, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF P_EN_PROT=0 then delete; run;	 %PERC_WT(A,L_P_EN_PROT, SEX DAY_CL ,sampleweight);
DATA A; SET ALL; IF P_EN_FAT=0 then delete; run;	 %PERC_WT(A,L_P_EN_FAT, SEX DAY_CL ,sampleweight);

DATA A; SET ALL; IF P_EN_ALC=0 then delete; run; 	%PERC_WT(A,L_P_EN_ALC, SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF P_EN_CARB=0 then delete; run; 	%PERC_WT(A,L_P_EN_CARB,SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF P_EN_PROT=0 then delete; run;	%PERC_WT(A,L_P_EN_PROT,SEX SEASONS4 ,sampleweight);
DATA A; SET ALL; IF P_EN_FAT=0 then delete; run;	%PERC_WT(A,L_P_EN_FAT, SEX SEASONS4 ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
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
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\GeoMeanByseasonDays_PERCENT_ENERGY_weighted_amongconsumers.rtf';
proc print data=GEOM;var  _TYPE_ Sex DAY_CL SEASONS4 LVAR N GEOMEAN GEOMP25 GEOMP75 ; run;
ods rtf close;



/*----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*ESSAI KRUSKALL WALLIS*/
/*AMONG ADULTS >18; AND LOG VARIABLES*/
PROC SORT DATA=DAYS; BY SEX1;RUN;
 proc npar1way data=days noprint;
	 class AGECL;
var M_L_PER_PROT M_L_PER_FAT M_L_PER_ALC M_L_PER_CARB LOGMENER;
	  by SEX1;
where AGECL not in (1,2);
output out=KW_4ADULTS_LOG wilcoxon;
	run;

dATA KW_4ADULTS_LOG (KEEP= SEX1 _VAR_ _KW_ P_KW); set KW_4ADULTS_LOG;run;
ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\KWtests_perEner.rtf';
title 'KW -Adults only';
PROC PRINT DATA=KW_4ADULTS_LOG;RUN;
title;
ods rtf close;


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
DATA B; SET DAYS; IF M_PER_ALC ne 0; RUN;  %KW(B,M_L_PER_ALC,KW_ALC) ; 
DATA B; SET DAYS; IF M_PER_CARB ne 0; RUN; %KW(B,M_L_PER_CARB,KW_CARB) ; 
DATA B; SET DAYS; IF MENER ne 0; RUN; %KW(B,MENER,KW_ENER) ; 
DATA B; SET DAYS; IF M_PER_PROT ne 0; RUN; %KW(B,M_L_PER_PROT,KW_PROT) ; 
DATA B; SET DAYS; IF M_PER_FAT ne 0; RUN;  %KW(B,M_L_PER_FAT,KW_FAT) ; 

ods rtf file='D:\Aurelie\Nutritional_survey\MaltaSurvey\KW_amongconsumers_perEner.rtf';
Data ALL; SET 
KW_ALC KW_CARB KW_ENER KW_PROT KW_FAT;run;
PROC PRINT DATA=ALL;RUN;
ods rtf close;


/*ESSAI MEAN (LOG (MEAN))*/
/*
DATA DAYS; SET DAYS;
LALC=LOG(M_PER_ALC);
LFAT=LOG(M_PER_FAT);
LPROT=LOG(M_PER_PROT);
LCARB=LOG(M_PER_CARB);
RUN;
ods rtf file='D:\Aurelie\EU-consortium\MaltaSurvey\GeometricMeans_PERCENT_ENERGY_LOGMEANS.rtf';
title 'weighted analyses';
DATA DBO_WT ; SET _NULL_; RUN ;
%PERC_WT(DAYS,LALC, SEX1 AGECAT1  ,sampleweight);
%PERC_WT(DAYS,LFAT,SEX1 AGECAT1  ,sampleweight );
%PERC_WT(DAYS,LPROT,SEX1 AGECAT1  ,sampleweight );
%PERC_WT(DAYS,LCARB, SEX1 AGECAT1  ,sampleweight);

DATA GEOM (DROP=MEAN STD MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX); SET DBO_WT; 
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
PROC PRINT DATA=GEOM;RUN;
ods rtf close;*/
