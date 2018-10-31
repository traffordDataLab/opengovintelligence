## Scan app ##

# load necessary packages ---------------------------
library(shiny) ; library(tidyverse) ; library(ghql) ; library(leaflet) ; library(sf) ; library(spdep) ; library(rgeos)

# load Trafford Data Lab's ggplot2 theme ---------------------------
source("https://www.traffordDataLab.io/assets/theme/ggplot2/theme_lab.R")

# load LISA stats ---------------------------
source("https://www.traffordDataLab.io/assets/rfunctions/LISA/lisa_stats.R")

# load tabular data using SPARQL queries ---------------------------
source("cubiql/queries.R")
  
# imd <- read_csv("https://www.traffordDataLab.io/open_data/imd_2015/IMD_2015_wide.csv",
#                 col_types = cols(lsoa11cd = col_factor(NULL),
#                                  index_domain = col_factor(NULL),
#                                  decile = col_factor(1:10),
#                                  rank = col_integer(),
#                                  score = col_double()))

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
jcplus <- read_csv("https://www.traffordDataLab.io/open_data/jobcentre_plus/gm_jobcentreplus.csv") %>% 
  st_as_sf(coords = c("lon", "lat")) %>% 
  st_set_crs(4326) 
