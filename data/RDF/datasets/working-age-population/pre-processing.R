# Measure: Mid-year population estimates for working age residents (16-64 years)
# Source: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/wardlevelmidyearpopulationestimatesexperimental
# Geography: Electoral Ward, Local Authority District and Combined Authority
# Period: 2017

library(tidyverse) ; library(readxl)

codelist <- read_csv("https://github.com/traffordDataLab/spatial_data/raw/master/lookups/codelist.csv") %>% 
  filter(area_type == "Electoral Wards") %>% 
  pull(area_code)

url <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/wardlevelmidyearpopulationestimatesexperimental/mid2017sape20dt8/sape20dt8mid2017ward2017syoaestimatesunformatted1.zip"
download.file(url, dest = "sape20dt8mid2017ward2017syoaestimatesunformatted1.zip")
unzip("sape20dt8mid2017ward2017syoaestimatesunformatted1.zip", exdir = ".")
file.remove("sape20dt8mid2017ward2017syoaestimatesunformatted1.zip")

ward <- read_excel("SAPE20DT8-mid-2017-ward-2017-syoa-estimates-unformatted.xls", sheet = 4, skip = 3) %>% 
  filter(`Ward Code 1` %in% codelist) %>% 
  mutate(`Measure Type` = "count",
         Unit = "persons",
         Value = rowSums(select(.,`16`:`64`))) %>% 
  select(Geography = `Ward Code 1`,
         `Measure Type`,
         Unit,
         Value)

la <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=1879048217...1879048226&date=latest&gender=0&c_age=203&measures=20100&select=date_name,geography_name,geography_code,obs_value") %>% 
  mutate(`Measure Type` = "count",
         Unit = "persons") %>% 
  select(Geography = GEOGRAPHY_CODE,
         `Measure Type`,
         Unit,
         Value = OBS_VALUE)

ca <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=1853882369&date=latest&gender=0&c_age=203&measures=20100&select=date_name,geography_name,geography_code,obs_value") %>% 
  mutate(`Measure Type` = "count",
         Unit = "persons") %>% 
  select(Geography = GEOGRAPHY_CODE,
         `Measure Type`,
         Unit,
         Value = OBS_VALUE)

bind_rows(ward, la, ca) %>% 
  write_csv("csv/input.csv")
