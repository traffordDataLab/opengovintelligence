## Work<ness app - using regularly updated nomis APIs ##

# load necessary packages ---------------------------
library(shiny)
library(tidyverse)
library(sf)
library(spdep) 
library(rgeos)
library(leaflet)
library(ggplot2) 
library(DT)

# load Trafford Data Lab's ggplot2 lab_theme() ---------------------------
source("https://github.com/traffordDataLab/assets/raw/master/theme/ggplot2/theme_lab.R")

# load data ---------------------------
# Latest claimant count data from nomis
source("data/nomis_api.R")

# 2011 Census data stored as a flat file
df <- read_csv("data/worklessness_data.csv") %>%
  bind_rows(ucjsa) %>% 
  mutate(lsoa11cd = factor(lsoa11cd),
         lsoa11nm = factor(lsoa11nm),
         lad17nm = factor(lad17nm),
         measure = factor(measure),
         value = as.integer(value))

# source("data/sparql.R") # commented out because takes 45 seconds approx
# IMD 2015 stored as a flat file but generated using SPARQL query
imd <- read_csv("https://github.com/traffordDataLab/open_data/raw/master/imd_2015/IMD_2015_wide.csv",
                col_types = cols(lsoa11cd = col_factor(NULL),
                                 index_domain = col_factor(NULL),
                                 decile = col_factor(1:10),
                                 rank = col_integer(),
                                 score = col_double()))

# Lower-layer Super Output areas in Greater Manchester
GM_lsoa <- st_read("https://github.com/traffordDataLab/spatial_data/raw/master/lookups/lsoa_to_ward_best-fit_lookup.geojson") %>% 
  as('Spatial')

# Local Authorities in Greater Manchester
la <- st_read("https://github.com/traffordDataLab/spatial_data/raw/master/local_authority/2016/gm_local_authority_generalised.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name) %>% 
  mutate(centroid_lng = map_dbl(geometry, ~st_centroid(.x)[[1]]),
         centroid_lat = map_dbl(geometry, ~st_centroid(.x)[[2]]))

# Jobcentre Plus locations in Greater Manchester
jcplus <- st_read("https://github.com/traffordDataLab/open_data/raw/master/job_centre_plus/jobcentreplus_gm.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

# Betting shops in Greater Manchester
betting <- st_read("https://github.com/traffordDataLab/opengovintelligence/raw/master/apps/beta/app_api/data/betting_shops/bettingshops_gm.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

# General Practices in Greater Manchester
gp <- st_read("https://github.com/traffordDataLab/open_data/raw/master/general_practice/GM_general_practices.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

# Food banks in Greater Manchester
food_bank <- st_read("https://github.com/traffordDataLab/open_data/raw/master/food_banks/GM_food_banks.geojson")

# Probation offices in Greater Manchester
probation <- st_read("https://github.com/traffordDataLab/open_data/raw/master/probation/GM_probation_offices.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)