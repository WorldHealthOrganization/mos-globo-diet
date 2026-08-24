DATA ALL; set A.ALL;run;
DATA DAYS; set A.DAYS;run;

/*IMPORT QUESTIONNAIRE INFORMATION */

/*FINAL ANALYSES*/
/*QUESTIONNAIRES SPLIT IN 2 PARTS*/
PROC IMPORT OUT= WORK.QUEST1 
            DATAFILE= "\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\Questionnaire_data_Part1.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
PROC IMPORT OUT= WORK.QUEST2 
            DATAFILE= "\\Inti\NME\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\Questionnaire_data_Part2.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*suppression of duplicates;
data quest1; set quest1; 
*ID 1320 -> EN version of the questionnaire retained / MT version deleted;
if ID=1320 AND LANG='MT' then delete;
*ID 3363 -> keep in the questionnaire in QUEST2 Qs. Part 2 Sep 17/ deleted the questionnaire in QUEST1 Qs. Part 1 Nov16;
if ID=3363 then delete;
run;

data quest2; set quest2; 
*ID 39 kept the questionnaire in QUEST1 Part 1 Nov16 /deleted the questionnaire in Qs. Part 2 Sep 17;
if ID=39 then delete;
*ID 5786 -> kept the questionnaire in QUEST Qs. Part 1 Nov16 / deleted  questionnaire in QUEST2 Qs. Part 2 Sep 17;
if ID=5786 then delete;
run;


proc sort data=quest1; by id ;run;
proc sort data=quest2; by id ;run;
/*3 subjects id with 2 quest-> temp solution remove 2nd quest (from quest2/part2)*/
data both quest1only quest2only;
	merge quest1(in=a) quest2(in=b);
	by ID;
	if a and b then output both;
	if a and ^b then output quest1only; 
	if ^a and b then output quest2only; 
run;

Data QUEST; set quest1 quest2; run;
proc sort data=quest; by id;run;

/*correction of errors in QUEST info 
Mail Daniel 23august2016-> gender to be corrected in the quest info
461        --> Female
3936       --> Female
5546       --> Male  
5654       --> Male       
5698       --> Female       
5752       --> Male     
added oct2017: 3102 ->Female
962->Male
3661->Male
5084->Male

*/
data quest; set quest;
if id=461 then gender=2;
if id=3936 then gender=2;
if id=5546 then gender=1;
if id=5654 then gender=1;
if id=5698 then gender=2;
if id=5752 then gender=1;
if id=3102 then gender=2;
if id=962 then gender=1;
if id=3661 then gender=1;
if id=5084 then gender=1;
run;

proc sql; select count (distinct id) from quest;quit;

/*link to GD database*/
proc sort data=quest; by id;run;
data days_quest; set days;
id=id_num*1;run;
proc sort data=days_quest;by id;run;


*dataset with id in the Quest and GD;
data both questonly GDonly;
	merge quest(in=a) days_quest(in=b);
	by ID;
	if a and b then output both;
	if a and ^b then output questonly; 
	if ^a and b then output GDonly; 
run;

/*check on sex-> seems correct for IDs with quest*/
proc print data=both; var id_num ID gender sex1; where (gender=2 and sex1='Man') or (gender=1 and sex1='Woman');run;

/*LIST of GloboDiet IDs without Questionnaires:*/
proc print data=GDonly;
var ID /*ID_NUM*/ SEX1 DATE_REC1 DATE_REC2;
run;
/*
       id    SEX1      DATE_REC1     DATE_REC2

      97    Man      07/15/2016    08/21/2016
     369    Woman    11/24/2016    12/16/2016
     510    Woman    05/09/2016    06/09/2016
     513    Man      11/18/2016    01/11/2017
     540    Woman    11/08/2016    12/06/2016
     550    Man      05/12/2016    06/12/2016
     586    Woman    09/01/2016    09/29/2016
     855    Woman    01/25/2016    03/13/2016
     902    Man      07/24/2016    08/30/2016
    1701    Woman    11/05/2016    11/25/2016
    1851    Woman    11/01/2016    12/04/2016
    2054    Man      12/21/2015    01/19/2016
    2134    Woman    09/23/2016    10/16/2016
    2241    Man      10/26/2016    01/18/2017
    2584    Man      03/23/2016    04/20/2016
    2597    Man      10/30/2016    12/13/2016
    2806    Woman    11/28/2016    01/11/2017
    2809    Woman    03/20/2016    05/03/2016
    2816    Man      12/02/2015    01/04/2016
    2882    Woman    05/29/2016    07/04/2016
    2928    Man      09/04/2016    10/13/2016
    2971    Woman    02/15/2016    03/14/2016
    3155    Man      08/07/2016    09/09/2016
    3759    Woman    09/13/2016    10/11/2016
    3835    Man      09/21/2016    10/21/2016
    4085    Woman    10/30/2016    11/27/2016
    4220    Woman    07/05/2016    09/15/2016
    4549    Woman    09/06/2016    10/20/2016
    4557    Woman    11/08/2015    01/16/2016
    4625    Woman    06/15/2016    07/13/2016
    4732    Man      11/09/2016    12/08/2016
    4768    Woman    10/31/2015    12/02/2015
    5036    Woman    07/03/2016    11/30/2016
    5038    Woman    04/25/2016    06/30/2016
    5166    Woman    10/16/2016    11/16/2016
    5252    Woman    01/12/2016    03/14/2016
    5407    Woman    10/20/2016    11/28/2016
    5923    Man      11/15/2016    01/11/2017

*/
/*LIST OF IDs With QUEST BUT NOT GLOBODIET*/
proc print data=questonly;
var ID GENDER;
run;
/*
Obs              id          gender
  1             319               1
  2             501               2
  3             544               2
  4             743               2
  5             871               1
  6            1036               1
  7            1091               2
  8            1584               1
  9            1939               1
 10            2083               1
 11            2226               1
 12            2824               2
 13            2908               2
 14            2993               2
 15            3047               2
 16            3090               2
 17            3618               2
 18            3685               2
 19            4637               2
 20            4646               1
 21            4787               1
 22            5035               2
 23            5041               1
 24            5598               2
 25            5789               1
 26            5969               2
 27            5994               2
*/

/*keep all subjects in DAYS/ALL -> subjects without quest will have missing values for Quest var*/
*merge quest with DAYS and ALL datasets;
*days;
data workdata;
	merge quest(in=a) days_quest(in=b);
	by ID;
	if  b ;
run;
proc sql; select count (distinct id) from workdata;quit;
PROC SORT DATA=workdata; BY ID; RUN ; 
DATA workdata; SET workdata;
by ID; 
retain n1 0; 
if first.ID then n1=0; 
n1+1; 
RUN;
PROC FREQ DATA=workdata ; Tables n1;RUN;
PROC PRINT DATA=workdata; var id ID_NUM ; where n1=2;RUN;
data workdata; set workdata;
if id=461 then gender=2;
if id=3936 then gender=2;
if id=5546 then gender=1;
if id=5654 then gender=1;
if id=5698 then gender=2;
if id=5752 then gender=1;
if id=3102 then gender=2;
if id=962 then gender=1;
if id=3661 then gender=1;
if id=5084 then gender=1;
run;

*all;
data all_s; set all;
id=id_num*1;run;
proc sort data=all_s;by id;run;
data ALLS;
	merge quest(in=a) all_s(in=b);
	by id;
	if /*a and*/ b then output ALLS;
run;
data ALLS; set ALLS;
if id=461 then gender=2;
if id=3936 then gender=2;
if id=5546 then gender=1;
if id=5654 then gender=1;
if id=5698 then gender=2;
if id=5752 then gender=1;
if id=3102 then gender=2;
if id=962 then gender=1;
if id=3661 then gender=1;
if id=5084 then gender=1;
run;
*hard save;
DATA A.DAYS; set workdata; RUN;
DATA A.ALL; set ALLS; RUN;





