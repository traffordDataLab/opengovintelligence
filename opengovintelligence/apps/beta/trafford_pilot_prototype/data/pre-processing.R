library(tidyverse)

## ------------ Rate of residents claiming JSA or Universal Credit (01-2014 - 09/2017)
# Claimant count by sex and age (nomis API)
# Source: https://www.nomisweb.co.uk/datasets/ucjsa
# Geographical area: Electoral ward (2015)

ucjsa <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=1853882369,1879048217...1879048226,1673527867...1673527876,1673527878,1673527877,1673527879...1673527899,1673527901,1673527900,1673527902...1673527950,1673527953,1673527951,1673527952,1673527954...1673527997,1673527999,1673527998,1673528000,1673528002,1673528003,1673528001,1673528004...1673528050,1673528052,1673528051,1673528053...1673528081&date=latestMINUS44-latest&gender=0&age=0&measure=1,2&measures=20100&select=date_name,geography_name,geography_code,gender_name,age_name,measure_name,measures_name,obs_value,obs_status_name") %>% 
  filter(MEASURE_NAME == "Claimants as a proportion of residents aged 16-64") %>% 
  select(date = DATE_NAME,
         area_code = GEOGRAPHY_CODE, 
         area_name = GEOGRAPHY_NAME, 
         measure = MEASURE_NAME, 
         value = OBS_VALUE) 

#  load area lookup (Open Geography Portal)
lookup <- read_csv("https://ons.maps.arcgis.com/sharing/rest/content/items/6417806dc4564ba5afcf15c3a5670ca6/data") %>% 
  select(area_code = WD15CD, 
         la_name = LAD15NM)

# join local authority names to ward rows
ucjsa_wards <- ucjsa %>% 
  filter(!area_name %in% c("Greater Manchester","Bolton","Bury","Manchester","Oldham","Rochdale",
                                               "Salford","Stockport","Tameside","Trafford","Wigan")) %>% 
  left_join(lookup) %>% 
  mutate(label = paste0("(", la_name, ")")) %>% 
  unite(label, area_name, label, sep = " ") %>% 
  select(-la_name)

# row bind local authorities
ucjsa_ts <- ucjsa %>% 
  filter(area_name %in% c("Greater Manchester","Bolton","Bury","Manchester","Oldham",
                                     "Rochdale","Salford","Stockport","Tameside","Trafford","Wigan")) %>% 
  rename(label = area_name) %>% 
  bind_rows(ucjsa_wards) %>% 
  mutate(date = as.Date(paste('01', date), format = '%d %B %Y'),
         area_name = label) %>% 
  select(date, area_code, area_name, measure, value) %>% 
  arrange(date)

write.csv(ucjsa_ts, "ucjsa_ts.csv", row.names = FALSE)
