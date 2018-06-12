## 2011 Census data - flat files ##

library(tidyverse)

# Measure: KS107EW - Lone parent households with dependent children
# Source: https://www.nomisweb.co.uk/census/2011/KS107EW
# Geography: Lower-layer Super Output Area
# Period: 27 March 2011

ks107ew <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_607_1.data.csv?geography=TYPE298&rural_urban=0&cell=3&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', GEOGRAPHY_NAME)) %>% 
  mutate(date = as.Date("27-03-2011", format = "%d-%m-%Y"),
         lad17nm = str_sub(GEOGRAPHY_NAME, 1, str_length(GEOGRAPHY_NAME)-5),
         measure = "Households with lone parent not in employment") %>% 
  select(date, 
         lsoa11nm = GEOGRAPHY_NAME, 
         lsoa11cd = GEOGRAPHY_CODE, 
         lad17nm,
         measure,
         value = OBS_VALUE)

# ---------------------------

# Measure: KS402EW - Tenure (Households classified as social rented)
# Source: https://www.nomisweb.co.uk/census/2011/ks402ew
# Geography: Lower-layer Super Output Area
# Period: 27 March 2011

ks402ew <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_619_1.data.csv?geography=TYPE298&rural_urban=0&cell=200&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', GEOGRAPHY_NAME)) %>% 
  mutate(date = as.Date("27-03-2011", format = "%d-%m-%Y"),
         lad17nm = str_sub(GEOGRAPHY_NAME, 1, str_length(GEOGRAPHY_NAME)-5),
         measure = "Social rented households") %>% 
  select(date, 
         lsoa11nm = GEOGRAPHY_NAME, 
         lsoa11cd = GEOGRAPHY_CODE, 
         lad17nm,
         measure,
         value = OBS_VALUE)

# ---------------------------

# Measure: LC5601EW - Highest level of qualification by economic activity
# Source: https://www.nomisweb.co.uk/census/2011/lc5601ew
# Geography: Lower-layer Super Output Area
# Period: 27 March 2011

lc5601ew <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1043_1.data.csv?geography=TYPE298&c_hlqpuk11=1&c_ecopuk11=0&measures=20100&select=date,geography_name,geography_code,cell_name,obs_value") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', GEOGRAPHY_NAME)) %>% 
  mutate(date = as.Date("27-03-2011", format = "%d-%m-%Y"),
         lad17nm = str_sub(GEOGRAPHY_NAME, 1, str_length(GEOGRAPHY_NAME)-5),
         measure = "Working-age adults with no qualifications") %>% 
  select(date, 
         lsoa11nm = GEOGRAPHY_NAME, 
         lsoa11cd = GEOGRAPHY_CODE, 
         lad17nm,
         measure,
         value = OBS_VALUE)

bind_rows(ks107ew, ks402ew, lc5601ew) %>%
  write_csv("data/worklessness_data.csv")
