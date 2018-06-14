## Prototype isochrone app ##

library(shiny); library(tidyverse) ; library(sf) ; library(openrouteservice) ; library(geojsonio) ; library(leaflet)

jobcentre <- st_read("https://www.traffordDataLab.io/open_data/job_centre_plus/jobcentreplus_gm.geojson")
foodbank <- st_read("https://www.traffordDataLab.io/open_data/food_banks/GM_food_banks.geojson")
probation <- st_read("https://www.traffordDataLab.io/open_data/probation/GM_probation_offices.geojson")
la <- st_read("https://www.traffordDataLab.io/spatial_data/local_authority/2016/gm_local_authority_generalised.geojson") %>% 
  rename(lad17cd = area_code, lad17nm = area_name)

ui <- navbarPage(
  title = div(img(src = "https://trafforddatalab.github.io/assets/logo/trafforddatalab_logo.svg", height="25", width="99"), 
              "Work<ness app"), windowTitle = "Work<ness app",
  tabPanel(title = "Isochrone map",
           div(class="shinyContainer",
               tags$head(includeCSS("styles_base.css"), includeCSS("styles_shiny.css"), includeCSS("styles_map.css"),
                         tags$style(HTML( ".leaflet-container {cursor:crosshair !important;}",
                                          "table.imd td:nth-child(2), table.imd td:nth-child(3) { text-align: right; }"))),
               leafletOutput("map", width = "100%", height = "100%"),
               absolutePanel(id = "shinyControls", class = "panel panel-default controls", fixed = TRUE, draggable = TRUE,
                             h4("Choose a measure"),
                             radioButtons(inputId = "measure",
                                          label = NULL,
                                          choices = c("Distance" = "distance", "Time" = "time"),
                                          selected = "distance"),
                             uiOutput("switch"),
                             uiOutput("range"),
                             br(),
                             actionButton("reset",
                                           label = "Clear isochrones"))))
)

server <- function(input, output,session) {
  
  output$switch <- renderUI({
    if(input$measure == "time"){
      selectInput(inputId = "mode",
                  label = NULL,
                  choices = c("Bike" = "cycling-regular",
                              "Car" = "driving-car", 
                              "Walk" = "foot-walking"),
                  selected = "cycling-regular")
    }else{
      return()
    }
  })
  
  output$range <- renderUI({
    if(input$measure == "distance"){
      sliderInput("slider", label = h5("Range (kilometres"), min = 0.5, max = 3, value = 0.5, step = 0.5, ticks = FALSE, post = " km")
    }else{
      sliderInput("slider", label = h5("Range (minutes)"), min = 5, max = 30, value = 5, step = 5, ticks = FALSE, post = " minutes")
    }
  })
  
  click <- eventReactive(input$map_click, {
    click <- input$map_click
    })

  iso <- reactive({
    iso <- ors_isochrones(locations = c(click()$lng, click()$lat), 
                          profile = 
                            if(input$measure == "distance"){
                              NULL
                          } else {
                            input$mode
                          },
                          range = 
                            if(input$measure == "distance"){
                              input$slider
                            } else {
                              input$slider*60
                            },
                          range_type = input$measure,
                          interval = 
                            if(input$measure == "distance"){
                              0.5
                          } else {
                            60*5
                          },
                          preference = 
                            if(input$measure == "distance"){
                              "shortest"
                            } else {
                              "fastest"
                            },
                          units = 
                            if(input$measure == "distance"){
                              "km"
                            } else {
                              NULL
                            },
                          geometry_simplify = FALSE)
    class(iso) <- "geo_list"
    iso <- geojson_sf(iso) %>% arrange(desc(value))
  })

  observeEvent(input$reset, {
    leafletProxy("map") %>%
      clearGroup("isochrones")
  })
  
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
                  fill = TRUE, fillColor = ~factpal(iso()$value), fillOpacity = 0,
                  stroke = TRUE, opacity = 1, color = ~factpal(iso()$value), weight = 6, 
                  dashArray = "1,13", options = pathOptions(lineCap = "round"),
                  label = if(input$measure == "time"){
                    as.character(paste0(iso()$value/60, " minutes"))
                  }else{
                    as.character(paste0(iso()$value, "m"))
                  },
                  group = "isochrones") %>%
      addAwesomeMarkers(data = click(), lat = ~lat, lng = ~lng,
                        icon = ~makeAwesomeIcon(icon = "times", library = "fa", iconColor = "red", markerColor = "white"),
                        group = "isochrones")
    
  })
  
}
    


shinyApp(ui, server)