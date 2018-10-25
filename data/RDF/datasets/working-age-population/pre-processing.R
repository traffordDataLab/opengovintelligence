# Measure: Mid-year population estimates for working age residents (16-64 years)
# Source: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/wardlevelmidyearpopulationestimatesexperimental
# Geography: Electoral Ward, Local Authority District and Combined Authority
# Period: 2016

library(tidyverse) ; library(readxl)

codelist <- read_csv("https://github.com/traffordDataLab/spatial_data/raw/master/lookups/codelist.csv") %>% 
  filter(area_type == "Electoral Wards") %>% 
  pull(area_code)

url <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/wardlevelmidyearpopulationestimatesexperimental/mid2016sape19dt8/sape19dt8mid2016ward2016syoaestimatesunformatted.zip"
download.file(url, dest = "sape19dt8mid2016ward2016syoaestimatesunformatted.zip")
unzip("sape19dt8mid2016ward2016syoaestimatesunformatted.zip", exdir = ".")
file.remove("sape19dt8mid2016ward2016syoaestimatesunformatted.zip")

ward <- read_excel("SAPE19DT8-mid-2016-ward-2016-syoa-estimates-unformatted.xls", sheet = 2, skip = 3) %>% 
  filter(`Ward Code 1` %in% codelist) %>% 
  mutate(`Measure Type` = "count",
         Unit = "persons",
         Value = rowSums(select(.,`16`:`64`))) %>% 
  select(Geography = `Ward Code 1`,
         `Measure Type`,
         Unit,
         Value)

la <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=1879048217...1879048226&date=latestMINUS1&gender=0&c_age=203&measures=20100&select=date_name,geography_name,geography_code,obs_value") %>% 
  mutate(`Measure Type` = "count",
         Unit = "persons") %>% 
  select(Geography = GEOGRAPHY_CODE,
         `Measure Type`,
         Unit,
         Value = OBS_VALUE)

ca <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=E47000001&date=latestMINUS1&gender=0&c_age=203&measures=20100&select=date_name,geography_name,geography_code,obs_value") %>% 
  mutate(`Measure Type` = "count",
         Unit = "persons") %>% 
  select(Geography = GEOGRAPHY_CODE,
         `Measure Type`,
         Unit,
         Value = OBS_VALUE)

bind_rows(ward, la, ca) %>% 
  write_csv("csv/input.csv")
