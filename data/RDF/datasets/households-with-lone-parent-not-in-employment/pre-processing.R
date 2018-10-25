# Measure: KS107EW - Lone parent households with dependent children
# Source: https://www.nomisweb.co.uk/census/2011/KS107EW
# Geography: Lower-layer Super Output Area, Electoral Ward and Local Authority District, Combined Authority
# Period: 27 March 2011

library(tidyverse)

codelist <- read_csv("https://github.com/traffordDataLab/spatial_data/raw/master/lookups/codelist.csv") %>% 
  filter(area_type %in% c("Lower Layer Super Output Areas", "Electoral Wards", "Local Authority Districts", "Combined Authority")) %>% 
  pull(area_code)

lsoa <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_607_1.data.csv?geography=TYPE298&rural_urban=0&cell=3&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(GEOGRAPHY_CODE %in% codelist)

ward <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_607_1.data.csv?geography=TYPE295&rural_urban=0&cell=3&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(GEOGRAPHY_CODE %in% codelist)

la <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_607_1.data.csv?geography=TYPE464&rural_urban=0&cell=3&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(GEOGRAPHY_CODE %in% codelist) %>% 
  add_row(GEOGRAPHY_NAME = "Greater Manchester",
          GEOGRAPHY_CODE = "E47000001",
          CELL_NAME = "Lone parent not in employment: Total",
          OBS_VALUE = sum(.$OBS_VALUE))

bind_rows(lsoa, ward, la) %>% 
  mutate(`Measure Type` = "count",
         Unit = "households") %>% 
  select(Geography = GEOGRAPHY_CODE,
         `Measure Type`,
         Unit,
         Value = OBS_VALUE) %>% 
  write_csv("csv/input.csv")
