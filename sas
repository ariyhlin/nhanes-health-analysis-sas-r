************************************************************ 
* Ari Lin                  
* Project 1                    
* Mar 4, 2025                                             
* SAS 9.4                                         
*                                                           
* Merging and analyzing NHANES data 	
************************************************************; 

/* Define NHANES XPT libraries */
libname demo xport "/home/u64141843/SP2025/P_DEMO.xpt";
libname bmx xport "/home/u64141843/SP2025/P_BMX.xpt";
libname bpxo xport "/home/u64141843/SP2025/P_BPXO.xpt";
libname diq xport "/home/u64141843/SP2025/P_DIQ.xpt";
libname chol xport "/home/u64141843/SP2025/P_TRIGLY.xpt";

/* Define formats */
proc format;
    value gendr 1 = "Male"
                2 = "Female"
                other = "Not Collected/Misclassified";
                
    value edu                
        1 = 'Less than 9th grade'
        2 = '9-11th grade (Includes 12th grade with no diploma)'
        3 = 'High school graduate/GED or equivalent'
        4 = 'Some college or AA degree'
        5 = 'College graduate or above'
        other = 'Not Collected/Misclassified';

    value mar
        1 = 'Married/Living with Partner'
        2 = 'Widowed/Divorced/Separated'
        3 = 'Never married'
        other = 'Not Collected/Misclassified';

    value race
        1 = 'Mexican American'
        2 = 'Other Hispanic'
        3 = 'Non-Hispanic White'
        4 = 'Non-Hispanic Black'
        6 = 'Non-Hispanic Asian'
        7 = 'Other Race - Including Multi-Racial'
        other = 'Not Collected/Misclassified';

    value insulin_fmt
        1 = "Yes"
        2 = "No"
        other = "Not Collected/Misclassified";
run;

/* Sort datasets for merging */
proc sort data=demo.p_demo out=demog; by SEQN; run;
proc sort data=bmx.p_bmx out=bm; by SEQN; run;
proc sort data=bpxo.p_bpxo out=bp; by SEQN; run;
proc sort data=diq.p_diq out=diab; by SEQN; run;
proc sort data=chol.p_trigly out=chol; by SEQN; run;

/* Merge datasets (Only keep records found in all datasets) */
data merged;
    merge demog (in=a) 
          bm (in=b) 
          bp (in=c) 
          diab (in=d) 
          chol (in=e);
    by SEQN;
    if a and b and c and d and e;
    format RIAGENDR gendr. RIDRETH3 race. DMDEDUC2 edu. DMDMARTZ mar. DIQ050 insulin_fmt.;
run;

/* Create filtered dataset for analysis */
data analysis;
    set merged;
    where RIAGENDR in (1, 2) and DMDEDUC2 in (1, 2, 3, 4, 5) 
          and DMDMARTZ in (1, 2, 3) and RIDRETH3 in (1, 2, 3, 4, 6, 7);
run;

/* Compute derived variables */
data analysis;
    set analysis;
    length gendr $50 edu $50 mar $50 race $50 insulin_fmt $50; 
    gendr = put(RIAGENDR, gendr.);
    edu = put(DMDEDUC2, edu.);
    mar = put(DMDMARTZ, mar.);
    race = put(RIDRETH3, race.);
    insulin_fmt = put(DIQ050, insulin_fmt.);

    /* Compute Average Systolic and Diastolic BP */
    systolic_bp_avg = mean(of BPXOSY1 BPXOSY2 BPXOSY3);
    diastolic_bp_avg = mean(of BPXODI1 BPXODI2 BPXODI3);
run;

/* Generate Summary Table */

/* Continuous Variables: Mean and SD by Category Including Overall */
proc means data=analysis mean std;
    class gendr;
    var RIDAGEYR BMXBMI systolic_bp_avg diastolic_bp_avg DID040 LBXTR;
    output out=continuous_stats mean=mean_value std=sd_value;
run;

/* Overall Statistics */
proc means data=analysis mean std;
    var RIDAGEYR BMXBMI systolic_bp_avg diastolic_bp_avg DID040 LBXTR;
    output out=overall_stats mean=overall_mean std=overall_sd;
run;


/* Categorical Variables: Frequency and Percent Including Male, Female, and Overall */
proc freq data=analysis;
    tables gendr*RIDRETH3 gendr*DMDMARTZ gendr*DMDEDUC2 gendr*insulin_fmt / out=categorical_stats;
    format RIDRETH3 race. DMDMARTZ mar. DMDEDUC2 edu.  DIQ050 insulin_fmt.;
run;

/* Overall Categorical Statistics */
proc freq data=analysis;
    tables RIDRETH3 DMDMARTZ DMDEDUC2 insulin_fmt / out=overall_categorical_stats;
    format RIDRETH3 race. DMDMARTZ mar. DMDEDUC2 edu. DIQ050 insulin_fmt.;
run;


/* Taking Insulin: Frequency and Percent (Only those taking insulin) */
proc freq data=analysis;
    tables DIQ050 / out=insulin_stats;
    where DIQ050 = 1;
    format DIQ050 insulin_fmt.;
run;

/* Answer Key Questions */

/* 1. Proportion of Participants Male vs. Female */
proc freq data=analysis;
    tables RIAGENDR / out=gender_freq;
run;
proc print data=gender_freq; run;

/* 2. Total Number of Observations in the Final Dataset */
proc sql;
    select count(*) as Total_Observations from analysis;
quit;

/* 3. Average Age for Males */
proc means data=analysis mean;
    where RIAGENDR = 1;
    var RIDAGEYR;
run;

/* 4. Average BMI for Females */
proc means data=analysis mean;
    where RIAGENDR = 2;
    var BMXBMI;
run;

