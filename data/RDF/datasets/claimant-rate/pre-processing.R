# Measure: Claimant count by sex and age: Claimants as a proportion of residents aged 16-64
# Source: https://www.nomisweb.co.uk/datasets/ucjsa
# Geography: Electoral Ward, Local Authority District, Combined Authority
# Period: latest 36 months

library(tidyverse)

read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=E05000650...E05000864,E08000001...E08000010,E47000001&date=latestMINUS36-latest&gender=0&age=0&measure=2&measures=20100&select=date_name,geography_name,geography_code,measure_name,obs_value") %>% 
  mutate(Date = as.Date(paste('01', DATE_NAME), format = '%d %B %Y'),
         Date = format(as.Date(Date), "%Y-%m"),
         `Measure Type` = "percent",
         Unit = "persons") %>% 
  select(Date,
         Geography = GEOGRAPHY_CODE, 
         `Measure Type`, 
         Unit,
         Value = OBS_VALUE) %>% 
  write_csv("csv/input.csv")
