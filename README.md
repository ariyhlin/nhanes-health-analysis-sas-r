# NHANES Health Data Analysis (SAS & R)

## 📌 Project Overview

This project analyzes health-related outcomes using NHANES data, focusing on demographic characteristics, BMI, blood pressure, and diabetes-related variables. The goal is to demonstrate data cleaning, dataset merging, and descriptive statistical analysis using both SAS and R.



## 🧾 Data Source

* National Health and Nutrition Examination Survey (NHANES)
* Publicly available datasets:

  * Demographics (DEMO)
  * Body Measures (BMX)
  * Blood Pressure (BPXO)
  * Diabetes Questionnaire (DIQ)
  * Triglycerides (TRIGLY)



## 🧠 Methods

### Data Processing

* Imported XPT datasets into SAS
* Sorted and merged datasets using SEQN (unique participant ID)
* Constructed an analysis dataset after applying inclusion criteria

### Key Steps

* Multi-dataset merging using SAS `DATA` step
* Data filtering based on demographic variables
* Creation of derived variables:

  * Average systolic blood pressure
  * Average diastolic blood pressure

### Statistical Analysis

* Continuous variables:

  * Mean and standard deviation using `PROC MEANS`
* Categorical variables:

  * Frequency and percentages using `PROC FREQ`



## 📊 Key Results

* Total observations: 4,245
* Male: 47.99%
* Female: 52.01%
* Average age (male): 51.47 years
* Average BMI (female): 30.74 kg/m²

---

## 🛠 Tools & Technologies

* SAS (data cleaning, merging, statistical analysis)
* R (data manipulation and summary analysis)
* Healthcare data analytics concepts



## 📁 Repository Structure


nhanes-health-analysis-sas-r/
├── sas/
├── r/
├── summary/



## ⚠️ Note

This project uses publicly available NHANES data for educational and demonstration purposes only.



## 👤 Author

Ari Lin
HEOR / RWE Analyst
