## Scan ##

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
    values$highlight <- input$map_shape_click$id
  })
  
  # dynamic CubiQL query of 2015 Indices of Multiple Deprivation for individual LSOAs
  imd <- reactive({
    client <- GraphqlClient$new(url = "http://cubiql.gmdatastore.org.uk/graphql")
    
    qry <- Query$new()
    qry$query('query', 
              paste0(
              '
              {
              cubiql {
              dataset_indices_of_deprivation_2015 {
              observations(dimensions: {reference_area: "http://statistics.data.gov.uk/id/statistical-geography/',
              values$highlight, '"}) {
              page(first: 500) {
              observation {
              reference_area {
              label
              }
              score
              rank
              decile
              indices_of_deprivation
              measure_type
              }
              }
              }
              }
              }
              }
              '))
    
    response <- fromJSON(client$exec(qry$queries$query), flatten = TRUE)
    
    df <- map_df(response$data$cubiql$dataset_indices_of_deprivation_2015$observations$page, as_data_frame) %>% 
      mutate(index_domain = sub(".*/", "", indices_of_deprivation),
             index_domain, index_domain = 
               case_when(
                 index_domain == "barrierstohousservices" ~ "Barriers to Housing and Services",
                 index_domain == "crime" ~ "Crime",
                 index_domain == "educskilltraindepriv" ~ "Education, Skills and Training",
                 index_domain == "employmentdeprivation" ~ "Employment",
                 index_domain == "healthdeprivdisability" ~ "Health Deprivation and Disability",
                 index_domain == "idaci" ~ "Income Deprivation Affecting Children Index (IDACI)",
                 index_domain == "idaopi" ~ "Income Deprivation Affecting Older People Index (IDAOPI)",
                 index_domain == "incomedeprivation" ~ "Income",
                 index_domain == "combineddeprivation" ~ "Index of Multiple Deprivation",
                 index_domain == "livingenvdepriv" ~ "Living Environment"
               )) %>% 
      filter(!index_domain %in% c("Income Deprivation Affecting Children Index (IDACI)", 
                                  "Income Deprivation Affecting Older People Index (IDAOPI)")) %>% 
      select(lsoa11cd = reference_area.label,
             index_domain,
             decile, rank) %>% 
      gather(type, value, -lsoa11cd, -index_domain) %>% 
      filter(!is.na(value)) %>% 
      spread(type, value) %>% 
      mutate(lsoa11cd = factor(lsoa11cd),
             index_domain = factor(index_domain),
             decile = factor(decile, levels = 1:10),
             rank = as.integer(rank))
  })
  
  output$info <- renderUI({
    
    if("Greater Manchester" == input$la){
    if (is.null(values$highlight)) {
      return(tags$h4("Click on a neighbourhood for more information"))
    } else {
      lsoaCode <- filteredData()$lsoa11cd[values$highlight == GM_lsoa$lsoa11cd]
      return(tags$div(
        HTML(paste0(tags$h4("LSOA: ", lsoaCode))),
        HTML(paste0("in ", tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$wd17nm), " Ward")),
        br(), br(),
        HTML(paste0(tags$strong(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$measure), ":")),
        br(),
        HTML(paste0(tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$value), 
                   " (", filteredData()[filteredData()$lsoa11cd == lsoaCode,]$quad, ")")),
        br(), hr(),
        tags$strong("IMD 2015"),
        HTML("<table class='imd' style='width: 100%' callspacing='7'>
             <tr>
             <th style='width: 70%; font-weight: normal; font-style: italic'>Index/Domain</th>
             <th style='width: 15%; text-align: left; font-weight: normal; font-style: italic'>Decile</th>
             <th style='width: 15%; text-align: left; font-weight: normal; font-style: italic'>Rank</th>
             </tr> 
             <tr>
             <td>", "Index of Multiple Deprivation", "</td>
             <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$decile, "</td>
             <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$rank, format="f", big.mark = ",", digits=0), "</td>
             </tr>
             <td>", "Barriers to Housing and Services", "</td>
             <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Barriers to Housing and Services")$decile, "</td>
             <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Barriers to Housing and Services")$rank, format="f", big.mark = ",", digits=0), "</td>
             </tr>
             <td>", "Crime", "</td>
             <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Crime")$decile, "</td>
             <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Crime")$rank, format="f", big.mark = ",", digits=0), "</td>
             </tr>
             <td>", "Education, Skills and Training", "</td>
             <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Education, Skills and Training")$decile, "</td>
             <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Education, Skills and Training")$rank, format="f", big.mark = ",", digits=0), "</td>
             </tr>
             <td>", "Employment", "</td>
             <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Employment")$decile, "</td>
             <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Employment")$rank, format="f", big.mark = ",", digits=0), "</td>
             </tr>
             <td>", "Health Deprivation and Disability", "</td>
             <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Health Deprivation and Disability")$decile, "</td>
             <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Health Deprivation and Disability")$rank, format="f", big.mark = ",", digits=0), "</td>
             </tr>
             <td>", "Income", "</td>
             <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Income")$decile, "</td>
             <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Income")$rank, format="f", big.mark = ",", digits=0), "</td>
             </tr>
             <td>", "Living Environment", "</td>
             <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Living Environment")$decile, "</td>
             <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Living Environment")$rank, format="f", big.mark = ",", digits=0), "</td>
             </tr>
             </table>")
        ))
    }
      
    } else if ("Greater Manchester" != input$la){
      if (is.null(values$highlight)) {
        return(tags$h4("Click on a neighbourhood for more information"))
      } else {
        lsoa <- GM_lsoa[GM_lsoa@data$lad17nm == input$la, ]
        lsoaCode <- filteredData()$lsoa11cd[values$highlight == lsoa$lsoa11cd]
        return(tags$div(
          HTML(paste0(tags$h4("LSOA: ", lsoaCode))),
          HTML(paste0("in ", tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$wd17nm), " Ward")),
          br(), br(),
          HTML(paste0(tags$strong(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$measure), ":")),
          br(),
          HTML(paste0(tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$value), 
                     " (", filteredData()[filteredData()$lsoa11cd == lsoaCode,]$quad, ")")),
          br(), hr(),
          tags$strong("IMD 2015"),
          HTML("<table class='imd' style='width: 100%' callspacing='7'>
               <tr>
               <th style='width: 70%; font-weight: normal; font-style: italic'>Index/Domain</th>
               <th style='width: 15%; text-align: left; font-weight: normal; font-style: italic'>Decile</th>
               <th style='width: 15%; text-align: left; font-weight: normal; font-style: italic'>Rank</th>
               </tr> 
               <tr>
               <td>", "Index of Multiple Deprivation", "</td>
               <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$decile, "</td>
               <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Index of Multiple Deprivation")$rank, format="f", big.mark = ",", digits=0), "</td>
               </tr>
               <td>", "Barriers to Housing and Services", "</td>
               <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Barriers to Housing and Services")$decile, "</td>
               <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Barriers to Housing and Services")$rank, format="f", big.mark = ",", digits=0), "</td>
               </tr>
               <td>", "Crime", "</td>
               <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Crime")$decile, "</td>
               <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Crime")$rank, format="f", big.mark = ",", digits=0), "</td>
               </tr>
               <td>", "Education, Skills and Training", "</td>
               <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Education, Skills and Training")$decile, "</td>
               <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Education, Skills and Training")$rank, format="f", big.mark = ",", digits=0), "</td>
               </tr>
               <td>", "Employment", "</td>
               <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Employment")$decile, "</td>
               <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Employment")$rank, format="f", big.mark = ",", digits=0), "</td>
               </tr>
               <td>", "Health Deprivation and Disability", "</td>
               <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Health Deprivation and Disability")$decile, "</td>
               <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Health Deprivation and Disability")$rank, format="f", big.mark = ",", digits=0), "</td>
               </tr>
               <td>", "Income", "</td>
               <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Income")$decile, "</td>
               <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Income")$rank, format="f", big.mark = ",", digits=0), "</td>
               </tr>
               <td>", "Living Environment", "</td>
               <td>", subset(imd(), lsoa11cd == lsoaCode & index_domain == "Living Environment")$decile, "</td>
               <td>", formatC(subset(imd(), lsoa11cd == lsoaCode & index_domain == "Living Environment")$rank, format="f", big.mark = ",", digits=0), "</td>
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
      addTiles(urlTemplate = "", 
               attribution = '<a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2018)</a>',
               group = "None") %>% 
      setView(-2.28417866956407, 53.5151885751656, zoom = 11) %>%
      addLayersControl(position = 'topleft',
                       baseGroups = c("Low Detail", "High Detail", "Satellite", "None"),
                       overlayGroups = c("Jobcentre Plus"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("Jobcentre Plus")) %>% 
      htmlwidgets::onRender(
        " function(el, t) {
        var myMap = this;
        myMap._container.style['background'] = '#ffffff';}")
    })
  
  observe({
    req(values$highlight)
    map <- leafletProxy("map") %>%
      removeShape("highlighted") %>%
      addPolylines(data = filteredData()[filteredData()$lsoa11cd == values$highlight, ], fill = FALSE,
                  color = "#e24a90", weight = 2, opacity = 1, layerId = "highlighted")
  })
  
  observeEvent(input$la, {
    values$highlight <- NULL
  })
  
  observe({
    factpal <- colorFactor(c("#F0F0F0", "#E93F36", "#2144F5", "#9794F8", "#EF9493"),
                           levels = c("Not significant", "High-High", "Low-Low", "Low-High", "High-Low"),
                           ordered = TRUE)
    
    icon <- makeIcon(iconUrl = "icon.jpg", iconWidth = 36, iconHeight = 32, iconAnchorX = 16, iconAnchorY = 16)

    if("Greater Manchester" == input$la){
      popup = ~paste0(
        "<div class='popupContainer'>",
        "<h5>", jcplus$name, "</h5>",
        "<table class='popupLayout'>",
        "<tr>",
        "<td>Address</td>",
        "<td>", jcplus$address, "</td>",
        "</tr>",
        "<tr>",
        "<td>Postcode</td>",
        "<td>", jcplus$postcode, "</td>",
        "</tr>",
        "</table>",
        "</div>"
      )
      
      leafletProxy("map", data = filteredData()) %>%
        clearShapes() %>% clearControls() %>% clearMarkers() %>% 
        addPolygons(data = filteredData(), fillColor = ~factpal(quad_sig), fillOpacity = 0.4, 
                    stroke = TRUE, color = "#212121", weight = 1, layerId = ~lsoa11cd) %>%
        addPolylines(data = la, stroke = TRUE, weight = 2, color = "#212121", opacity = 1) %>% 
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
                  title = input$measure) }
    else {
      popup = ~paste0(
        "<div class='popupContainer'>",
        "<h5>", jcplus[jcplus$area_name == input$la, ]$name, "</h5>",
        "<table class='popupLayout'>",
        "<tr>",
        "<td>Address</td>",
        "<td>", jcplus[jcplus$area_name == input$la, ]$address, "</td>",
        "</tr>",
        "<tr>",
        "<td>Postcode</td>",
        "<td>", jcplus[jcplus$area_name == input$la, ]$postcode, "</td>",
        "</tr>",
        "</table>",
        "</div>"
      )
      
      bbox <- st_bbox(la[la$lad17nm == input$la, ]) %>% as.vector()
      leafletProxy("map", data = filteredData()) %>%
        clearShapes() %>% clearControls() %>% clearMarkers() %>% 
        fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) %>%  
        addPolygons(data = filteredData(), fillColor = ~factpal(quad_sig), fillOpacity = 0.4, 
                  stroke = TRUE, color = "#212121", weight = 1, layerId = ~lsoa11cd) %>%
        addPolylines(data = la[la$lad17nm == input$la, ], stroke = TRUE, weight = 2, color = "#212121", opacity = 1) %>% 
        addLabelOnlyMarkers(data = la[la$lad17nm == input$la, ], lng = ~centroid_lng, lat = ~centroid_lat, label = ~as.character(lad17nm), 
                          labelOptions = labelOptions(noHide = T, textOnly = T, direction = "bottom",
                                                      style = list(
                                                        "color"="white",
                                                        "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>%
        addMarkers(data = jcplus[jcplus$area_name == input$la, ], popup = popup, icon = icon, group = "Jobcentre Plus", options = markerOptions(riseOnHover = TRUE, opacity = 1)) %>% 
        addLegend(position = "bottomleft", colors = c("#F0F0F0", "#E93F36", "#2144F5", "#9794F8", "#EF9493"),
                labels = 
                  c(paste0("Not significant (", formatC(sum(filteredData()$quad_sig == "Not significant"), format="f", big.mark = ",", digits=0), ")"),
                    paste0("High-High (", sum(filteredData()$quad_sig == "High-High"), ")"),  
                    paste0("Low-Low (", sum(filteredData()$quad_sig == "Low-Low"), ")"),
                    paste0("Low-High (", sum(filteredData()$quad_sig == "Low-High"), ")"),
                    paste0("High-Low (", sum(filteredData()$quad_sig == "High-Low "), ")")), 
                opacity = 0.4,
                title = input$measure)
  }
    })
  
}