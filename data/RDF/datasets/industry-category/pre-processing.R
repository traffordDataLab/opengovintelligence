# Measure: Percentage of employees by broad industry group
# Source: https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/bulletins/businessregisterandemploymentsurveybresprovisionalresults/provisionalresults2017revisedresults2016
# Geography: Electoral ward
# Period: 2017

library(tidyverse)

read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_189_1.data.csv?geography=1665139259...1665139473&date=latest&industry=163577857...163577874&employment_status=1&measure=2&measures=20100&select=date_name,geography_name,geography_code,industry_name,employment_status_name,measure_name,measures_name,obs_value,obs_status_name") %>% 
  mutate(Date = "2017",
         `Industry category` = readr::parse_number(INDUSTRY_NAME),
         `Measure Type` = "percent",
         Unit = "persons") %>%
  select(Date,
         Geography = GEOGRAPHY_CODE, 
         `Measure Type`,
         Unit,
         `Industry category`,
         Value = OBS_VALUE) %>%
  write_csv("csv/input.csv")
