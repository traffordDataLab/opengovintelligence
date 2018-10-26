## Scan app ##

# load necessary packages ---------------------------
library(shiny) ; library(tidyverse) ; library(SPARQL) ; library(leaflet) ; library(sf) ; library(spdep) ; library(rgeos)

# load Trafford Data Lab's ggplot2 theme ---------------------------
source("https://www.traffordDataLab.io/assets/theme/ggplot2/theme_lab.R")

# load LISA stats ---------------------------
source("https://www.traffordDataLab.io/assets/rfunctions/LISA/lisa_stats.R")

# load tabular data using SPARQL queries ---------------------------
source("sparql/claimant_count.R")
source("sparql/households_with_lone_parent_not_in_employment.R")
source("sparql/social_rented_households.R")
source("sparql/working_age_adults_with_no_qualifications.R")

df <- bind_rows(claimant_count, 
                households_with_lone_parent_not_in_employment, 
                social_rented_households, 
                working_age_adults_with_no_qualifications) %>% 
  mutate(lsoa11cd = factor(lsoa11cd),
         lsoa11nm = factor(lsoa11nm),
         lad17nm = factor(lad17nm),
         measure = factor(measure),
         value = as.integer(value))
  
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
jcplus <- st_read("https://www.traffordDataLab.io/open_data/jobcentre_plus/gm_jobcentreplus.geojson")