## Prototype isochrone app ##

library(tidyverse) ; library(sf) ; library(openrouteservice) ; library(geojsonio) ; library(leaflet)

jobcentre <- st_read("https://www.traffordDataLab.io/open_data/job_centre_plus/jobcentreplus_gm.geojson")
foodbank <- st_read("https://www.traffordDataLab.io/open_data/food_banks/GM_food_banks.geojson")
probation <- st_read("https://www.traffordDataLab.io/open_data/probation/GM_probation_offices.geojson")
la <- st_read("https://www.traffordDataLab.io/spatial_data/local_authority/2016/gm_local_authority_generalised.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

ui <- bootstrapPage(
  tags$head(tags$style(
    type = "text/css",
    "html, body {width:100%; height:100%}",
    ".leaflet-container {cursor:crosshair !important;}",
    ".shiny-notification {height:80px; width:400px; position:fixed; top:calc(50% - 25px); left:calc(50% - 200px);}")),
  leafletOutput("map", width = "100%", height = "100%")
)

server <- function(input, output,session) {
  
  output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "CartoDB",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>  | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "OpenStreetMap",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", 
               attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community | <a href="https://www.ons.gov.uk/methodology/geography/licences"> Contains OS data © Crown copyright and database right (2017)</a>', 
               group = "Satellite",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>%
      addTiles(urlTemplate = "", 
               attribution = '<a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "No background") %>% 
      setView(-2.28417866956407, 53.5151885751656, zoom = 11) %>% 
      addPolylines(data = la, stroke = TRUE, weight = 3, color = "#212121", opacity = 1) %>% 
      addAwesomeMarkers(data = jobcentre, label = ~as.character(name),
                        icon = ~makeAwesomeIcon(icon = "building-o", library = "fa", iconColor = "#fff", markerColor = "green"),
                        options = markerOptions(riseOnHover = TRUE, opacity = 0.75),
                        group = "Jobcentre Plus") %>%
      addAwesomeMarkers(data = foodbank, label = ~as.character(name),
                        icon = ~makeAwesomeIcon(icon = "fa-cutlery", library = "fa", iconColor = "#000000", markerColor = "blue"),
                        options = markerOptions(riseOnHover = TRUE, opacity = 0.75),
                        group = "Foodbanks") %>%
      addAwesomeMarkers(data = probation, label = ~as.character(name),
                        icon = ~makeAwesomeIcon(icon = "fa-balance-scale", library = "fa", iconColor = "#fff", markerColor = "black"),
                        options = markerOptions(riseOnHover = TRUE, opacity = 0.75),
                        group = "Probation offices") %>%
      addLayersControl(position = 'topleft',
                       baseGroups = c("CartoDB", "OpenStreetMap", "Satellite", "No background"),
                       overlayGroups = c("Jobcentre Plus", "Foodbanks", "Probation offices"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("Foodbanks", "Probation offices")) %>% 
      addControl("<h4>Select a road location with the crosshair<br>to calculate the network distance from it.</h4>",
                 position="topright") %>% 
      htmlwidgets::onRender(
        " function(el, t) {
        var myMap = this;
        myMap._container.style['background'] = '#ffffff';}")
    })
  
  observeEvent(input$map_click, {
    click <- input$map_click
    iso <- ors_isochrones(locations = c(click$lng, click$lat), 
                          profile = "driving-car",
                          range_type = "distance",
                          range = 2500, 
                          interval = 500)
    class(iso) <- "geo_list"
    iso <- geojson_sf(iso) %>% arrange(desc(value))
    factpal <- colorFactor(palette = "viridis", domain = iso$value)
    
    leafletProxy("map") %>%
      clearShapes() %>% removeControl("legend") %>% removeMarker("marker") %>% 
      addPolylines(data = la, stroke = TRUE, weight = 3, color = "#212121", opacity = 1) %>% 
      addPolygons(data = iso,
                  fill = TRUE, fillColor = ~factpal(iso$value), fillOpacity = 0.2,
                  stroke = TRUE, color = "black", weight = 0.5,
                  label = as.character(paste0(iso$value, "m"))) %>%
      addAwesomeMarkers(data = input$map_click, lat = ~click$lat, lng = ~click$lng,
                        icon = ~makeAwesomeIcon(icon = "times", library = "fa", iconColor = "red", markerColor = "white"),
                        layerId = "marker") %>%
      addLegend(pal = factpal, 
                values = iso$value, 
                opacity = 0.2,
                labFormat = labelFormat(suffix = "m"),
                title = "Network distance", position = "bottomleft",
                layerId = "legend")
  })
  }

shinyApp(ui, server)