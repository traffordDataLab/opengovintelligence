## Gambling premises ##

# Source: Gambling Commission
# Publisher URL: https://secure.gamblingcommission.gov.uk/PublicRegister
# Licence: Open Government Licence

# load libraries
library(tidyverse); library(readxl) ; library(sf)

# load data ---------------------------
raw <- read_excel("Premises-licence-database-extract.xlsx")

# load area lookup ---------------------------
area_lookup <- read_csv("https://www.traffordDataLab.io/spatial_data/lookups/administrative_lookup.csv") %>% 
  select(area_code = lad17cd, area_name = lad17nm) %>% 
  unique()

# tidy data ---------------------------
df <- raw %>%
  mutate(premises_City = gsub("(?<=\\b)([a-z])", "\\U\\1", tolower(premises_City), perl = TRUE),
         address = str_c(premises_Address1, premises_Address2, premises_City, sep=", "),
         area_name = str_extract(Local_Authority_Name, "Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan")) %>% 
  filter(!is.na(area_name)) %>%
  select(name = Account_Name, address, postcode = premises_Postcode, area_name) %>% 
  left_join(., area_lookup, by = "area_name")

# match with ONS postcodes ---------------------------
postcodes <- read_csv("https://www.traffordDataLab.io/spatial_data/postcodes/GM_postcodes_2018-02.csv")
df_postcodes <- left_join(df, postcodes, by = "postcode")

# convert to spatial object ---------------------------
sf <- df_postcodes %>%  
  filter(!is.na(lat)) %>%
  st_as_sf(coords = c("long", "lat")) %>% 
  st_set_crs(4326)

# write data   ---------------------------
st_write(sf, "bettingshops_gm.geojson")
