## Work<ness app ##

# Load necessary packages
library(shiny) ; library(tidyverse) ; library(sf) ; library(spdep) ; library(rgeos); library(leaflet) ; library(ggplot2) ; library(DT)

# Load Trafford Data Lab's ggplot2 lab_theme()
source("https://github.com/traffordDataLab/assets/raw/master/theme/ggplot2/theme_lab.R")

# Load  data ---------------------------

# 1. ONS Claimant Count by sex and age (ONS) - latest month (September 2017)
# 2. KS107EW - Lone parent households with dependent children (Census 2011)
# 3. LC5601EW - Highest level of qualification by economic activity (Census 2011)
# 4. Employment and Support Allowance - May 2017 (ONS)
# 5. Households classified as social rented (Census 2011)
df <- read_csv("data/worklessness_data.csv", 
               col_types = cols(lsoa11cd = col_factor(NULL),
                                lsoa11nm = col_factor(NULL),
                                lad16nm = col_factor(NULL),
                                measure = col_factor(NULL), 
                                value = col_integer()))

# ONS Claimant Count by sex and age (ONS) - time series
df_ts <- read_csv("data/ucjsa_ts.csv", col_types = cols(date = col_datetime(),
                                                        area_code = col_factor(NULL), 
                                                        area_name = col_factor(NULL),
                                                        measure = col_factor(NULL), 
                                                        value = col_double()))

# Index of Multiple Deprivation (DCLG, 2015)
imd <- read_csv("https://github.com/traffordDataLab/open_data/raw/master/imd_2015/IMD_2015_wide.csv",
                col_types = cols(lsoa11cd = col_factor(NULL), 
                                 index_domain = col_factor(NULL), 
                                 decile = col_factor(1:10), 
                                 rank = col_integer(), 
                                 score = col_double()))

# GM LSOA layer (ONS Open Geography Portal)
GM_lsoa <- st_read("https://github.com/traffordDataLab/spatial_data/raw/master/lookups/lsoa_to_ward_best-fit_lookup.geojson") %>% 
  as('Spatial')

# GM Local Authority layer (ONS Open Geography Portal)
la <- st_read("https://github.com/traffordDataLab/spatial_data/raw/master/local_authority/2016/gm_local_authority_generalised.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name) %>% 
  mutate(centroid_lng = map_dbl(geometry, ~st_centroid(.x)[[1]]),
         centroid_lat = map_dbl(geometry, ~st_centroid(.x)[[2]]))

# GM Jobcentre Plus 
jcplus <- st_read("https://github.com/traffordDataLab/open_data/raw/master/job_centre_plus/jobcentreplus_gm.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

# Gambling Premises (Gambling Commission)
gambling <- st_read("https://github.com/traffordDataLab/open_data/raw/master/betting_shops/bettingshops_gm.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

# General Practices
gp <- st_read("https://github.com/traffordDataLab/open_data/raw/master/general_practice/GM_general_practices.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)
