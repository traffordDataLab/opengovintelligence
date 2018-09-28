## Work<ness app ##

server <- function(input, output, session) {
  values <- reactiveValues(highlight = c())
  
  # Clusters ---------------------------
  
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
    values$highlight <- input$cluster_map_shape_mouseover$id
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
  
  output$cluster_map <- renderLeaflet({
    
    leaflet() %>% 
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "Low Detail",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>  | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "High Detail",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", 
               attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community | <a href="https://www.ons.gov.uk/methodology/geography/licences"> Contains OS data © Crown copyright and database right (2017)</a>', 
               group = "Satellite",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>%
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}{r}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "Dark",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "", 
               attribution = '<a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "None") %>% 
      setView(-2.28417866956407, 53.5151885751656, zoom = 11) %>% 
      addLayersControl(position = 'topleft',
                       baseGroups = c("Low Detail", "High Detail", "Satellite", "Dark", "None"),
                       overlayGroups = c("Jobcentre Plus", "Probation offices", "GPs", "Food banks", "Betting shops"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("Jobcentre Plus", "Probation offices", "GPs", "Food banks", "Betting shops")) %>% 
      htmlwidgets::onRender(
        " function(el, t) {
        var myMap = this;
        myMap._container.style['background'] = '#ffffff';}")
    })
  
  observe({
    factpal <- colorFactor(c("#F0F0F0", "#E93F36", "#2144F5", "#9794F8", "#EF9493"),
                           levels = c("Not significant", "High-High", "Low-Low", "Low-High", "High-Low"),
                           ordered = TRUE)
    
    leafletProxy("cluster_map", data = filteredData()) %>%
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
      addAwesomeMarkers(data = jcplus, popup = jcplus_popup, icon = ~makeAwesomeIcon(icon = "building-o", library = "fa", markerColor = "green", iconColor = "#fff"), group = "Jobcentre Plus", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addAwesomeMarkers(data = probation, popup = probation_popup, icon = ~makeAwesomeIcon(icon = "balance-scale", library = "fa", markerColor = "black", iconColor = "#fff"), group = "Probation offices", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addAwesomeMarkers(data = gp, popup = gp_popup, icon = ~makeAwesomeIcon(icon = "stethoscope", library = "fa", markerColor = "pink", iconColor = "#fff"), group = "GPs", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addAwesomeMarkers(data = food_bank, popup = food_bank_popup, icon = ~makeAwesomeIcon(icon = "fa-cutlery", library = "fa", markerColor = "orange", iconColor = "#fff"), group = "Food banks", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addAwesomeMarkers(data = betting, popup = betting_popup, icon = ~makeAwesomeIcon(icon = "money", library = "fa", markerColor = "darkpurple", iconColor = "#fff"), group = "Betting shops", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
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
  
  # Trends ---------------------------   
  
  output$choose_area <- renderUI({
    if(input$multiple) {
      title = NULL
      options = list(maxItems = 4)
    } else {
      title = NULL
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
      theme(panel.grid.major.y = element_blank(),
            plot.title = element_text(size = 16, colour = "#757575", face = "bold", hjust = 0.5, vjust = 5),
            axis.title = element_blank(),
            legend.title = element_blank())
    
    if(input$multiple) {
      if(input$facet) {
        p + geom_line(aes(colour = area_name), size = 1) +
          labs(title = paste("Proportion of residents claiming JSA or Universal Credit")) +
          facet_wrap(~area_name) +
          theme(legend.position = "none") +
          theme(panel.spacing = unit(1, "lines"),
                strip.text = element_text(size = 10, vjust = 1))
      } else {
        p +  geom_line(aes(colour = area_name), size = 1) +
          labs(title = paste("Proportion of residents claiming JSA or Universal Credit"))
      }
    } else {
      p + geom_line(colour = "#1b9e77", size = 1) +
        labs(title = paste("Proportion of residents claiming JSA or Universal Credit in", area_data()$area_name))
    }
    
  })
  
  output$area_table <- renderDT({
    if(is.null(area_data())) {
      return(NULL)
    }
    
    area_data() %>% 
      arrange(desc(date)) %>% 
      DT::datatable(filter = "top", extensions = c("Buttons", "Scroller"),
                    rownames = FALSE,
                    style = "bootstrap",
                    class = "compact",
                    width = "100%",
                    options = list(
                      dom = "Blrtip",
                      deferRender = TRUE,
                      scrollY = 300,
                      scroller = TRUE,
                      columnDefs = list(list(visible = FALSE, targets = c(1))),
                      buttons = list(I("colvis"), "csv", "excel")),
                    colnames = c("Date", "Area code", "Area name", "Proportion (%)"))
    })
  
  # Reachability ---------------------------   
  
  output$range <- renderUI({
    if(input$unit == "distance"){
      sliderInput("distance_slider", 
                  label = h5("Range (kilometres)"), min = 0.5, max = 3, value = 0.5, step = 0.5, 
                  ticks = FALSE, post = " km")
    }else{
      NULL
    }
  })
  
  click <- eventReactive(input$isochrone_map_click,{
    event <- input$isochrone_map_click
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
    sf <- geojson_sf(results) %>% arrange(desc(value))
  })
  
  observeEvent(input$reset, {
    leafletProxy("isochrone_map") %>% clearGroup("isochrones")
  })
  
  output$isochrone_map <- renderLeaflet({
    leaflet() %>% 
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "Low Detail",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>  | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "High Detail",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", 
               attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community | <a href="https://www.ons.gov.uk/methodology/geography/licences"> Contains OS data © Crown copyright and database right (2017)</a>', 
               group = "Satellite",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>%
      addTiles(urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}{r}.png",
               attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://cartodb.com/attributions">CartoDB</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "Dark",
               options = providerTileOptions(minZoom = 10, maxZoom = 16)) %>% 
      addTiles(urlTemplate = "", 
               attribution = '<a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "None") %>% 
      setView(-2.28417866956407, 53.5151885751656, zoom = 11) %>% 
      addPolylines(data = GM_lsoa, stroke = TRUE, weight = 1.2, color = "#212121", opacity = 1) %>% 
      addPolylines(data = la, stroke = TRUE, weight = 3, color = "#212121", opacity = 1) %>% 
      addLabelOnlyMarkers(data = la, lng = ~centroid_lng, lat = ~centroid_lat, label = ~as.character(lad17nm), 
                          labelOptions = labelOptions(noHide = T, textOnly = T, direction = "bottom",
                                                      style = list(
                                                        "color"="white",
                                                        "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>%
      addAwesomeMarkers(data = jcplus, popup = jcplus_popup, icon = ~makeAwesomeIcon(icon = "building-o", library = "fa", markerColor = "green", iconColor = "#fff"), group = "Jobcentre Plus", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addAwesomeMarkers(data = probation, popup = probation_popup, icon = ~makeAwesomeIcon(icon = "balance-scale", library = "fa", markerColor = "black", iconColor = "#fff"), group = "Probation offices", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addAwesomeMarkers(data = gp, popup = gp_popup, icon = ~makeAwesomeIcon(icon = "stethoscope", library = "fa", markerColor = "pink", iconColor = "#fff"), group = "GPs", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addAwesomeMarkers(data = food_bank, popup = food_bank_popup, icon = ~makeAwesomeIcon(icon = "fa-cutlery", library = "fa", markerColor = "orange", iconColor = "#fff"), group = "Food banks", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addAwesomeMarkers(data = betting, popup = betting_popup, icon = ~makeAwesomeIcon(icon = "money", library = "fa", markerColor = "darkpurple", iconColor = "#fff"), group = "Betting shops", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
      addLayersControl(position = 'topleft',
                       baseGroups = c("Low Detail", "High Detail", "Satellite", "Dark", "None"),
                       overlayGroups = c("Jobcentre Plus", "Probation offices", "GPs", "Food banks", "Betting shops"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("Jobcentre Plus", "Probation offices", "GPs", "Food banks", "Betting shops")) %>% 
      htmlwidgets::onRender(
        " function(el, t) {
        var myMap = this;
        myMap._container.style['background'] = '#ffffff';}")
})
  
  observe({
    
    factpal <- colorFactor(palette = c( "#7f2704","#a63603","#d94801","#f16913","#fd8d3c","#fdae6b"), 
                           levels = factor(iso()$value), ordered = TRUE)
    
    map <- leafletProxy('isochrone_map') %>%
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
  
  output$downloadGeoJSON <- downloadHandler(
    
    filename = function() {
      paste("export.geojson")
    },
    content = function(file) {
      st_write(iso(), file, driver = "GeoJSON")
    }
  )
    
}