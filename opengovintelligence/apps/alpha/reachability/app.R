## Reachability app ##

## load R packages ---------------------------
library(shiny); library(tidyverse) ; library(httr) ; library(geojsonio) ; library(jsonlite) ; library(sf) ; library(leaflet) 

## load data ---------------------------

# Trafford boundary  ---------------------------
la <- st_read("https://www.traffordDataLab.io/spatial_data/local_authority/2016/trafford_local_authority_generalised.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name) %>% 
  mutate(centroid_lng = map_dbl(geometry, ~st_centroid(.x)[[1]]),
         centroid_lat = map_dbl(geometry, ~st_centroid(.x)[[2]]))

# General Practices
gp <- st_read("https://www.traffordDataLab.io/open_data/general_practice/trafford_general_practices.geojson")

# Pharmacies
pharma <- st_read("https://www.traffordDataLab.io/open_data/pharmacies/trafford_pharmacies.geojson")

ui <- bootstrapPage(
  tags$head(includeCSS("styles_base.css"), includeCSS("styles_shiny.css"), includeCSS("styles_map.css"),
            tags$style(type = "text/css", "html, body {width:100%;height:100%}", ".leaflet-container {cursor:crosshair !important;}"),
               leafletOutput("map", width = "100%", height = "100%"),
               absolutePanel(id = "shinyControls", class = "panel panel-default controls", fixed = TRUE, draggable = TRUE,
                             h4("Choose a measure of reachability"),
                             radioButtons(inputId = "unit",
                                          label = NULL,
                                          choices = c("Distance" = "distance", "Travel time" = "time"),
                                          selected = "distance"),
                             conditionalPanel(
                               condition = "input.unit == 'time'",
                               selectInput(inputId = "mode",
                                           label = NULL,
                                           choices = c("Bike" = "cycling-regular",
                                                       "Car" = "driving-car", 
                                                       "Walk" = "foot-walking"),
                                           selected = "foot-walking"),
                             sliderInput("time_slider", label = h5("Range (minutes)"), min = 5, max = 30, value = 5, step = 5, ticks = FALSE, post = " minutes")),
                             uiOutput("range"),
                             br(),
                             actionButton("reset",
                                           label = "Clear isochrones"),
                             br(),br(),
                             tags$small("© Powered by ", tags$a(href="https://openrouteservice.org/", "openrouteservice"))))
)


server <- function(input, output, session) {
  
  output$range <- renderUI({
    if(input$unit == "distance"){
      sliderInput("distance_slider", label = h5("Range (kilometres)"), min = 0.5, max = 3, value = 0.5, step = 0.5, ticks = FALSE, post = " km")
    }else{
      NULL
    }
  })
  
  click <- eventReactive(input$map_click, {
    click <- input$map_click
    })
  
  iso <- reactive({
    
    if(input$unit == "distance"){
      param_profile <- "driving-car"
      param_range <- input$distance_slider
      param_interval <- 0.5
      param_units <- "km"
    }
    else {
      param_profile <- input$mode
      param_range <- input$time_slider*60
      param_interval <- 60*5
      param_units <- ""
    }
    
    request <- GET(url = "https://api.openrouteservice.org/isochrones?",
                   query = list(api_key = "58d904a497c67e00015b45fc6862cde0265d4fd78ec660aa83220cdb",
                                locations = paste0(click()$lng,",",click()$lat),
                                profile = param_profile,
                                range_type = input$unit,
                                range = param_range,
                                interval = param_interval,
                                units = param_units))
    
    content <- content(request, as = "text", encoding = "UTF-8")
    results <- fromJSON(txt = content)
    class(results) <- "geo_list"
    request <- geojson_sf(results) %>% arrange(desc(value))
    
  })

  observeEvent(input$reset, {
    leafletProxy("map") %>%
      clearGroup("isochrones")
  })
  
  output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles(urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", 
               attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community | <a href="https://www.ons.gov.uk/methodology/geography/licences"> Contains OS data © Crown copyright and database right (2017)</a>', 
               group = "Aerial",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>%
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "Low Detail",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>  | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "High Detail",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}{r}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "Dark",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "", 
               attribution = '<a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "None") %>% 
      setView(-2.35533522781156, 53.419025498197, zoom = 12) %>% 
      addPolylines(data = la, stroke = TRUE, weight = 3, color = "#212121", opacity = 1) %>% 
      addLabelOnlyMarkers(data = la, lng = ~centroid_lng, lat = ~centroid_lat, label = ~as.character(lad17nm), 
                          labelOptions = labelOptions(noHide = T, textOnly = T, direction = "bottom",
                                                      style = list(
                                                        "color"="white",
                                                        "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>%
      addAwesomeMarkers(data = gp, popup = ~as.character(name), icon = ~makeAwesomeIcon(icon = "stethoscope", library = "fa", iconColor = "#fff", markerColor = "pink"), group = "GPs", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
      addAwesomeMarkers(data = pharma, popup = ~as.character(provider), icon = ~makeAwesomeIcon(icon = "medkit", library = "fa", iconColor = " #000000", markerColor = "blue"), group = "Pharmacies", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
      addLayersControl(position = 'topleft',
                       baseGroups = c("Aerial", "Dark", "High Detail", "Low Detail", "None"),
                       overlayGroups = c("GPs", "Pharmacies"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("GPs", "Pharmacies")) %>% 
      htmlwidgets::onRender(
        " function(el, t) {
        var myMap = this;
        myMap._container.style['background'] = '#ffffff';}")
    })
  
  observe({
    
    req(click())
    factpal <- colorFactor(palette = c( "#7f2704","#a63603","#d94801","#f16913","#fd8d3c","#fdae6b"), domain = iso()$value,
                           ordered = TRUE)
    
    map <- leafletProxy('map') %>%
      clearGroup("isochrones") %>% 
      addPolygons(data = iso(),
                  fill = TRUE, fillColor = "#ffffff", fillOpacity = 0.1,
                  stroke = TRUE, opacity = 1, color = ~factpal(iso()$value), weight = 6, 
                  dashArray = "1,13", options = pathOptions(lineCap = "round"),
                  label = if(input$unit == "time"){
                    as.character(paste0(iso()$value/60, " minutes"))
                  }else{
                    as.character(paste0(iso()$value/1000, "km"))
                  },
                  labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto"),
                  highlight = highlightOptions(weight = 6, color = "#FFFF00", fillOpacity = 0, bringToFront = FALSE),
                  group = "isochrones") %>%
      addAwesomeMarkers(data = click(), lat = ~lat, lng = ~lng,
                        icon = if(input$unit == "time" & input$mode == "cycling-regular"){
                          ~makeAwesomeIcon(icon = "bicycle", library = "fa", iconColor = "black", markerColor = "white")
                        } else if(input$unit == "time" & input$mode == "driving-car"){
                          ~makeAwesomeIcon(icon = "car", library = "fa", iconColor = "black", markerColor = "white")
                        } else if(input$unit == "time" & input$mode == "foot-walking") {
                          ~makeAwesomeIcon(icon = "male", library = "fa", iconColor = "black", markerColor = "white")
                        } else if(input$unit == "distance"){
                          ~makeAwesomeIcon(icon = "road", library = "fa", iconColor = "black", markerColor = "white")
                        } else {  
                          return()
                        },
                        group = "isochrones")
  })

}

shinyApp(ui, server)