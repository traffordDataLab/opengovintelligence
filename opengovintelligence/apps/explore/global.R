## Work<ness app ##

# load necessary packages ---------------------------
library(shiny) ; library(tidyverse) ; library(leaflet) ; library(sf) ; library(spdep) ; library(rgeos) ; 
library(ggplot2) ; library(plotly) ; library(DT) ; 
library(httr) ; library(geojsonio) ; library(jsonlite) 

# load Trafford Data Lab's ggplot2 theme ---------------------------
source("https://www.traffordDataLab.io/assets/theme/ggplot2/theme_lab.R")

# load LISA stats ---------------------------
source("https://www.traffordDataLab.io/assets/rfunctions/LISA/lisa_stats.R")

# load tabular data ---------------------------

# latest claimant count data from nomis
source("data/nomis_api.R")

# 2011 Census data stored as a flat file
df <- read_csv("data/worklessness_data.csv") %>%
  bind_rows(ucjsa) %>% 
  mutate(lsoa11cd = factor(lsoa11cd),
         lsoa11nm = factor(lsoa11nm),
         lad17nm = factor(lad17nm),
         measure = factor(measure),
         value = as.integer(value))

# IMD 2015 stored as a flat file but generated using SPARQL query
imd <- read_csv("https://www.traffordDataLab.io/open_data/imd_2015/IMD_2015_wide.csv",
                col_types = cols(lsoa11cd = col_factor(NULL),
                                 index_domain = col_factor(NULL),
                                 decile = col_factor(1:10),
                                 rank = col_integer(),
                                 score = col_double()))

# load geospatial data ---------------------------

# Lower-layer Super Output areas in Greater Manchester
GM_lsoa <- st_read("https://www.traffordDataLab.io/spatial_data/lookups/lsoa_to_ward_best-fit_lookup.geojson") %>% 
  as('Spatial')

# Local Authorities in Greater Manchester
la <- st_read("https://www.traffordDataLab.io/spatial_data/local_authority/2016/gm_local_authority_generalised.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name) %>% 
  mutate(centroid_lng = map_dbl(geometry, ~st_centroid(.x)[[1]]),
         centroid_lat = map_dbl(geometry, ~st_centroid(.x)[[2]]))

# Jobcentre Plus locations in Greater Manchester
jcplus <- st_read("https://www.traffordDataLab.io/open_data/job_centre_plus/jobcentreplus_gm.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

# Betting shops in Greater Manchester
betting <- st_read("https://github.com/traffordDataLab/projects/raw/master/opengovintelligence/apps/production/work%3Cness/data/betting_shops/bettingshops_gm.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

# General Practices in Greater Manchester
gp <- st_read("https://www.traffordDataLab.io/open_data/general_practice/GM_general_practices.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

# Food banks in Greater Manchester
food_bank <- st_read("https://www.traffordDataLab.io/open_data/food_banks/GM_food_banks.geojson")

# Probation offices in Greater Manchester
probation <- st_read("https://www.traffordDataLab.io/open_data/probation/GM_probation_offices.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)
