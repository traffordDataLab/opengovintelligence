library(tidyverse)

# Measure: LC5601EW - Highest level of qualification by economic activity
# Source: https://www.nomisweb.co.uk/census/2011/lc5601ew
# Geography: Lower-layer Super Output Area
# Period: 27 March 2011

read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1043_1.data.csv?geography=TYPE298&c_hlqpuk11=1&c_ecopuk11=0&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', GEOGRAPHY_NAME)) %>% 
  mutate(`Measure Type` = "count",
       Unit = "persons") %>% 
  select(Geography = GEOGRAPHY_CODE, 
         `Measure Type`, 
         Unit,
         Value = OBS_VALUE) %>%
  write_csv("csv/input.csv")