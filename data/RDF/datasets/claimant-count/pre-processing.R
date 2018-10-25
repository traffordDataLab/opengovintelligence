# Measure: Claimant count by sex and age: Claimant count
# Source: https://www.nomisweb.co.uk/datasets/ucjsa
# Geography: Lower-layer Super Output Area
# Period: latest month

library(tidyverse)

read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=TYPE298&date=latest&gender=0&age=0&measure=1&measures=20100&select=date_name,geography_name,geography_code,measure_name,obs_value") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', GEOGRAPHY_NAME)) %>% 
  mutate(Date = as.Date(paste('01', DATE_NAME), format = '%d %B %Y'),
         Date = format(as.Date(Date), "%Y-%m"),
         `Measure Type` = "count",
         Unit = "persons") %>% 
  select(Date,
         Geography = GEOGRAPHY_CODE, 
         `Measure Type`,
         Unit,
         Value = OBS_VALUE) %>% 
  write_csv("csv/input.csv")
