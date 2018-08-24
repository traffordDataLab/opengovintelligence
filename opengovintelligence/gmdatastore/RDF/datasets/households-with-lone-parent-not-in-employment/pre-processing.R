library(tidyverse)

# Measure: KS107EW - Lone parent households with dependent children
# Source: https://www.nomisweb.co.uk/census/2011/KS107EW
# Geography: Lower-layer Super Output Area
# Period: 27 March 2011

read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_607_1.data.csv?geography=TYPE298&rural_urban=0&cell=3&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', GEOGRAPHY_NAME)) %>% 
  mutate(`Measure Type` = "count",
         Unit = "households") %>% 
  select(Geography = GEOGRAPHY_CODE, 
         `Measure Type`, 
         Unit,
         Value = OBS_VALUE) %>% 
  write_csv("csv/input.csv")
