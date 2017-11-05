## OGI - Trafford pilot app ##

library(shiny) ; library(tidyverse) ; library(sf) ; library(spdep) ; library(leaflet)

# Claimant count by sex for Lower Super Output Areas (nomis API)
df <- read_csv("data/ucjsa.csv", skip = 7) %>% 
  slice(-1) %>% 
  select(area_name = `2011 super output area - lower layer`, area_code = mnemonic, Total, Male, Female) %>% 
  gather(category, value, -c(area_code, area_name)) %>% 
  mutate(area_name = as.factor(area_name),
         category = as.factor(category),
         value = as.integer(value)) %>% 
  select(-area_code)

# GM LSOA layer (ONS Open Geography Portal)
lsoa <- st_read("https://opendata.arcgis.com/datasets/da831f80764346889837c72508f046fa_2.geojson") %>% 
  filter(lsoa11nm %in% pull(df, area_name)) %>%
  st_as_sf(crs = 4326, coords = c("long", "lat")) %>% 
  select(area_code = lsoa11cd, area_name = lsoa11nm) %>% 
  as('Spatial')

spatmatrix <- poly2nb(lsoa, queen=TRUE)
listw <- nb2listw(spatmatrix)

# GM Local Authority layer (ONS Open Geography Portal)
la <- st_read("https://opendata.arcgis.com/datasets/686603e943f948acaa13fb5d2b0f1275_3.geojson") %>% 
  filter(grepl('Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan', lad16nm)) %>% # filter by GM borough
  st_as_sf(crs = 4326, coords = c("long", "lat"))

centroids <- la %>%
  st_transform(crs = 27700) %>% 
  st_centroid() %>%
  st_coordinates() %>% 
  as.data.frame() %>% 
  st_as_sf(coords = c("X", "Y"), crs = 27700) %>% 
  st_transform(crs = 4326) 

coords <- do.call(rbind, unclass(st_geometry(centroids)))
la <- cbind(coords, la)

# GM Jobcentre Plus 
jcplus <- read_csv("https://github.com/traffordDataLab/open_data/raw/master/job_centre_plus/jobcentreplus_gm.csv") %>% 
  st_as_sf(crs = 4326, coords = c("lon", "lat"))

# -------------------------------------------------------------------------------

ui <- bootstrapPage(
  tags$head(tags$style(
    type = "text/css",
    "html, body {width:100%;height:100%}",
    "#controls {background-color: white; padding: 0 20px 20px 20px; border-radius: 15px; opacity: 0.85;}")),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE, top = 10, left = "auto", right = 20, bottom = "auto",
                width = 330, height = "auto",
                h4(paste("Count of residents claiming\n JSA or Universal Credit during\n September 2017")),
                radioButtons(inputId = "category",
                             label = NULL,
                             choices = c(levels(df$category)),
                             selected = "Total"),
                hr(),
                uiOutput("lsoaInfo")))

server <- function(input, output, session) {
  values <- reactiveValues(highlight = c())
  
  selectedData <- reactive({
    sub <- subset(df, category == input$category)
    lsoa@data <- left_join(lsoa@data, sub, by = "area_name") %>% 
      separate(area_name, c("la", "temp"), sep = " ")
    lmoran <- localmoran(lsoa$value, listw)
    lsoa$s_value <- scale(lsoa$value)  %>% as.vector()
    lsoa$lag_s_value <- lag.listw(listw, lsoa$s_value)
    lsoa$quad_sig <- NA
    lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value >= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "High-High"
    lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value <= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "Low-Low"
    lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value >= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "Low-High"
    lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value <= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "High-Low"
    lsoa@data[(lmoran[, 5] > 0.05), "quad_sig"] <- "Non-sig"  
    lsoa$quad_sig <- as.factor(lsoa$quad_sig)
    lsoa <- st_as_sf(lsoa)
  })
  
  observe({
    values$highlight <- input$map_shape_mouseover$id
  })
  
  output$lsoaInfo <- renderUI({
    if (is.null(values$highlight)) {
      return(tags$h4("Hover over an LSOA"))
    } else {
      lsoaName <- selectedData()$area_code[values$highlight == selectedData()$area_code]
      return(tags$div(
        tags$h4(lsoaName, "-", selectedData()[selectedData()$area_code == lsoaName,]$la),
        tags$h5(input$category, "claimants:", selectedData()[selectedData()$area_code == lsoaName,]$value)
      ))
    }
  })

   output$map <- renderLeaflet({
      
     leaflet() %>% 
       addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "Road map",
               options = providerTileOptions(minZoom = 10, maxZoom = 15)) %>% 
       addTiles(urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", 
               attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community | <a href="https://www.ons.gov.uk/methodology/geography/licences"> Contains OS data © Crown copyright and database right (2017)</a>', 
               group = "Satellite",
               options = providerTileOptions(minZoom = 10, maxZoom = 15)) %>%
       addTiles(urlTemplate = "", 
               attribution = '<a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "No tiles") %>% 
       fitBounds(-2.730521, 53.3281, -1.909621, 53.68573) %>%
       addLayersControl(position = 'topleft',
                       baseGroups = c("Road map", "Satellite", "No tiles"),
                       overlayGroups = c("Jobcentre Plus"), 
                       options = layersControlOptions(collapsed = FALSE)) %>% 
       hideGroup(c("Jobcentre Plus"))
  })
  
  observe({
    factpal <- colorFactor(c("#f0f0f0", "red", "blue", "cyan", "pink"),
                           levels = c("Non-sig", "High-High", "Low-Low", "Low-High", "High-Low"))
    icons <- awesomeIconList(
      `Jobcentre Plus` = makeAwesomeIcon(icon = "map-marker", library = "glyphicon", markerColor = "green", iconColor = "#FFED00"))
    
    html_legend <- "<img src='https://trafforddatalab.github.io/assets/logo/trafforddatalab_logo.svg'><svg style='width:40px;height:1px;'><small><a href=https://github.com/traffordDataLab/projects/tree/master/opengovintelligence target=_blank>Source code</a></small>"
    
    leafletProxy("map", data = selectedData()) %>%
      clearShapes() %>% clearControls() %>% clearMarkers() %>% 
      addPolygons(data = selectedData(), fillColor = ~factpal(quad_sig), fillOpacity = 0.4, 
                  stroke = TRUE, color = "black", weight = 1, layerId = ~area_code,
                  highlight = highlightOptions(color = "#FFFF00", weight = 3, opacity = 1, bringToFront = TRUE)) %>%
      addPolylines(data = la, stroke = TRUE, weight = 3, color = "#212121", opacity = 1) %>% 
      addLabelOnlyMarkers(data = la, lng = ~X1, lat = ~X2, label = ~as.character(lad16nm), 
                          labelOptions = labelOptions(noHide = T, textOnly = T, direction = "bottom",
                                                      style = list(
                                                        "color"="white",
                                                        "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>%
      addAwesomeMarkers(data = jcplus, popup = ~as.character(name), icon = icons, group = "Jobcentre Plus", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
      addLegend(position = "bottomleft", colors = c("#f0f0f0", "red", "blue", "cyan", "pink"),
                labels = c("Non-sig", "High-High", "Low-Low", "Low-High", "High-Low"), opacity = 0.4,
                title = paste0(input$category, " claimants")) %>%
      addControl(html = html_legend, position = "bottomright")
  })
}

shinyApp(ui, server)