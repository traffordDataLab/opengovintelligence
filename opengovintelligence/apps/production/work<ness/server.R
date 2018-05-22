## Work<ness app ##

# Server ---------------------------

server <- function(input, output, session) {
  values <- reactiveValues(highlight = c())
  
  # Maps ---------------------------
  
  filteredData <- reactive({
    
    if("Greater Manchester" == input$la){
      sub <- filter(df, measure == input$measure)
      lsoa <- GM_lsoa
      lsoa@data <- left_join(lsoa@data, sub, by = "lsoa11cd")
      nb <- poly2nb(lsoa, queen = TRUE)
      lw <- nb2listw(nb)
      lmoran <- localmoran(lsoa$value, lw)
      lsoa$s_value <- scale(lsoa$value)  %>% as.vector()
      lsoa$lag_s_value <- lag.listw(lw, lsoa$s_value)
      
      lsoa$quad <- NA
      lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value >= 0), "quad"] <- "High-High"
      lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value <= 0), "quad"] <- "Low-Low"
      lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value >= 0), "quad"] <- "Low-High"
      lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value <= 0), "quad"] <- "High-Low"
      
      lsoa$quad_sig <- NA
      lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value >= 0) & (lmoran[, 5] <= 0.01), "quad_sig"] <- "High-High"
      lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value <= 0) & (lmoran[, 5] <= 0.01), "quad_sig"] <- "Low-Low"
      lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value >= 0) & (lmoran[, 5] <= 0.01), "quad_sig"] <- "Low-High"
      lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value <= 0) & (lmoran[, 5] <= 0.01), "quad_sig"] <- "High-Low"
      lsoa@data[(lmoran[, 5] > 0.01), "quad_sig"] <- "Not significant"
      lsoa$quad_sig <- as.factor(lsoa$quad_sig)
      lsoa <- st_as_sf(lsoa)
    
    } else if ("Greater Manchester" != input$la){
    sub <- filter(df, measure == input$measure & lad16nm == input$la) %>% select(lsoa11cd, measure, value)
    lsoa <- GM_lsoa[GM_lsoa@data$lad17nm == input$la, ]
    lsoa@data <- left_join(lsoa@data, sub, by = "lsoa11cd")
    nb <- poly2nb(lsoa, queen = TRUE)
    lw <- nb2listw(nb)
    lmoran <- localmoran(lsoa$value, lw)
    lsoa$s_value <- scale(lsoa$value)  %>% as.vector()
    lsoa$lag_s_value <- lag.listw(lw, lsoa$s_value)
    
    lsoa$quad <- NA
    lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value >= 0), "quad"] <- "High-High"
    lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value <= 0), "quad"] <- "Low-Low"
    lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value >= 0), "quad"] <- "Low-High"
    lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value <= 0), "quad"] <- "High-Low"
    
    lsoa$quad_sig <- NA
    lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value >= 0) & (lmoran[, 5] <= 0.01), "quad_sig"] <- "High-High"
    lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value <= 0) & (lmoran[, 5] <= 0.01), "quad_sig"] <- "Low-Low"
    lsoa[(lsoa$s_value <= 0 & lsoa$lag_s_value >= 0) & (lmoran[, 5] <= 0.01), "quad_sig"] <- "Low-High"
    lsoa[(lsoa$s_value >= 0 & lsoa$lag_s_value <= 0) & (lmoran[, 5] <= 0.01), "quad_sig"] <- "High-Low"
    lsoa@data[(lmoran[, 5] > 0.01), "quad_sig"] <- "Not significant"
    lsoa$quad_sig <- as.factor(lsoa$quad_sig)
    lsoa <- st_as_sf(lsoa)
    }
  })
  
  observe({
    values$highlight <- input$map_shape_mouseover$id
  })
  
  output$info <- renderUI({
    
    if("Greater Manchester" == input$la){
    if (is.null(values$highlight)) {
      return(tags$h4("then hover over an LSOA"))
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
      addLayersControl(position = 'topleft',
                       baseGroups = c("CartoDB", "OpenStreetMap", "Satellite", "No background"),
                       overlayGroups = c("Jobcentre Plus", "Gambling premises", "GPs"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("Jobcentre Plus", "Gambling premises", "GPs")) %>% 
      htmlwidgets::onRender(
        " function(el, t) {
        var myMap = this;
        myMap._container.style['background'] = '#ffffff';}")
    })
  
  observe({
    factpal <- colorFactor(c("#F0F0F0", "#E93F36", "#2144F5", "#9794F8", "#EF9493"),
                           levels = c("Not significant", "High-High", "Low-Low", "Low-High", "High-Low"),
                           ordered = TRUE)
    
    icon_jcplus <- makeAwesomeIcon(icon = "building-o", library = "fa", markerColor = "green", iconColor = "#fff")
    icon_gambling <- makeAwesomeIcon(icon = "money", library = "fa", markerColor = "black", iconColor = "#fff")
    icon_gp <- makeAwesomeIcon(icon = "stethoscope", library = "fa", markerColor = "darkpurple", iconColor = "#fff")
    
    
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
      addAwesomeMarkers(data = jcplus, popup = ~as.character(name), icon = icon_jcplus, group = "Jobcentre Plus", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
      addAwesomeMarkers(data = gambling, popup = ~as.character(name), icon = icon_gambling, group = "Gambling premises", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
      addAwesomeMarkers(data = gp, popup = ~as.character(name), icon = icon_gp, group = "GPs", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
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
  
  # Charts ---------------------------   
  
  output$choose_area <- renderUI({
    if(input$multiple) {
      title = "Select areas"
      options = list(maxItems = 4)
    } else {
      title = "Select an area"
      options = NULL
    }
    selectizeInput(inputId = "GM_areas", 
                   title, 
                   multiple = input$multiple, options = options,
                   as.list(levels(df_ts$area_name), selected = levels(df_ts$area_name)))
  })
  
  area_data  <- reactive({
    if(is.null(input$GM_areas)) {
      return(NULL)
    }
    filter(df_ts, area_name %in% input$GM_areas)
  })
  
  output$ggplot_plot <- renderPlot({
    if(is.null(area_data())) {
      return(NULL)
    }
    
    p <- ggplot(area_data(), aes(x = date, y = value)) + 
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))), 
                         limits = c(0, max(area_data()$value)), labels = function(x){ paste0(x, "%") }, 
                         position = "right") +
      scale_colour_brewer(palette = "Dark2") +
      theme_lab() +
      theme(panel.grid.major.x = element_blank(),
            plot.subtitle = element_text(margin = margin(b = 12)),
            axis.title = element_blank(),
            legend.position = "bottom", legend.title = element_blank())
    
    if(input$multiple) {
      if(input$facet) {
        p + geom_line(aes(colour = area_name)) +
          geom_point(aes(colour = area_name)) +
          labs(title = paste("Proportion of residents claiming JSA or Universal Credit")) +
          facet_wrap(~area_name) +
          theme(legend.position = "none")
      } else {
        p +  geom_line(aes(colour = area_name)) +
          geom_point(aes(colour = area_name)) +
          labs(title = paste("Proportion of residents claiming JSA or Universal Credit"))
      }
    } else {
      p + geom_line(colour = "#1b9e77") +
        geom_point(colour = "#1b9e77") +
        labs(title = paste("Proportion of residents claiming JSA or Universal Credit in", area_data()$area_name)) 
    }
    
  })
  
  output$area_table <- DT::renderDataTable({
    area_data()
    
  }, rownames = FALSE, options = list(pageLength = 10, dom = 'tip',
                                      initComplete = JS(
                                        "function(settings, json) {",
                                        "$(this.api().table().header()).css({'background-color': '#F5F5F5', 'color': '#212121'});",
                                        "}")))
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data_download.csv")
    },
    content = function(file) {
      write.csv(area_data(), file, row.names = FALSE)
    }
  )
    }