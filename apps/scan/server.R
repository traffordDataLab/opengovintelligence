## Scan app ##

server <- function(input, output, session) {
  values <- reactiveValues(highlight = c())
  
  filteredData <- reactive({
    
    if("Greater Manchester" == input$la){
      sub <- filter(df, measure == input$measure)
      lsoa <- GM_lsoa
      lsoa@data <- left_join(lsoa@data, sub, by = "lsoa11cd")
      lsoa <- lisa_stats(lsoa, variable = "value", queen = TRUE, sig = 0.01) %>% 
        st_as_sf(lsoa)
    
    } else if ("Greater Manchester" != input$la){
    sub <- filter(df, measure == input$measure & lad17nm == input$la) %>% select(lsoa11cd, measure, value)
    lsoa <- GM_lsoa[GM_lsoa@data$lad17nm == input$la, ]
    lsoa@data <- left_join(lsoa@data, sub, by = "lsoa11cd")
    lsoa <- lisa_stats(lsoa, variable = "value", queen = TRUE, sig = 0.01) %>% 
      st_as_sf(lsoa)
    }
  })
  
  observe({
    values$highlight <- input$map_shape_mouseover$id
  })
  
  output$info <- renderUI({
    
    if("Greater Manchester" == input$la){
    if (is.null(values$highlight)) {
      return(tags$h4("Hover over a neighbourhood for more information"))
    } else {
      lsoaCode <- filteredData()$lsoa11cd[values$highlight == GM_lsoa$lsoa11cd]
      return(tags$div(
        HTML(paste(tags$h4("LSOA: ", lsoaCode))),
        HTML(paste("in ", tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$wd17nm), " Ward", sep = "")),
        br(), br(),
        HTML(paste(tags$strong(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$measure), ":", sep = "")),
        br(),
        HTML(paste(tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$value), 
                   " (", filteredData()[filteredData()$lsoa11cd == lsoaCode,]$quad, ")", sep = "")),
        br(), hr(),
        tags$h4("Index of Multiple Deprivation (2015)"),
        HTML("<table class='imd' style='width: 100%' callspacing='7'>
             <tr>
             <th style='width: 70%'>Index/Domain</th>
             <th style='width: 15%; text-align: right'>Rank</th>
             <th style='width: 15%; text-align: right'>Decile</th>
             </tr> 
             <tr>
             <td>", "Index of Multiple Deprivation", "</td>
             <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$rank, format="f", big.mark = ",", digits=0), "</td>
             <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$decile, "</td>
             </tr>
             <td>", "Income", "</td>
             <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Income")$rank, format="f", big.mark = ",", digits=0), "</td>
             <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Income")$decile, "</td>
             </tr>
             <td>", "Employment", "</td>
             <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Employment")$rank, format="f", big.mark = ",", digits=0), "</td>
             <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Employment")$decile, "</td>
             </tr>
             <td>", "Education, Skills and Training", "</td>
             <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Education, Skills and Training")$rank, format="f", big.mark = ",", digits=0), "</td>
             <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Education, Skills and Training")$decile, "</td>
             </tr>
             <td>", "Health Deprivation and Disability", "</td>
             <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Health Deprivation and Disability")$rank, format="f", big.mark = ",", digits=0), "</td>
             <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Health Deprivation and Disability")$decile, "</td>
             </tr>
             <td>", "Crime", "</td>
             <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$rank, format="f", big.mark = ",", digits=0), "</td>
             <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$decile, "</td>
             </tr>
             <td>", "Barriers to Housing and Services", "</td>
             <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Crime")$rank, format="f", big.mark = ",", digits=0), "</td>
             <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Crime")$decile, "</td>
             </tr>
             <td>", "Living Environment", "</td>
             <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Living Environment")$rank, format="f", big.mark = ",", digits=0), "</td>
             <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Living Environment")$decile, "</td>
             </tr>
             </table>")
        ))
    }
      
    } else if ("Greater Manchester" != input$la){
      if (is.null(values$highlight)) {
        return(tags$h4("then hover over an LSOA"))
      } else {
        lsoa <- GM_lsoa[GM_lsoa@data$lad17nm == input$la, ]
        lsoaCode <- filteredData()$lsoa11cd[values$highlight == lsoa$lsoa11cd]
        return(tags$div(
          HTML(paste(tags$h4("LSOA: ", lsoaCode))),
          HTML(paste("in ", tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$wd17nm), " Ward", sep = "")),
          br(), br(),
          HTML(paste(tags$strong(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$measure), ":", sep = "")),
          br(),
          HTML(paste(tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$value), 
                     " (", filteredData()[filteredData()$lsoa11cd == lsoaCode,]$quad, ")", sep = "")),
          br(), hr(),
          tags$h4("Index of Multiple Deprivation (2015)"),
          HTML("<table class='imd' style='width: 100%' callspacing='7'>
               <tr>
               <th style='width: 70%'>Index/Domain</th>
               <th style='width: 15%; text-align: right'>Rank</th>
               <th style='width: 15%; text-align: right'>Decile</th>
               </tr> 
               <tr>
               <td>", "Index of Multiple Deprivation", "</td>
               <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$rank, format="f", big.mark = ",", digits=0), "</td>
               <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$decile, "</td>
               </tr>
               <td>", "Income", "</td>
               <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Income")$rank, format="f", big.mark = ",", digits=0), "</td>
               <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Income")$decile, "</td>
               </tr>
               <td>", "Employment", "</td>
               <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Employment")$rank, format="f", big.mark = ",", digits=0), "</td>
               <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Employment")$decile, "</td>
               </tr>
               <td>", "Education, Skills and Training", "</td>
               <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Education, Skills and Training")$rank, format="f", big.mark = ",", digits=0), "</td>
               <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Education, Skills and Training")$decile, "</td>
               </tr>
               <td>", "Health Deprivation and Disability", "</td>
               <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Health Deprivation and Disability")$rank, format="f", big.mark = ",", digits=0), "</td>
               <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Health Deprivation and Disability")$decile, "</td>
               </tr>
               <td>", "Crime", "</td>
               <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$rank, format="f", big.mark = ",", digits=0), "</td>
               <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$decile, "</td>
               </tr>
               <td>", "Barriers to Housing and Services", "</td>
               <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Crime")$rank, format="f", big.mark = ",", digits=0), "</td>
               <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Crime")$decile, "</td>
               </tr>
               <td>", "Living Environment", "</td>
               <td>", formatC(subset(imd, lsoa11cd == lsoaCode & index_domain == "Living Environment")$rank, format="f", big.mark = ",", digits=0), "</td>
               <td>", subset(imd, lsoa11cd == lsoaCode & index_domain == "Living Environment")$decile, "</td>
               </tr>
               </table>")
          ))
      }
    }
    })
  
  output$map <- renderLeaflet({
    
    leaflet() %>% 
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "Low Detail",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>  | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "High Detail",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", 
               attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community | <a href="https://www.ons.gov.uk/methodology/geography/licences"> Contains OS data © Crown copyright and database right (2018)</a>', 
               group = "Satellite",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>%
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}{r}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "Dark",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "", 
               attribution = '<a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "None") %>% 
      setView(-2.28417866956407, 53.5151885751656, zoom = 11) %>% 
      addLayersControl(position = 'topleft',
                       baseGroups = c("Low Detail", "High Detail", "Satellite", "Dark", "None"),
                       overlayGroups = c("Jobcentre Plus"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("Jobcentre Plus")) %>% 
      htmlwidgets::onRender(
        " function(el, t) {
        var myMap = this;
        myMap._container.style['background'] = '#ffffff';}")
    })
  
  observe({
    factpal <- colorFactor(c("#F0F0F0", "#E93F36", "#2144F5", "#9794F8", "#EF9493"),
                           levels = c("Not significant", "High-High", "Low-Low", "Low-High", "High-Low"),
                           ordered = TRUE)
    
    icon <- makeIcon(iconUrl = "icon.jpg", iconWidth = 36, iconHeight = 32, iconAnchorX = 16, iconAnchorY = 16)
    
    popup = ~paste0(
      "<div class='popupContainer'>",
      "<h5>", jcplus$Name, "</h5>",
      "<table class='popupLayout'>",
      "<tr>",
      "<td>Address</td>",
      "<td>", jcplus$Address, "</td>",
      "</tr>",
      "<tr>",
      "<td>Postcode</td>",
      "<td>", jcplus$Postcode, "</td>",
      "</tr>",
      "</table>",
      "</div>"
    )
  
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>% clearControls() %>% clearMarkers() %>% 
      addPolygons(data = filteredData(), fillColor = ~factpal(quad_sig), fillOpacity = 0.4, 
                  stroke = TRUE, color = "black", weight = 1, layerId = ~lsoa11cd,
                  highlight = highlightOptions(color = "#FFFF00", weight = 3, opacity = 1, bringToFront = TRUE)) %>%
      addPolylines(data = la, stroke = TRUE, weight = 3, color = "#212121", opacity = 1) %>% 
      addLabelOnlyMarkers(data = la, lng = ~centroid_lng, lat = ~centroid_lat, label = ~as.character(lad17nm), 
                          labelOptions = labelOptions(noHide = T, textOnly = T, direction = "bottom",
                                                      style = list(
                                                        "color"="white",
                                                        "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>%
      addMarkers(data = jcplus, popup = popup, icon = icon, group = "Jobcentre Plus", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addLegend(position = "bottomleft", colors = c("#F0F0F0", "#E93F36", "#2144F5", "#9794F8", "#EF9493"),
                labels = 
                  c(paste0("Not significant (", formatC(sum(filteredData()$quad_sig == "Not significant"), format="f", big.mark = ",", digits=0), ")"),
                    paste0("High-High (", sum(filteredData()$quad_sig == "High-High"), ")"),  
                    paste0("Low-Low (", sum(filteredData()$quad_sig == "Low-Low"), ")"),
                    paste0("Low-High (", sum(filteredData()$quad_sig == "Low-High"), ")"),
                    paste0("High-Low (", sum(filteredData()$quad_sig == "High-Low "), ")")), 
                opacity = 0.4,
                title = "LISA cluster map")
  })
  
}