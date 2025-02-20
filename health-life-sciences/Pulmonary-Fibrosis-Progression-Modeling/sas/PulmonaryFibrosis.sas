*****************************************************************************;
**                                                                         **;
**                Modeling Pulmonary Fibrosis Progression                  **;
**                                                                         **;
*****************************************************************************;
**                                                                         **;
**  The scenario for this demo is as follows:                              **;
**  Imagine a patient is diagnosed with pulmonary fibrosis,                **;
**  a disorder with no known cause and no known cure, that can             **;
**  range from long-term stability to rapid deterioration.                 **;
**  Currently, doctors aren’t easily able to tell where an                 **;
**  individual may fall on that spectrum but by using machine              **;
**  learning we may be able to aid in this prediction.                     **;
**                                                                         **;
**  This notebook aims to predict a patient’s severity of lung             **;
**  function decline based on an initial baseline reading. Our             **;
**  target variable, lung function, is assessed based on output            **;
**  from a spirometer, which measures the forced vital capacity            **;
**  (FVC). The results consist of three predictions per patient            **;
**  accompanied by a confidence score for each.                            **;            
**                                                                         **;
**                                                                         **;
*****************************************************************************;

*****************************************************************************;
**                                                                         **;
**                   Step 1: Import and Visualize Data                     **;
**                                                                         **;
*****************************************************************************;

/* Setup library and import data */

**options nonotes nosource;

/* Define macro variable for generic file path */
/*** NOTE : Adjust macro based upon your WB naming conventions ***/
%let FilePath=/workspaces/workbench/Pulmonary-Fibrosis-Progression/data;

/* Initiate new library */
libname PF "&FilePath";
run;

/* Load Patient Data */
proc import datafile="&FilePath/train.csv"
			dbms=csv
			out=PF.PATIENT
			replace;
			guessingrows=max;
			getnames=yes;
run;

/* Visualize patient data */
/* Summary Statistics */

ods proctitle;

title "Summary Statistics of Patient Data";
ods noproctitle;
proc means data=PF.PATIENT n nmiss mean min max std;
  ods exclude sortinfo;
run;

title "First 10 Rows of Patient Data";
proc print data=PF.PATIENT(obs=10);
run; 
title;

/* FVC Distribution */
proc sgplot data=PF.PATIENT noautolegend;
  title "FVC Distribution in Patient Data";
  histogram FVC;
  density FVC;
run;

/* Percent Distribution */
proc sgplot data=PF.PATIENT noautolegend;
  title "Percent Distribution in Patient Data";
  histogram Percent;
  density Percent;
run;

/* Scatterplot Matrix */
proc sgscatter data=PF.PATIENT;
  title "Scatterplot Matrix for Patient Data";
  compare x=(FVC)
          y=(Age Percent Weeks)
         / group=Sex filledoutlinedmarkers
        markerattrs=(symbol=circlefilled size=5);
run;

/* Highlight FVC of Unique Patient */
proc sgplot data=PF.PATIENT;
    where Patient = "ID00020637202178344345685";
    series x=Weeks y=FVC;
    scatter x=Weeks y=FVC /  markerattrs=(symbol=circlefilled size=10);
    xaxis label="Weeks";
    yaxis label="FVC";
    title "FVC Decrease Over Weeks for Patient: ID00020637202178344345685";
run;
title;
/*********************/

*****************************************************************************;
**                                                                         **;
**                         Step 2: Preprocessing                           **;
**                                                                         **;
*****************************************************************************;

/* Encoding + variable creation for training & testing data */
data PF.PATIENT_CLEAN;
    set PF.PATIENT;
    by Patient Weeks;

    retain Patient Sex_Num SmokingStatus_Num Weeks Patient_Week Baseline_Week Baseline_FVC Baseline_Percent Percent;

    if first.Patient then Baseline_Week = Weeks;
    if first.Patient then Baseline_FVC = FVC;
    if first.Patient then Baseline_Percent = Percent;

    Weeks_Passed = Weeks - Baseline_Week;

    Patient_Week = catx('_', Patient, Weeks);

    /* Encode Sex */
    if Sex = "Male" then Sex_Num = 1;
    else if Sex = "Female" then Sex_Num = 0;

    /* Encode SmokingStatus */
    if SmokingStatus = "Never smoked" then SmokingStatus_Num = 0;
    else if SmokingStatus = "Ex-smoker" then SmokingStatus_Num = 1;
    else if SmokingStatus = "Currently smokes" then SmokingStatus_Num = 2;

    if first.Patient then delete;
    drop Sex SmokingStatus;
run;
/*********************/

/* Cartesian join of patient data (for extra training data) */
proc sql;
    create table PF.PATIENT_CARTESIAN as
    select
        A.Patient,
        A.Patient_Week as Baseline_Patient_Week,
        A.Weeks as Baseline_Week,
        A.FVC as Baseline_FVC,
        A.Percent as Baseline_Percent,
        B.Patient_Week as Patient_Week,
        B.Weeks as Predict_Week,
        B.FVC as Predict_FVC,
        B.Percent as Predict_Percent,
        B.Age,
        A.Sex_Num,
        A.SmokingStatus_Num,
        (B.Weeks - A.Weeks) as Weeks_Passed
    from 
        PF.PATIENT_CLEAN as A
    inner join 
        PF.PATIENT_CLEAN as B
    on 
        A.Patient = B.Patient
    where 
        A.Weeks ne B.Weeks
    ORDER by
        B.Patient_Week;
quit;

data PF.PATIENT_CARTESIAN;
    retain Patient_Week Patient Predict_Week Predict_Patient_Week Baseline_Week Baseline_FVC Baseline_Percent Age Sex_Num SmokingStatus_Num Weeks_Passed Predict_FVC;
    set PF.PATIENT_CARTESIAN;
    by Patient_Week;
    if first.Patient_Week;
    drop Baseline_Patient_Week Predict_Percent;
run;

/* Check for missing values and then impute with mean */
proc means data=PF.PATIENT_CARTESIAN n nmiss;
run;

proc stdize data=PF.PATIENT_CARTESIAN out=PF.PATIENT_CARTESIAN reponly method=mean;
    var _numeric_;
run;

/* */
proc print data=PF.PATIENT_CARTESIAN(obs=10);
run;

proc partition data=PF.PATIENT_CARTESIAN seed=12345
    partind samppct=80;
    output out=PF.PATIENT_CARTESIAN_PART;
run;

data PF.PATIENT_TRAIN(drop=_partind_);
    set PF.PATIENT_CARTESIAN_PART(where=(_partind_=1));
run;

data PF.PATIENT_TEST(drop=_partind_);
    set PF.PATIENT_CARTESIAN_PART(where=(_partind_~=1));
run;

data PF.PATIENT_TEST_BLIND;
    set PF.PATIENT_TEST;
    drop Predict_FVC;
run;
/*********************/

*****************************************************************************;
**                                                                         **;
**                   Step 3: Build Model and Score Data                    **;
**                                                                         **;
*****************************************************************************;

/* Train a LightGBM model to predict FVC */
proc lightgradboost data=PF.PATIENT_TRAIN seed=12345
   boosting=GBDT objective=regression deterministic;
   input Baseline_FVC Baseline_Percent Age Weeks_Passed Predict_Week / level=interval;
   input Sex_Num SmokingStatus_Num / level=nominal;
   target Predict_FVC / level=interval;
   SAVESTATE RSTORE=PF.lgbmStore; 
   output out=PF.lgbm_train_output; 
   ods output ModelInfo=ModelInfo_FVC;
run;

/* Score the test data using the saved LightGBM model */
proc astore;
   score data=PF.PATIENT_TEST_BLIND out=PF.TEST_PREDICTIONS rstore=PF.lgbmStore;
run;
/*********************/

data PF.PATIENT_TEST;
   set PF.PATIENT_TEST;
   Obs = _N_; 
run;

data PF.TEST_PREDICTIONS;
   set PF.TEST_PREDICTIONS;
   Obs = _N_;
run;

data PF.TEST_COMPARISON;
   merge PF.PATIENT_TEST(in=a) PF.TEST_PREDICTIONS(in=b);
   Error = Predict_FVC - P_Predict_FVC; 
   Absolute_Error = abs(Error);        
   Percentage_Error = (Error / Predict_FVC) ; 
   format Percentage_Error percent10.2;
   rename Predict_FVC=Actual_FVC P_Predict_FVC=Predicted_FVC;
   by Obs;
   drop Obs Patient Predict_Week Baseline_Week Baseline_Percent Age Sex_Num SmokingStatus_Num Weeks_Passed;
run;

proc means data=PF.TEST_COMPARISON mean median std min max;
   var Error Absolute_Error Percentage_Error;
   title "Error Metrics Summary";
run;

proc print data=PF.TEST_COMPARISON(obs=5);
run;

proc univariate data=PF.TEST_COMPARISON normal;
   var Error;
   histogram Error / normal;
   qqplot Error / normal(mu=est sigma=est);
   title "Residual Analysis";
run;

/* Export scoring data */ 
proc export data=PF.TEST_COMPARISON         
     outfile="&FilePath/Scoring.csv"   
     dbms=csv                                   
     replace;                                     
run;

proc datasets library=PF;
   save lgbmstore;
run;
/*********************/

