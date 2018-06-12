## Openroute isochrone maps ##

# https://giscience.github.io/openrouteservice-r/articles/openrouteservice.html

library(openrouteservice) ; library(geojsonio) ; library(leaflet)

# define API key
# ors_api_key("<your-api-key>")

# select coordinates
coordinates <- c(-2.330229, 53.421826)

# query Openroute API network distance from location
x <- ors_isochrones(coordinates, 
                    profile = "driving-car",
                    range_type = "distance",
                    range = 2500, 
                    interval = 500)

# convert to an sf object
class(x) <- "geo_list"
sf <- geojson_sf(x) %>% 
  arrange(desc(value))

# create palette
factpal <- colorFactor(palette = "viridis", domain = sf$value)

# plot isochrones
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = sf,
              fill = TRUE, fillColor = ~factpal(sf$value), fillOpacity = 0.2,
              stroke = TRUE, color = "black", weight = 0.5,
              label = as.character(sf$value))

