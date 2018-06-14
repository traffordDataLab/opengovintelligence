## Claimant counts - nomis API ##

library(tidyverse)

# Measure: Claimant count by sex and age: Claimants as a proportion of residents aged 16-64
# Source: https://www.nomisweb.co.uk/datasets/ucjsa
# Geography: Combined Authority, Local Authority, Electoral ward
# Period: latest 36 months

ucjsa <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=E47000001,E08000001...E08000010,E05000650...E05000864&date=latestMINUS36-latest&gender=0&age=0&measure=2&measures=20100&select=date_name,geography_name,geography_code,gender_name,age_name,measure_name,measures_name,obs_value,obs_status_name") %>% 
  mutate(date = as.Date(paste('01', DATE_NAME), format = '%d %B %Y'),
         lad17nm = str_sub(GEOGRAPHY_NAME, 1, str_length(GEOGRAPHY_NAME)-5)) %>% 
  select(date,
         area_name = GEOGRAPHY_NAME,
         area_code = GEOGRAPHY_CODE, 
         measure = MEASURE_NAME,
         value = OBS_VALUE)

# load ward to local authority lookup ---------------------------
lookup <- read_csv("https://github.com/traffordDataLab/spatial_data/raw/master/lookups/administrative_lookup.csv") %>% 
  select(area_code = wd17cd, lad17nm)

# join local authority names to ward rows ---------------------------
wards <- ucjsa %>% 
  filter(!area_name %in% c("Greater Manchester","Bolton","Bury","Manchester","Oldham","Rochdale",
                           "Salford","Stockport","Tameside","Trafford","Wigan")) %>% 
  left_join(lookup) %>% 
  mutate(label = paste0("(", lad17nm, ")")) %>% 
  unite(label, area_name, label, sep = " ") %>% 
  select(-lad17nm)

# row bind local authorities ---------------------------
df_ts <- ucjsa %>% 
  filter(area_name %in% c("Greater Manchester","Bolton","Bury","Manchester","Oldham",
                          "Rochdale","Salford","Stockport","Tameside","Trafford","Wigan")) %>% 
  rename(label = area_name) %>% 
  bind_rows(wards) %>% 
  mutate(area_name = label) %>% 
  select(date, area_code, area_name, measure, value) %>% 
  arrange(date) %>% 
  mutate(area_name = factor(area_name),
       area_code = factor(area_code),
       measure = factor(measure),
       value = as.double(value))

rm(ucjsa, lookup, wards)

# ---------------------------

# Measure: Claimant count by sex and age: Claimant count
# Source: https://www.nomisweb.co.uk/datasets/ucjsa
# Geography: Lower-layer Super Output Area
# Period: latest month

ucjsa <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=TYPE298&date=latest&gender=0&age=0&measure=1&measures=20100&select=date_name,geography_name,geography_code,gender_name,age_name,measure_name,measures_name,obs_value,obs_status_name") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', GEOGRAPHY_NAME)) %>% 
  mutate(date = as.Date(paste('01', DATE_NAME), format = '%d %B %Y'),
         lad17nm = str_sub(GEOGRAPHY_NAME, 1, str_length(GEOGRAPHY_NAME)-5),
         measure = "Residents claiming JSA or Universal Credit") %>% 
  select(date,
         lsoa11nm = GEOGRAPHY_NAME,
         lsoa11cd = GEOGRAPHY_CODE, 
         lad17nm,
         measure,
         value = OBS_VALUE)
