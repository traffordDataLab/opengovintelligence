## Prototype isochrone app ##

library(shiny); library(tidyverse) ; library(sf) ; library(openrouteservice) ; library(geojsonio) ; library(leaflet) ; library(htmlwidgets)

# Local Authorities in Greater Manchester
la <- st_read("https://www.traffordDataLab.io/spatial_data/local_authority/2016/gm_local_authority_generalised.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name) %>% 
  mutate(centroid_lng = map_dbl(geometry, ~st_centroid(.x)[[1]]),
         centroid_lat = map_dbl(geometry, ~st_centroid(.x)[[2]]))

# General Practices in Greater Manchester
gp <- st_read("https://www.traffordDataLab.io/open_data/general_practice/GM_general_practices.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

ui <- bootstrapPage(
  tags$head(includeCSS("styles_base.css"), includeCSS("styles_shiny.css"), includeCSS("styles_map.css"),
            tags$style(type = "text/css", "html, body {width:100%;height:100%}", ".leaflet-container {cursor:crosshair !important;}"),
               leafletOutput("map", width = "100%", height = "100%"),
               absolutePanel(id = "shinyControls", class = "panel panel-default controls", fixed = TRUE, draggable = TRUE,
                             h4("Choose an isochrone unit"),
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
                             tags$small("Powered by ", tags$a(href="https://openrouteservice.org/", "OpenRouteService"))))
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
    iso <- ors_isochrones(locations = c(click()$lng, click()$lat), 
                          profile = 
                            if(input$unit == "distance"){
                              NULL
                          } else {
                            input$mode
                          },
                          range = 
                            if(input$unit == "distance"){
                              input$distance_slider
                            } else {
                              input$time_slider*60
                            },
                          range_type = input$unit,
                          interval = 
                            if(input$unit == "distance"){
                              0.5
                          } else {
                            60*5
                          },
                          preference = 
                            if(input$unit == "distance"){
                              "shortest"
                            } else {
                              "fastest"
                            },
                          units = 
                            if(input$unit == "distance"){
                              "km"
                            } else {
                              NULL
                            })
    class(iso) <- "geo_list"
    iso <- geojson_sf(iso) %>% arrange(desc(value))
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
      setView(-2.28417866956407, 53.5151885751656, zoom = 11) %>% 
      addPolylines(data = la, stroke = TRUE, weight = 3, color = "#212121", opacity = 1) %>% 
      addLabelOnlyMarkers(data = la, lng = ~centroid_lng, lat = ~centroid_lat, label = ~as.character(lad17nm), 
                          labelOptions = labelOptions(noHide = T, textOnly = T, direction = "bottom",
                                                      style = list(
                                                        "color"="white",
                                                        "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>%
      addAwesomeMarkers(data = gp, popup = ~as.character(name), icon = ~makeAwesomeIcon(icon = "stethoscope", library = "fa", markerColor = "pink", iconColor = "#fff"), group = "GPs", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
      addLayersControl(position = 'topleft',
                       baseGroups = c("Aerial", "Dark", "High Detail", "Low Detail", "None"),
                       overlayGroups = c("GPs"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("GPs")) %>% 
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