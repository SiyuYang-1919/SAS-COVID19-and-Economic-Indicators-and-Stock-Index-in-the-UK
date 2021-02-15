*Sets the default library to folder IntroSASworkspace;
LIBNAME User '/home/u53785542/IntroSASWorkspace/SAS Project';

*-------------------------------------------------------------------------*
*------------PART1: Import and preprocess the data------------------------*
*-------------------------------------------------------------------------*
*Divide seven datasets into three groups: --------------------------------*
1) COVID-19 datasets, ----------------------------------------------------*
2) Economics indicator datasets, -----------------------------------------*
3) Stock index datasets. -------------------------------------------------*
*-------------------------------------------------------------------------*
*Preprocess the datasets in the following steps: -------------------------*
1) Import datasets, ------------------------------------------------------*
2) Clean datasets if necessary, ------------------------------------------*
3) Sort and merge datasets, ----------------------------------------------*
4) Further clean datasets if necessary, ----------------------------------*
5) Examine the final dataset. --------------------------------------------*
*-------------------------------------------------------------------------*

/******************************************/
/********Macro command list 1.0************/
/******************************************/
*Create a macro command to import raw datasets;
%MACRO importdata(file, name, sheetname=None, format=csv);
proc import
            datafile=&file
            out=&name
            dbms=&format
            replace;
  getnames=yes;
  %IF &format=xls %THEN %DO;
     sheet=&sheetname;
  %END;
run;
%MEND importdata;

*Create a macro command to sort datasets by one(or more) variable;
%MACRO sortdata(data, variable);
proc sort data=&data;
    by &variable;
run;
%MEND sortdata;

*Create a macro command to merge at most three datasets through one-to-one match;
%MACRO mergedata(mergeddata, datalist, variable);
 data &mergeddata;
   merge &datalist;
   by &variable;
 run;
%MEND mergedata;

/******************************************************************/
/*******STEP1.Import and preprocess three COVID-19 datasets********/
/******************************************************************/
*1) Import three COVID-19 datasets;
%importdata('/home/u53785542/IntroSASWorkspace/SAS Project/Positive cases COVID-19 UK(spicemen date).csv',
            PositiveCases);
%importdata('/home/u53785542/IntroSASWorkspace/SAS Project/Deaths with COVID-19 UK (within 28 days of positive test by date of death).csv',
            Deaths);
%importdata('/home/u53785542/IntroSASWorkspace/SAS Project/Patients admitted to hospital UK.csv',
            Patients);
            
*2) Sort and merge these datasets;
* Sort the datasets;
%sortdata(PositiveCases, date);
%sortdata(Deaths, date);
%sortdata(Patients, date);

* Merge the datasets;
%mergedata(COVID19, PositiveCases Deaths Patients, date);

************************************************************************************************
Notice that there are some missing data and several unimportant columns in the merged dataset.
I will leave the missing data there because they will not affect our analysis in later sections,
meanwhile, for some columns that do not have missing data, we can have more instances to perform
the analysis.)
************************************************************************************************

*3) Clean the merged dataset;
* Drop some unimportant columns;
data COVID19_final;
 set COVID19;
 drop areaType areaName areaCode;
run;

* Inspect the merged dataset;
proc print data=COVID19_final;
  title 'COVID-19 Dataset';
run;
proc contents data=COVID19_final;
run;

/**************************************************************************/
/*******STEP2.Import and preprocess two economic indicator datasets********/
/**************************************************************************/
*1) Import two economic indicator datasets;
* Set the form of variable names in advance;
Option validvarname=V7;
%importdata('/home/u53785542/IntroSASWorkspace/SAS Project/GDP monthly estimates and components.xls',
            GDP_components,
            sheetname='data',
            format=xls);
            
Option validvarname=V7;
%importdata('/home/u53785542/IntroSASWorkspace/SAS Project/Unemployment rate.xls',
            Unemployment,
            sheetname='data',
            format=xls);

*2) Clean, sort, and merge the two datasets;
* Delete the first 6 rows and rename columns;
data GDP_components_sub;
 set GDP_components;
 if _N_ in (1:6) then delete;
 rename Figure_2__While_construction_out=Month B=MonthlyGDP C=Services D=Production E=Construction;
run;

* Select the monthly data in 2020 only;
data Unemployment_sub;
 set Unemployment;
 if _N_ in (843:852) then output;
 rename title=Month unemployment_rate__aged_16_and_o=Unemployment_rate;
run;

* Sort the two datasets;
%sortdata(GDP_components_sub, month);
%sortdata(Unemployment_sub, month);

* Merge the two datsets;
%mergedata(economics, GDP_components_sub Unemployment_sub, month);

*************************************************************************
Notice that there is a missing data in the last row of Unemployment_rate,
I will leave the missing data there as well, because it will not affect 
the analysis in later sections as well.
*************************************************************************

* Inspect the merged dataset;
proc print data=economics;
  title 'Economics Dataset';
run;
proc contents data=economics;
run;

**********************************************************************************
Notice that we need to convert the type of values in each variable to 'numeric',
also it is better to change the unformatted 'month' varibale to the formatted one.
**********************************************************************************
  
* 3) Further process the merged dataset;
data economics_final;
 set economics;
 Monthname=input(month, monname.);
 format monthname monname.;
 MonthlyGDP_num=input(monthlygdp, 8.);
 Services_num=input(services, 8.);
 Production_num=input(production, 8.);
 Construction_num=input(construction, 8.);
 UnemploymentRate_num=input(unemployment_rate, 8.);
 drop month monthlygdp services production construction unemployment_rate;
run;

* Inspect the dataset;
proc print data=economics_final;
  title 'Economics Dataset';
run;
proc contents data=economics_final;
run;

/*******************************************************************/
/*******STEP3.Import and preprocess two stock index datasets********/
/*******************************************************************/
*1) Import two stock datasets;
%importdata('/home/u53785542/IntroSASWorkspace/SAS Project/FTSE100 Index.xls',
            FTSE100,
            sheetname='Pane 1',
            format=xls);
            
%importdata('/home/u53785542/IntroSASWorkspace/SAS Project/FTSE All-Share Index.xls',
            FTSE_AS,
            sheetname='Pane 1',
            format=xls);
            
*2) Clean, sort, and merge the two datasets;
* Delete the first row and rename variables;
data FTSE100_sub;
 set FTSE100;
 if _N_ in (1) then delete;
 rename A=Dates B=FTSE100;
run;
* Delete the first row and rename variables;
data FTSE_AS_sub;
 set FTSE_AS;
 if _N_ in (1) then delete;
 rename A=Dates B=FTSE_AS;
run;

* Sort the two datasets;
%sortdata(FTSE100_sub, dates);
%sortdata(FTSE_AS_sub, dates);

* Merge the two datasets;
%mergedata(FTSE, FTSE100_sub FTSE_AS_sub, dates);

* Inspect the merged dataset;
proc print data=FTSE;
  title 'FTSE Dataset';
run;
proc contents data=FTSE;
run;

**********************************************************************************
Notice that we need to change the type of values in each variable to 'numeric',
also it is better to change the unformatted 'month' varibale to the formatted one.
**********************************************************************************

*3) Further process the dataset;
/*Convert the character variables to the SAS unformatted datetimes and numeric ones;*
  The first date should be '2020/01/30' according to the original database;*
  Check if the SAS unformatted datetime in variable 'Dates' (e.g. 43860...) starts from that day;*/
data test;
 date1=43860;
 date2=43861;
 format date1 date2 yymmdd10.;
run;

/*Through the simple test above, we can see that the SAS unformatted datetime does not match what we want;
  This is probably because of the format difference between excel and sas;
  We can adjust the SAS unformatted datetimes in 'Dates', then format them;*/
 
* Get the right SAS unformatted datetime for '2020/03/23';
data test2;                        
   date='2020/01/30';                    
   sasdate=input(date,yymmdd10.);        
   put sasdate;                        
   put sasdate date9.;                  
run;

/*Through the small test above, we can see that the right SAS unformatted datatime for '2020/03/23' is
21944 rather than 43860;*/

* Convert character variables to the SAS unformatted datetimes and numeric variables;
* Let each value in 'date' minus (43860-21944) will make them become the right SAS
unformatted datetime;
data FTSE_final;
 set FTSE;
 Date=input(dates, 8.);
 Date=Date-(43860-21944);
 format Date yymmdd10.;
 FTSE100_num=input(FTSE100, 8.);
 FTSE_AS_num=input(FTSE_AS, 8.);
 drop Dates FTSE100 FTSE_AS;
run;

* Inspect the merged dataset;
proc print data=FTSE_final;
  title 'FTSE Dataset';
run;
proc contents data=FTSE_final;
run;


*-------------------------------------------------------------------------*
*---------------PART2: Summarize and Visualize the Data-------------------*
*-------------------------------------------------------------------------*
*Now we have three datasets: ---------------------------------------------*
1) COVID19_final, --------------------------------------------------------*
2) Economics_final, ------------------------------------------------------*
3) FTSE_final. -----------------------------------------------------------*
*-------------------------------------------------------------------------*
*In this part, I will: ---------------------------------------------------*
1) Inspect the basic statistics description of each dataset, -------------*
2) Use series/bar plots to visualise each dataset. -----------------------*
*-------------------------------------------------------------------------*

/******************************************/
/********Macro command list 2.0************/
/******************************************/
*Create a macro command to summarize the dataset;
%MACRO statistics(data, varlist, title);
 proc means data=&data N MIN p5 Q1 MEDIAN Q3 P90 MAX NMISS MEAN STDDEV VAR SKEW KURTOSIS;
  var &varlist;
  title &title;
 run;
%MEND statistics;

*Create a macro command to make a bar-line plot;
%MACRO barlineplot(data, x, y1, y2, title);
 proc sgplot data=&data noautolegend;
  vbar &x / response=&y1 stat=mean nostatlabel dataskin=pressed
              barwidth=0.5 nooutline fillattrs=(color=royalblue transparency=0.2);
  vline &x / response=&y2 stat=mean nostatlabel lineattrs=(color=crimson thickness=3) transparency=0.3 y2axis;
  xaxis type=time display=(nolabel);
  yaxis grid offsetmin=0;
  title &title;
 run;
%MEND barlineplot;

/******************************************************************/
/****************STEP1.COVID19_final dataset***********************/
/******************************************************************/
*1. Summarize the dataset;
* For variables that represent the number of newly-added cases/deaths/patients;
%statistics(covid19_final, newCasesBySpecimenDate newDeaths28DaysByDeathDate newAdmissions,
            'Statistics description for COVID-19 data (new)');
               
* For variables that represent the number of cumulative cases/deaths/patients;
%statistics(covid19_final, cumCasesBySpecimenDate cumDeaths28DaysByDeathDate cumAdmissions,
           'Statistics description for COVID-19 data (cum)');            

*2. Visualize the dataset;
* For 'positive cases' data;
%barlineplot(covid19_final, date, newCasesBySpecimenDate, cumCasesBySpecimenDate,
             'Positive cases by date');
* For 'deaths' data;           
%barlineplot(covid19_final, date, newDeaths28DaysByDeathDate, cumDeaths28DaysByDeathDate,
             'Deaths with COVID-19');
* For 'patients' data;            
%barlineplot(covid19_final, date, newAdmissions, cumAdmissions,
             'Patients admitted to hospitals');

/******************************************************************/
/********************STEP2.Economics dataset***********************/
/******************************************************************/      
*1. Summarize the economics dataset;
%statistics(economics_final, 
            MonthlyGDP_num services_num production_num construction_num UnemploymentRate_num,
            'Statistics description for economics data');

*2. Visualize the dataset;
proc sgplot data=economics_final;
 vline Monthname / response=MonthlyGDP_num legendlabel='GDP'
    markers lineattrs=(color=crimson pattern=1 thickness=3);
 vline Monthname / response=services_num legendlabel='Services'
    markers lineattrs=(color=dodgerblue pattern=2 thickness=2);
 vline Monthname / response=production_num legendlabel='Production'
    markers lineattrs=(color=mediumblue pattern=5 thickness=2);
 vline Monthname / response=construction_num legendlabel='Construction'
    markers lineattrs=(color=royalblue pattern=14 thickness=2);   
 vbar Monthname / response=UnemploymentRate_num nostatlabel stat=mean fillattrs=(color=red transparency=0.5)
 transparency=0.5 barwidth=0.5 y2axis outlineattrs=(thickness=0);
 xaxis type=discrete;
 yaxis label='GDP and Components Index';
 y2axis label='Unemployment Rate' grid offsetmin=0;
 title 'Monthly GDP and Components Index in the UK';
run;

/******************************************************************/
/***********************STEP3.FTSE dataset*************************/
/******************************************************************/ 
*1. Summarize the FTSE dataset;
%statistics(FTSE_final, FTSE100_num FTSE_AS_num,
            'Statistics description for stock index data');       
               
*2. Visualize the dataset;
proc sgplot data=ftse_final;
 series x=date y=FTSE100_num / legendlabel='FTSE100'
    lineattrs=(color=crimson pattern=1 thickness=2);
 series x=date y=FTSE_AS_num / legendlabel='FTSE_All_Share'
    lineattrs=(color=royalblue pattern=1 thickness=2);
    xaxis type=time display=(nolabel);
    yaxis label='FTSE100 and FTSEAllShare Index';
    title 'FTSE Stock Index';
 run;


*----------------------------------------------------------------------------*
*---------------PART3: Correlation and Regression Analysis-------------------*
*----------------------------------------------------------------------------*
*Now we still have three datasets: ------------------------------------------*
1) COVID19_final, -----------------------------------------------------------*
2) Economics_final, ---------------------------------------------------------*
3) FTSE_final. --------------------------------------------------------------*
*----------------------------------------------------------------------------*
*In this part, I will: ------------------------------------------------------*
1) Merge the COVID19_final dataset and Economics_final/FTSE_final dataset, --*
2) Inspect the correlations between each variable in COVID-19 dataset and ---*
variables in the other two datasets, --------------------------------------------*
3) Pick variables that have high correlations to build linear regression ----* 
models and try to predict the economics indicators and FTSE index with ------*
COVID-19 data. --------------------------------------------------------------*
*----------------------------------------------------------------------------*
*----------------------------------------------------------------------------*

/******************************************/
/********Macro command list 3.0************/
/******************************************/
*Create a macro to get the correlations between variables;
%MACRO corr(data, varlist, var=none);
 proc corr data=&data;
 var &varlist;
 %IF &var~=none %THEN %DO;
 with &var;
 %END;
run;
%MEND corr;

*Create a macro to do regression analysis;
%MACRO regression(data, title, y, xlist, plot=none);
proc reg data=&data outest=est;
 title &title;
 model &y=&xlist;
 %IF &plot~=none %THEN %DO;
 plot &y*&xlist;
 %END;
run;
%MEND regression;

*Create a macro to generate predictions;
%MACRO prediction(data, est, newdata, varlist);
proc score data=&data score=&est out=&newdata predict type=parms;
 var &varlist;
run;
%MEND prediction;

*Create a macro to make a scatter plot to compare observations and predictions;
%MACRO scatter(data, x, y);
proc sgplot data=&data;
 scatter x=&x y=&y;
 series x=&x y=&x /
        lineattrs=(color=red pattern=1 thickness=2);
run;
%MEND scatter;


/****************************************************************************/
/****************STEP1.COVID19_final and Economics_final*********************/
/****************************************************************************/
*1. Process these datasets;
*As we only have monthly economic indicators, we need to convert COVID
-19 data to monthly data as well;
*Delete the data after November/2020 in COVID19_final to match the data in
 Economics_final;
*Create a new column to store the month name of each value in 'date';
*Drop cumulative variables as we do not need them right now;
data COVID19_sub;
 set COVID19_final;
 if _N_ in (307:373) then delete;
 month=input(date, monname.);
 format month monname.;
 drop cumCasesBySpecimenDate cumDeaths28DaysByDeathDate cumAdmissions;
run;

*Sum the values in 3 variables by month;
proc summary data=covid19_sub nway;
class month;
var newCasesBySpecimenDate newDeaths28DaysByDeathDate newAdmissions;
output out=covid19_month(drop=_:) sum=cases deaths patients;
run;

*Select cumulative data at the end of each month;
*Drop newly-added data;
data COVID19_cum;
 set COVID19_final;
 if _N_ in (2 31 62 92 123 153 184 215 245 276 306) then output;
 drop newCasesBySpecimenDate newDeaths28DaysByDeathDate newAdmissions;
run;


* 2. Merge datasets;
data covid19_economics_new;
 merge covid19_month economics_final;
 drop monthname;
run;

data covid19_economics_cum;
 merge covid19_cum economics_final;
 rename cumCasesBySpecimenDate=cumcases cumDeaths28DaysByDeathDate=cumdeaths cumAdmissions=cumpatients;
 drop monthname;
run;

****************************************************************
Notice that we have some missing data in the datasets above,
again, it is alright to leave them as where they are as they
will not affect either the correlation analysis or regression, 
meanwhile, we can keep as many instances as possible for other
variables.
****************************************************************

* 3. Correlation analysis;
*1) For variables in covid19_economics_new dataset;
* An overview;
%corr(covid19_economics_new, 
      cases deaths patients monthlyGDP_num services_num production_num construction_num UnemploymentRate_num);

*2) For variables in covid19_economics_cum dataset;
* An overview;
%corr(covid19_economics_cum, 
      cumcases cumdeaths cumpatients monthlyGDP_num services_num production_num construction_num UnemploymentRate_num);

* 4. Regression;
* 1) From the correlation matrix above, we can see that only 'deaths' in covid19_economics_new has high and significant correlation with 
economic indicators, except unemployment rate;

%regression(covid19_economics_new, 'Deaths and MonthlyGDP',
            MonthlyGDP_num, deaths, plot=True);
%regression(covid19_economics_new, 'Deaths and Service_num',
            services_num, deaths, plot=True);
%regression(covid19_economics_new, 'Deaths and Production_num',
            production_num, deaths, plot=True);
%regression(covid19_economics_new, 'Deaths and Construction_num',
            construction_num, deaths, plot=True);
            
* 2) From the correlation matrix above, we can see that all the cumulative COVID19 variables 
in covid19_economics_cum have high and significant correlation with the unemployment rate;

%regression(covid19_economics_cum, 'CumCases and Unemployment_Rate',
            UnemploymentRate_num, cumcases, plot=True);
%regression(covid19_economics_cum, 'CumDeaths and Unemployment_Rate',
            UnemploymentRate_num, cumdeaths, plot=True);
%regression(covid19_economics_cum, 'CumPatients and Unemployment_Rate',
            UnemploymentRate_num, cumpatients, plot=True);


/****************************************************************************/
/****************STEP2.COVID19_final and FTSE_final*********************/
/****************************************************************************/
*1. Process and merge the datasets;
data covid19_stock;
 merge covid19_final ftse_final;
 rename newCasesBySpecimenDate=cases newDeaths28DaysByDeathDate=deaths newAdmissions=patients
        cumCasesBySpecimenDate=cumcases cumDeaths28DaysByDeathDate=cumdeaths cumAdmissions=cumpatients;
run;

*2. Correlation analysis;
* An overview;
%corr(covid19_stock, 
      cases deaths patients cumcases cumdeaths cumpatients ftse100_num ftse_as_num);

*3. Regression;
* From the correlation matrix above, we can see that 'cases', 'patients', 'cumcases', 
'cumdeaths', and 'cumpatients' in covid19_stock have very significant correlations with FTSE stock index;

*1) Build linear regression model to predict FTSE100 stock index;

****************************************************************
I have tried to use single variable and all the combinations of
varibales to build the regression models. Only the following ones
are significant and have relatively fine R^2 score.
****************************************************************

*Use cases and patients to build the model;
%regression(covid19_stock, 'COVID-19 Data and FTSE100',
            ftse100_num, cases patients);    
%prediction(covid19_stock, est, covid_stock_pred, cases patients);
%scatter(covid_stock_pred, ftse100_num, model1);

*Use cumcases and cumpatients to build the model;
%regression(covid19_stock, 'COVID-19 Data and FTSE100',
            ftse100_num, cumcases cumpatients);
%prediction(covid_stock_pred, est, covid_stock_pred, cumcases cumpatients);
%scatter(covid_stock_pred, ftse100_num, model12);
 
*Use cumdeaths and cumpatients to build the model;
%regression(covid19_stock, 'COVID-19 Data and FTSE100',
            ftse100_num, cumdeaths cumpatients);  
%prediction(covid_stock_pred, est, covid_stock_pred, cumdeaths cumpatients);
%scatter(covid_stock_pred, ftse100_num, model13);
           
           
*2) Build linear regression model to predict FTSE_AS stock index;

****************************************************************
I have tried to use single variable and all the combinations of
varibales to build the regression models. Only the following ones
are significant and have relatively fine R^2 score.
****************************************************************

*Use cases and patients to build the model;
%regression(covid19_stock, 'COVID-19 Data and FTSE_AS',
            ftse_as_num, cases patients);
%prediction(covid19_stock, est, covid_stock_pred2, cases patients);
%scatter(covid_stock_pred2, ftse_as_num, model1);

*Use cumcases and cumpatients to build the model;
%regression(covid19_stock, 'COVID-19 Data and FTSE_AS',
            ftse_as_num, cumcases cumpatients);
%prediction(covid_stock_pred2, est, covid_stock_pred2, cumcases cumpatients);
%scatter(covid_stock_pred2, ftse_as_num, model12);

*Use cumdeaths and cumpatients to build the model;
%regression(covid19_stock, 'COVID-19 Data and FTSE_AS',
            ftse_as_num, cumdeaths cumpatients);
%prediction(covid_stock_pred2, est, covid_stock_pred2, cumdeaths cumpatients);
%scatter(covid_stock_pred2, ftse_as_num, model13); 




 




