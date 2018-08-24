library(tidyverse)

read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=E47000001,E08000001...E08000010,E05000650...E05000864&date=latestMINUS36-latest&gender=0&age=0&measure=2&measures=20100&select=date_name,geography_name,geography_code,gender_name,age_name,measure_name,measures_name,obs_value,obs_status_name") %>% 
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
