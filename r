# Ari Lin: Project 2 ------------------------------------------------------
# May 6, 2025

# Library Statement -------------------------------------------------------
library(haven)
library(dplyr)
library(gtsummary)
library(ggplot2)
library(knitr)
library(tidyverse)

# Read in data ------------------------------------------------------------
demo <- read_xpt("datasets/P_DEMO.xpt")
bmx  <- read_xpt("datasets/P_BMX.xpt")
bpxo <- read_xpt("datasets/P_BPXO.xpt")
diq  <- read_xpt("datasets/P_DIQ.xpt")
chol <- read_xpt("datasets/P_TRIGLY.xpt")  

# Create Analysis Dataset -------------------------------------------------
merged <- left_join(bmx, demo, by = "SEQN") %>%
  left_join(diq, by = "SEQN") %>%
  left_join(chol, by = "SEQN") %>%
  left_join(bpxo, by = "SEQN")

analysis <- merged %>%
  mutate(
    Gender = factor(RIAGENDR, levels = c(1,2), labels = c("Male", "Female")),
    Education.Level = factor(DMDEDUC2, levels = 1:5, labels = c("Less than 9th grade",
                                                                "9–11th grade",
                                                                "High school graduate",
                                                                "Some college/AA",
                                                                "College graduate or above")),
    Marital.Status = factor(DMDMARTZ, levels = 1:3, labels = c("Married/Living with Partner",
                                                               "Widowed/Divorced/Separated",
                                                               "Never married")),
    Race = factor(RIDRETH3, levels = c(1,2,3,4,6,7),
                  labels = c("Mexican American", "Other Hispanic", "Non-Hispanic White",
                             "Non-Hispanic Black", "Non-Hispanic Asian", "Other/Multi-Racial")),
    Taking.Insulin = factor(DIQ050, levels = c(1,2), labels = c("Yes", "No")),
    Systolic.BP = rowMeans(select(., BPXOSY1, BPXOSY2, BPXOSY3), na.rm = TRUE),
    Diastolic.BP = rowMeans(select(., BPXODI1, BPXODI2, BPXODI3), na.rm = TRUE)
  ) 

# Summary Statistics: Continuous ------------------------------------------
summary_by_gender <- analysis %>%
  group_by(Gender) %>%
  summarise(
    Age_Mean = mean(RIDAGEYR, na.rm = TRUE),
    Age_SD = sd(RIDAGEYR, na.rm = TRUE),
    BMI_Mean = mean(BMXBMI, na.rm = TRUE),
    BMI_SD = sd(BMXBMI, na.rm = TRUE),
    SysBP_Mean = mean(Systolic.BP, na.rm = TRUE),
    SysBP_SD = sd(Systolic.BP, na.rm = TRUE),
    DiaBP_Mean = mean(Diastolic.BP, na.rm = TRUE),
    DiaBP_SD = sd(Diastolic.BP, na.rm = TRUE),
    Glucose_Mean = mean(DID040, na.rm = TRUE),
    Glucose_SD = sd(DID040, na.rm = TRUE),
    Trig_Mean = mean(LBXTR, na.rm = TRUE),
    Trig_SD = sd(LBXTR, na.rm = TRUE)
  )

summary_overall <- analysis %>%
  summarise(
    Age_Mean = mean(RIDAGEYR, na.rm = TRUE),
    Age_SD = sd(RIDAGEYR, na.rm = TRUE),
    BMI_Mean = mean(BMXBMI, na.rm = TRUE),
    BMI_SD = sd(BMXBMI, na.rm = TRUE),
    SysBP_Mean = mean(Systolic.BP, na.rm = TRUE),
    SysBP_SD = sd(Systolic.BP, na.rm = TRUE),
    DiaBP_Mean = mean(Diastolic.BP, na.rm = TRUE),
    DiaBP_SD = sd(Diastolic.BP, na.rm = TRUE),
    Glucose_Mean = mean(DID040, na.rm = TRUE),
    Glucose_SD = sd(DID040, na.rm = TRUE),
    Trig_Mean = mean(LBXTR, na.rm = TRUE),
    Trig_SD = sd(LBXTR, na.rm = TRUE)
  )

# Summary Statistics: Categorical (example: insulin only) -----------------
insulin_by_gender <- analysis %>%
  group_by(Gender, Taking.Insulin) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(Gender) %>%
  mutate(percent = 100 * n / sum(n))

# Answer Key Questions ----------------------------------------------------
# 1.What proportion of participants are male? What proportion are female?
# Ans: Male: 7085 participants (49.55%); Female: 7215 participants (50.45%)
gender_prop <- analysis %>%
  count(Gender) %>%
  mutate(percent = round(100 * n / sum(n), 2))

# 2.How many observations are in the final dataset? How do you know?
# Ans: The final dataset contains 14300 observations
# This number was obtained by using nrow(analysis) after all datasets were merged
n_total <- nrow(analysis)

# 3.What is the average age for males who were never married?
# Ans: The average age for males who were never married is 36.48 years
avg_age_never_married_males <- analysis %>%
  filter(Gender == "Male", Marital.Status == "Never married") %>%
  summarise(avg_age = mean(RIDAGEYR, na.rm = TRUE))

# 4.What is the average BMI for males?
#Ans: The average BMI for males is 26.07 kg/m²
avg_bmi_males <- analysis %>%
  filter(Gender == "Male") %>%
  summarise(avg_bmi = mean(BMXBMI, na.rm = TRUE))

# Table: Demographic Summary ----------------------------------------------
t_demo <- tbl_summary(
  analysis,
  by = Gender,
  include = c(RIDAGEYR, Race, Marital.Status, Education.Level, Systolic.BP, Diastolic.BP, DID040, Taking.Insulin, LBXTR),
  statistic = list(all_continuous() ~ "{mean} ({sd})",
                   all_categorical() ~ "{n} ({p}%)")
) %>%
  add_overall(last = TRUE)

# Print the summary table
t_demo

# Export to Excel ---------------------------------------------------------
gtsummary::as_hux_xlsx(t_demo, file = "outputs/Table_Ari.xlsx")


# Create 2 plots comparing at least 3 variables  --------------------------
# Plot 1: Age vs. BMI by Gender -------------------------------------------
p1 <- analysis %>%
  ggplot(aes(x = RIDAGEYR, y = BMXBMI, color = Gender)) +
  geom_point(alpha = 0.4) +
  labs(title = "Age vs BMI by Gender", x = "Age", y = "BMI")
ggsave("outputs/plot1_age_bmi.png", p1)

# Plot 2: Triglycerides vs. Systolic BP by Education ----------------------
p2 <- analysis %>%
  ggplot(aes(x = Systolic.BP , y = LBXTR, color = Education.Level)) +
  geom_point(alpha = 0.4) +
  labs(title = "Triglycerides vs. Systolic BP by Education", x = "Systolic BP", y = "Triglycerides")
ggsave("outputs/plot2_trigly_sbp.png", p2)
