## Libraries in Greater Manchester - July 2016 ## 
# Source: Libraries Taskforce
# Publisher URL: https://www.gov.uk/government/publications/public-libraries-in-england-basic-dataset
# Licence: Open Government Licence

# load libraries -----------------------------------------
library(tidyverse) ; library(sf)

# load data -----------------------------------------
raw <- read_csv("https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/673041/Public_libraries_in_England-_extended_basic_dataset__as_on_1_July_2016_.csv",
                col_names = FALSE, skip = 1)
names(raw) <- raw[1,]
raw <- raw[-1,]

# tidy data -----------------------------------------
df <- raw %>% 
  filter(is.na(`Type of closed library: \nXL: Closed library \nXLR: Closed and replaced\nXLT: Temporarily closed`)) %>% 
  select(service = `Library service`,
         name = `Library name`,
         address = `Postal address`,
         postcode = Postcode,
         type = `Type of library: LAL, LAL-, CL, CRL, CRL+, ICL, ICL+`,
         email = `Contact email`,
         website = `URL of library website`) %>% 
  mutate(type = fct_recode(type,
                           "Local authority run library" = "LAL", 
                           "Local authority run library" = "LAL-",
                           "Commissioned library" = "CL",
                           "Community run library" = "CRL",
                           "Community run library" = "CRL+",
                           "Independent community library" = "ICL",
                           "Independent community library" = "ICL+")) %>% 
  filter(service %in% c("Bolton","Bury","Manchester","Oldham","Rochdale","Salford","Stockport","Tameside","Trafford","Wigan"))

# geocode  -----------------------------------------
postcodes <- read_csv("https://www.traffordDataLab.io/spatial_data/postcodes/GM_postcodes_2018-02.csv")
df_postcodes <- left_join(df, postcodes, by = "postcode")

# convert to spatial object ---------------------------
sf <- df_postcodes %>%  
  filter(!is.na(lat)) %>%
  st_as_sf(coords = c("long", "lat")) %>% 
  st_set_crs(4326)

# write data   ---------------------------
services <- c("Bolton","Bury","Manchester","Oldham","Rochdale","Salford","Stockport","Tameside","Trafford","Wigan")

for(search in services){
  write_csv(filter(st_set_geometry(sf, value = NULL), service == search), paste0("data/libraries_", search, ".csv"))
  st_write(filter(sf, service == search), paste0("data/libraries_", search, ".geojson"))
}
