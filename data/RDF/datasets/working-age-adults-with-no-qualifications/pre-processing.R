# Measure: LC5601EW - Highest level of qualification by economic activity
# Source: https://www.nomisweb.co.uk/census/2011/lc5601ew
# Geography: Lower-layer Super Output Area, Electoral Ward and Local Authority District, Combined Authority
# Period: 27 March 2011

library(tidyverse)

codelist <- read_csv("https://github.com/traffordDataLab/spatial_data/raw/master/lookups/codelist.csv") %>% 
  filter(area_type %in% c("Lower Layer Super Output Areas", "Electoral Wards", "Local Authority Districts", "Combined Authority")) %>% 
  pull(area_code)

lsoa <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1043_1.data.csv?geography=TYPE298&c_hlqpuk11=1&c_ecopuk11=0&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(GEOGRAPHY_CODE %in% codelist)

ward <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1043_1.data.csv?geography=TYPE295&c_hlqpuk11=1&c_ecopuk11=0&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(GEOGRAPHY_CODE %in% codelist)

la <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1043_1.data.csv?geography=TYPE464&c_hlqpuk11=1&c_ecopuk11=0&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(GEOGRAPHY_CODE %in% codelist) %>% 
  add_row(GEOGRAPHY_NAME = "Greater Manchester",
          GEOGRAPHY_CODE = "E47000001",
          CELL_NAME = NA,
          OBS_VALUE = sum(.$OBS_VALUE))

bind_rows(lsoa, ward, la) %>% 
  mutate(`Measure Type` = "count",
         Unit = "persons") %>% 
  select(Geography = GEOGRAPHY_CODE,
         `Measure Type`,
         Unit,
         Value = OBS_VALUE) %>% 
  write_csv("csv/input.csv")
