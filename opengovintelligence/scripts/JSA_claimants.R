
# ------------------ Job Seekers Allowance claimants by ward
# Query SPARQL endpoint for JSA claimants data, join with ward vector boundary and plot as an interactive map

# load the SPARQL package
library(SPARQL)

# define the endpoint
endpoint <- "http://gmdatastore.org.uk/sparql"

# build the query statement
query <- paste0(
  "
  SELECT ?ward_code ?count
  WHERE {
  ?s <http://purl.org/linked-data/cube#dataSet> <http://gmdatastore.org.uk/data/jsa-by-ward>.
  ?s <http://gmdatastore.org.uk/def/dimension/gender> <http://gmdatastore.org.uk/def/concept/gender/all>.
  ?s <http://purl.org/linked-data/sdmx/2009/dimension#refPeriod> <http://reference.data.gov.uk/id/month/2017-06>.
  ?s <http://gmdatastore.org.uk/def/measure-properties/count> ?count.
  ?s <http://purl.org/linked-data/sdmx/2009/dimension#refArea> ?ward_code_uri.
  ?ward_code_uri <http://www.w3.org/2004/02/skos/core#notation> ?ward_code.
  }
  ")

# submit query and save results to a data frame
qd <- SPARQL(endpoint,query)$results

# extract ward code (wd16cd) from string
library(stringr) ; library(tidyverse)
qd$ward_code <- str_extract(qd$ward_code,'(?<=").*?(?=")')
qd <- rename(qd, wd16cd = ward_code) %>% as.data.frame()

# load the ward boundary layer
library(sf)
wards <- st_read("https://opendata.arcgis.com/datasets/afcc88affe5f450e9c03970b237a7999_3.geojson") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', lad16nm)) %>%
  st_as_sf(crs = 4326, coords = c("long", "lat"))

# join JSA claimant data to ward vector layer
wards_jsa <- left_join(wards, qd, by = "wd16cd")
plot(wards_jsa["count"])

# plot the results
library(RColorBrewer) ; library(classInt) ; library(leaflet) ; library(htmltools)

cols_classes <- classIntervals(round(wards_jsa$count, 1), n = 5, style = "jenks")
cols_code <- findColours(cols_classes, brewer.pal(5, "Blues"))
binpal <- colorBin(palette = "Blues", 
                   domain = cols_classes$brks, 
                   bins = cols_classes$brks, 
                   pretty = FALSE,
                   na.color = "#f7fcb9")

leaflet(data = wards_jsa) %>% 
  setView(-2.242605, 53.480832, 10) %>% 
  addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
           attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> <a href="https://www.ons.gov.uk/methodology/geography/licences">| Contains OS data © Crown copyright and database right (2017)</a>') %>% 
  addPolygons(fillColor = cols_code, 
              weight = 0.5, 
              opacity = 1, 
              color = "#636363", 
              fillOpacity = 0.7,
              highlight = highlightOptions(weight = 3, color = "#ffffff", fillOpacity = 0.7, bringToFront = TRUE),
              popup = sprintf(
                "<strong>%s</strong><br /><em>%s</em><hr /><strong>Claimants</strong>: %s", 
                htmlEscape(wards_jsa$wd16nm),
                htmlEscape(wards_jsa$lad16nm),
                htmlEscape(wards_jsa$count))) %>% 
  addLegend(position = "bottomleft",
            pal = binpal,
            opacity = 1,
            values = round(cols_classes$brks, 0),
            title = "June 2017") %>% 
  addControl("<strong>Job Seekers Allowance claimants by ward</strong> - June 2017<br /><em>Source: DWP</em>",
             position = 'topright')

# library(htmlwidgets)
# saveWidget(map, file = "index.html")
