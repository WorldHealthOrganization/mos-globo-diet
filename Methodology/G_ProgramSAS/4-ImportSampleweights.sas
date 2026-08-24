/*import sampling weights PROVIDED BY THE NATIONAL STATISTICS OFFICE*/
/*SAVE DATABASES*/
DATA ALL; set A.ALL;run;
DATA DAYS; set A.DAYS;run;
/*PROC IMPORT OUT= WORK.weights 
            DATAFILE= "Z:\DEX\Global Surveillance\Data_Analyses\Malta\Datasets_PreliminaryReport\NFCS-Final_Sample130716.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;*/


data WORK.district;
infile '\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\NFCS-Final_Sample130716.csv'
DELIMITER=',' 
MISSOVER 
DSD 
LRECL=32767 
FIRSTOBS=2 ; 

informat Subject_ID best32. ;
informat Sex $6.;
informat District $30.;
informat Age_group $10.;

input
	Subject_ID Sex $ District $ Age_group $ ;
run;



data WORK.weights;
infile '\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\MetaData\Samplingweights_NationalFoodConsumptionSurvey.csv'
DELIMITER=',' 
MISSOVER 
DSD 
LRECL=32767 
FIRSTOBS=4 ; 

informat Age_group $10.;
informat District $30.;
informat Sex $6.;
informat sampleweight best32. ;

input
	Age_group $ District $ Sex $  sampleweight;
run;
*merge the 2 info;
proc sort data=weights; by age_group district sex;run;
proc sort data=district;by age_group district sex;run;

data weights; merge weights district ; by age_group district sex;run;

/*link to GD database*/
proc sort data=weights; by Subject_ID;run;
data days_s; set days;
Subject_ID=id_num*1;run;
proc sort data=days_s;by Subject_ID;run;

*dataset with id in the Quest and GD;
data tableSamples samponly GDonly;
	merge weights(in=a) days_s(in=b);
	by Subject_ID;
	if a and b then output tableSamples;
	if a and ^b then output samponly; 
	if ^a and b then output GDonly; 
run;

*merge sample weights with DAYS and ALL datasets;
*days;
data S;
	merge weights(in=a) days_s(in=b);
	by Subject_ID;
	if a and b then output S;
run;

/*checks based on sex*/
/*proc print data= S; var id_num subject_id sex sex1; where (sex='Female' and sex1='Man') or (sex='Male' and sex1='Woman');run;*/

*all;
data all_s; set all;
Subject_ID=id_num*1;run;
proc sort data=all_s;by Subject_ID;run;
data ALLS;
	merge weights(in=a) all_s(in=b);
	by Subject_ID;
	if a and b then output ALLS;
run;



*hard save;
DATA A.DAYS; set S; RUN;
DATA A.ALL; set ALLS; RUN;
