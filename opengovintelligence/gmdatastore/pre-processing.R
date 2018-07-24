## Data preparation for GM DataStore ##

library(sf) ; library(tidyverse)

# betting_shops
sf <- st_read("https://www.traffordDataLab.io/projects/opengovintelligence/apps/explore/data/betting_shops/bettingshops_gm.geojson")
coords <- st_coordinates(sf)
df <- sf %>%
  st_set_geometry(value = NULL) 
df$long <- coords[,1]
df$lat <- coords[,2]
write_csv(df, "data/bettingshops_gm.csv")

# census data
df <- read_csv("https://www.traffordDataLab/projects/opengovintelligence/apps/explore/data/worklessness_data.csv")
filter(df, measure == "Households with lone parent not in employment") %>% 
  write_csv("data/ks107ew.csv")
filter(df, measure == "Social rented households") %>% 
  write_csv("data/ks402ew.csv")
filter(df, measure == "Working-age adults with no qualifications") %>% 
  write_csv("data/lc5601ew.csv")

# claimant counts
read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=E47000001,E08000001...E08000010,E05000650...E05000864&date=latestMINUS36-latest&gender=0&age=0&measure=2&measures=20100&select=date_name,geography_name,geography_code,gender_name,age_name,measure_name,measures_name,obs_value,obs_status_name") %>% 
  mutate(date = as.Date(paste('01', DATE_NAME), format = '%d %B %Y'),
         lad17nm = str_sub(GEOGRAPHY_NAME, 1, str_length(GEOGRAPHY_NAME)-5)) %>% 
  select(date,
         area_name = GEOGRAPHY_NAME,
         area_code = GEOGRAPHY_CODE, 
         measure = MEASURE_NAME,
         value = OBS_VALUE) %>% 
  write_csv("data/ucjsa_time_series.csv")

read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=TYPE298&date=latest&gender=0&age=0&measure=1&measures=20100&select=date_name,geography_name,geography_code,gender_name,age_name,measure_name,measures_name,obs_value,obs_status_name") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', GEOGRAPHY_NAME)) %>% 
  mutate(date = as.Date(paste('01', DATE_NAME), format = '%d %B %Y'),
         lad17nm = str_sub(GEOGRAPHY_NAME, 1, str_length(GEOGRAPHY_NAME)-5),
         measure = "Residents claiming JSA or Universal Credit") %>% 
  select(date,
         lsoa11nm = GEOGRAPHY_NAME,
         lsoa11cd = GEOGRAPHY_CODE, 
         lad17nm,
         measure,
         value = OBS_VALUE) %>% 
  write_csv("data/ucjsa_lsoa.csv")

