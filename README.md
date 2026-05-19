**Project title:** Data Science Salaries 2023/2024  

**Group members:** Dilara Ozdil, Eljan Abbaszada, Paula Gwanchele  

**Research question:** How do variables such as experience level, remote work status, job title, and geographic location impact salaries.  

**Data Source** Kaggle (https://www.kaggle.com/datasets/sazidthe1/data-science-salaries)  

**Project that Will Be Reproduced** (https://www.kaggle.com/code/analyticaobscura/ds-salary-2024)

**Planned approach:** The dataset is first cleaned and preprocessed to ensure consistency and accuracy, focusing on standardizing salary values, categorizing experience levels, and refining job titles.  
A regression analysis is then conducted using log-transformed salary as the dependent variable, with relevant dummy variables included to capture categorical effects. Finally, the results are visualized through an interactive dashboard and plots, providing clear insights and interpretations of the findings.   

**Language / tools:** Python  

**Motivation:** This project analyzes the Data Science Salaries 2023/2024 dataset to understand the key factors that influence salary levels in data-related roles.

**Usage**

Run the following commands in your terminal:



1. Clone repository

git clone https://github.com/claradilara/Reprodicable-Research-Course-Project

2. Enter repository

cd Reprodicable-Research-Course-Project

3. Check R version

dir "C:\Program Files\R"

4. Open R

& "C:\Program Files\R\R-4.6.0\bin\R.exe"

5. Inside R install packages

options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages(c(
"tidyverse",
"fixest",
"modelsummary",
"scales",
"stringi",
"stringr",
"ggplot2"
))

6. Quit R

q()
n

7. Run script

& "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" "data_science_salaries_report.R"


**How to test the project**

After you got the files, you can open the data_science_salaries_report.R to run the program. You will need Rstudio and the following libraries; "tidyverse", "fixest", "modelsummary", "scales" to run it. Libraries can be installed.

If you want to get a ready page with all results and pieces of code, then open the data_science_salaries_report.html using an internet browser, like Google Chrome or Mozilla Firefox or etc. 
