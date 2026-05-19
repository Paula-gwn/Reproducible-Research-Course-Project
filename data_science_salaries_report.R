options(repos = c(CRAN = "https://cloud.r-project.org"))


## ----libraries--------------------------------------------------------------------------------------------------------------------------
required <- c("tidyverse", "fixest", "modelsummary", "scales")
to_install <- setdiff(required, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install)

library(tidyverse)
library(scales)
library(fixest)
library(modelsummary)


## ----load-data--------------------------------------------------------------------------------------------------------------------------
raw_data <- read_csv("data_clean.csv")
glimpse(raw_data)


## ----clean-data-------------------------------------------------------------------------------------------------------------------------
cleaned_data <- raw_data %>%
  drop_na() %>%
  filter(salary_in_usd > 0) %>%
  mutate(
    experience_level = factor(
      experience_level,
      levels = c("Entry-level", "Mid-level", "Senior-level", "Executive-level")
    ),
    company_size       = factor(company_size, levels = c("Small", "Medium", "Large")),
    work_year          = as.factor(work_year),
    employment_type    = as.factor(employment_type),
    work_models        = as.factor(work_models),
    company_location   = as.factor(company_location),
    employee_residence = as.factor(employee_residence),
    log_salary         = log(salary_in_usd),
    job_category = case_when(
      str_detect(job_title, "Data Scientist")      ~ "Data Science",
      str_detect(job_title, "Data Engineer")       ~ "Data Engineering",
      str_detect(job_title, "Analyst")             ~ "Data Analysis",
      str_detect(job_title, "Machine Learning|ML") ~ "Machine Learning",
      str_detect(job_title, "Manager|Lead|Head")   ~ "Management",
      TRUE                                          ~ "Other"
    )
  ) %>%
  select(-any_of(c("salary", "salary_currency")))

write_csv(cleaned_data, "data_clean.csv")
dim(cleaned_data)


## ----eda-experience---------------------------------------------------------------------------------------------------------------------
ggplot(cleaned_data, aes(x = experience_level, y = salary_in_usd, fill = experience_level)) +
  geom_boxplot(alpha = 0.7) +
  scale_y_continuous(labels = label_dollar()) +
  labs(title = "Does Experience Actually Pay Off?",
       subtitle = "Salary distribution across experience levels",
       x = "Level of Experience", y = "Salary (USD)") +
  theme_minimal() + theme(legend.position = "none")


## ----eda-distribution-------------------------------------------------------------------------------------------------------------------
ggplot(cleaned_data, aes(x = salary_in_usd)) +
  geom_histogram(fill = "#2d5a3f", color = "white", bins = 30) +
  scale_x_continuous(labels = label_dollar()) +
  labs(title = "The Spread of Data Science Salaries",
       subtitle = "Most salaries cluster between $100k and $200k",
       x = "Salary (USD)", y = "Number of Employees") +
  theme_minimal()


## ----eda-job-category-------------------------------------------------------------------------------------------------------------------
category_summary <- cleaned_data %>%
  group_by(job_category) %>%
  summarise(avg_salary = mean(salary_in_usd), .groups = "drop") %>%
  arrange(desc(avg_salary))

ggplot(category_summary,
       aes(x = reorder(job_category, avg_salary), y = avg_salary, fill = job_category)) +
  geom_col() + coord_flip() +
  scale_y_continuous(labels = label_dollar()) +
  labs(title = "Which Field Pays the Best?",
       x = "Job Category", y = "Average Salary (USD)") +
  theme_minimal() + theme(legend.position = "none")


## ----eda-remote-------------------------------------------------------------------------------------------------------------------------
ggplot(cleaned_data, aes(x = work_models, y = salary_in_usd, fill = work_models)) +
  geom_violin(trim = FALSE, alpha = 0.6) +
  geom_boxplot(width = 0.1, color = "black", outlier.shape = NA) +
  scale_y_continuous(labels = label_dollar()) +
  labs(title = "Remote vs. On-site: Is There a Pay Gap?",
       x = "Work Model", y = "Salary (USD)") +
  theme_minimal() + theme(legend.position = "none")


## ----eda-company-size-------------------------------------------------------------------------------------------------------------------
ggplot(cleaned_data, aes(x = company_size, y = salary_in_usd, fill = company_size)) +
  geom_boxplot() +
  scale_y_continuous(labels = label_dollar()) +
  labs(title = "Does Company Size Matter?",
       x = "Company Size", y = "Salary (USD)") +
  theme_minimal() + theme(legend.position = "none")


## ----eda-geo----------------------------------------------------------------------------------------------------------------------------
geo_summary <- cleaned_data %>%
  group_by(company_location) %>%
  filter(n() > 10) %>%
  summarise(avg_salary = mean(salary_in_usd), .groups = "drop") %>%
  arrange(desc(avg_salary)) %>%
  slice_head(n = 10)

ggplot(geo_summary, aes(x = reorder(company_location, avg_salary), y = avg_salary)) +
  geom_col(fill = "#5a8a6e") + coord_flip() +
  scale_y_continuous(labels = label_dollar()) +
  labs(title = "Top 10 Locations with Highest Average Salaries",
       subtitle = "Only countries with more than 10 reported roles included",
       x = "Country", y = "Average Salary (USD)") +
  theme_minimal()


## ---------------------------------------------------------------------------------------------------------------------------------------
model1 <- feols(
  log_salary ~
    experience_level +
    work_models +
    company_size +
    work_year |
    company_location,
  
  data = cleaned_data,
  
  vcov = "hetero"
)
summary(model1)


## ---------------------------------------------------------------------------------------------------------------------------------------
cleaned_data_fulltime <- cleaned_data %>%
  filter(employment_type == "Full-time")

model2 <- feols(
  log_salary ~
    experience_level +
    work_models +
    company_size +
    work_year |
    company_location,
  
  data = cleaned_data_fulltime,
  
  vcov = "hetero"
)
summary(model2)


## ---------------------------------------------------------------------------------------------------------------------------------------
model3 <- feols(
  log_salary ~
    experience_level +
    work_models +
    company_size +
    work_year |
    employee_residence,
  
  data = cleaned_data,
  
  vcov = "hetero"
)
summary(model3)


## ----robust-trimmed---------------------------------------------------------------------------------------------------------------------
salary_cutoff <- quantile(cleaned_data$salary_in_usd, 0.99)

cleaned_data_trimmed <- cleaned_data %>%
  filter(salary_in_usd < salary_cutoff)

model4 <- feols(
  log_salary ~
    experience_level +
    work_models +
    company_size +
    work_year |
    company_location,
  
  data = cleaned_data_trimmed,
  
  vcov = "hetero"
)
summary(model4)


## ----robust-interaction-----------------------------------------------------------------------------------------------------------------
model5 <- feols(
  log_salary ~
    experience_level * work_models +
    company_size +
    work_year |
    company_location,
  
  data = cleaned_data,
  
  vcov = "hetero"
)
summary(model5)


## ----results-table----------------------------------------------------------------------------------------------------------------------
modelsummary(
  list(
    "Main Model"     = model1,
    "Full-Time Only" = model2,
    "Residence FE"   = model3,
    "Trimmed Sample" = model4,
    "Remote x Exp."  = model5
  ),
  stars  = TRUE,
  output = "markdown"
)


## ----session-info-----------------------------------------------------------------------------------------------------------------------
sessionInfo()

