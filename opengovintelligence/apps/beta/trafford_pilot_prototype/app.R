## OGI - Trafford pilot prototype ##

# Load necessary packages
library(shiny) ; library(tidyverse) ; library(sf) ; library(spdep) ; library(leaflet) ; library(ggplot2) ; library(DT)

# Load Trafford Data Lab's ggplot2 lab_theme()
source("https://trafforddatalab.github.io/assets/theme/ggplot2/theme_lab.R")

# Load  data ---------------------------

# 1. ONS Claimant Count by sex and age (ONS) - latest month (September 2017)
# 2. KS107EW - Lone parent households with dependent children (Census 2011)
# 3. LC5601EW - Highest level of qualification by economic activity (Census 2011)
df <- read_csv("data/worklessness_data.csv", 
               col_types = cols(lsoa11cd = col_factor(NULL),
                                lsoa11nm = col_factor(NULL),
                                measure = col_factor(NULL), 
                                value = col_integer()))

# ONS Claimant Count by sex and age (ONS) - time series
df_ts <- read_csv("data/ucjsa_ts.csv", col_types = cols(lsoa11cd = col_factor(NULL), 
                                                     area_name = col_factor(NULL),
                                                     measure = col_factor(NULL), 
                                                     value = col_double()))

# Index of Multiple Deprivation (DCLG, 2015)
imd <- read_csv("https://github.com/traffordDataLab/open_data/raw/master/imd_2015/IMD_2015_wide.csv",
                col_types = cols(lsoa11cd = col_factor(NULL), 
                                 index_domain = col_factor(NULL), 
                                 decile = col_integer(), 
                                 rank = col_integer(), 
                                 score = col_double())) 

# GM LSOA layer (ONS Open Geography Portal)
lsoa <- st_read("https://github.com/traffordDataLab/boundaries/raw/master/lsoa.geojson") %>% 
  st_as_sf(crs = 4326, coords = c("long", "lat")) %>% 
  as('Spatial')

# GM Local Authority layer (ONS Open Geography Portal)
la <- st_read("https://github.com/traffordDataLab/boundaries/raw/master/local_authorities.geojson") %>% 
  st_as_sf(crs = 4326, coords = c("long", "lat"))

# GM Jobcentre Plus 
jcplus <- read_csv("https://github.com/traffordDataLab/open_data/raw/master/job_centre_plus/jobcentreplus_gm.csv") %>% 
  st_as_sf(crs = 4326, coords = c("lon", "lat"))

# Gambling Premises (Gambling Commission)
gambling <- read_csv("https://github.com/traffordDataLab/open_data/raw/master/betting_shops/bettingshops_gm.csv") %>% 
  st_as_sf(crs = 4326, coords = c("lon", "lat"))


# Define neighbours for LISA maps ---------------------------

# Create a first order, Queen’s contiguity spatial weights matrix
nb <- poly2nb(lsoa, queen = TRUE)
lw <- nb2listw(nb)

# User interface ---------------------------

ui <- navbarPage(
  title = div(img(src = "https://trafforddatalab.github.io/assets/logo/trafforddatalab_logo.svg", height="25", width="99"), 
                             "OGI - Trafford pilot prototype"), windowTitle = "OGI - Trafford pilot prototype",
  tabPanel(title = "Maps",
           div(class="shinyContainer",
               tags$head(includeCSS("styles_base.css"), includeCSS("styles_shiny.css"), includeCSS("styles_map.css"),
                         tags$style(HTML("table.imd td:nth-child(2), table.imd td:nth-child(3) { text-align: right; }"))),
               leafletOutput("map", width = "100%", height = "100%"),
               absolutePanel(id = "shinyControls", class = "panel panel-default controls", fixed = TRUE, draggable = TRUE,
                             h4("Choose a measure"),
                             radioButtons(inputId = "measure",
                                          label = NULL,
                                          choices = c("Residents claiming JSA or Universal Credit",
                                                      "Working-age adults with no qualifications",
                                                      "Households with lone parent not in employment"),
                                          selected = "Residents claiming JSA or Universal Credit"),
                             hr(),
                             uiOutput("info")))),
  tabPanel(title = "Charts",
           fluidPage(
             sidebarLayout(
               sidebarPanel(width = 3,
                            uiOutput("choose_area"),
                            checkboxInput("multiple", label = "or multiple areas", value = FALSE),
                            conditionalPanel(
                              condition="input.multiple==true",
                              h5("Output options"),
                              checkboxInput("facet", label = "Facet by area", value = FALSE))),
                              mainPanel(plotOutput("ggplot_plot", width = "100%", height = "300px"),
                              br(),
                              DT::dataTableOutput("area_table"),
                              br(),
                              downloadButton("downloadData", "Download data"))))),
  tabPanel(title = "About", 
           fluidRow(
             column(8, offset = 1,
                    includeMarkdown("about.md"), style = "color:#212121")))
)

# Server ---------------------------

server <- function(input, output, session) {
  values <- reactiveValues(highlight = c())
  
  # Maps ---------------------------
    
  filteredData <- reactive({
    sub <- filter(df, measure == input$measure)
    lsoa@data <- left_join(lsoa@data, sub, by = "lsoa11cd")
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
  })
  
  observe({
    values$highlight <- input$map_shape_mouseover$id
  })
  
  output$info <- renderUI({
    if (is.null(values$highlight)) {
      return(tags$h4("then hover over an LSOA"))
    } else {
      lsoaCode <- filteredData()$lsoa11cd[values$highlight == lsoa$lsoa11cd]
      return(tags$div(
        HTML(paste(tags$h4("LSOA: ", lsoaCode))),
        HTML(paste("in ", tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$wd16nm), " Ward, ",
                   tags$span(filteredData()[filteredData()$lsoa11cd == lsoaCode,]$lad16nm), sep = "")),
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
               attribution = '<a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>',
               group = "No background") %>% 
      setView(-2.28417866956407, 53.5151885751656, zoom = 11) %>% 
      addLayersControl(position = 'topleft',
                       baseGroups = c("CartoDB", "OpenStreetMap", "Satellite", "No background"),
                       overlayGroups = c("Jobcentre Plus", "Gambling premises"), 
                       options = layersControlOptions(collapsed = TRUE)) %>% 
      hideGroup(c("Jobcentre Plus", "Gambling premises")) %>% 
      htmlwidgets::onRender(
        " function(el, t) {
        var myMap = this;
        myMap._container.style['background'] = '#ffffff';}")
  })
  
  observe({
    factpal <- colorFactor(c("#F0F0F0", "#E93F36", "#2144F5", "#9794F8", "#EF9493"),
                           levels = c("Not significant", "High-High", "Low-Low", "Low-High", "High-Low"),
                           ordered = TRUE)
    
    icon_jcplus <- makeAwesomeIcon(icon = "map-marker", library = "glyphicon", markerColor = "green", iconColor = "#FFED00")
    icon_gambling <- makeAwesomeIcon(icon = "map-marker", library = "glyphicon", markerColor = "darkpurple", iconColor = "white")
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>% clearControls() %>% clearMarkers() %>% 
      addPolygons(data = filteredData(), fillColor = ~factpal(quad_sig), fillOpacity = 0.4, 
                  stroke = TRUE, color = "black", weight = 1, layerId = ~lsoa11cd,
                  highlight = highlightOptions(color = "#FFFF00", weight = 3, opacity = 1, bringToFront = TRUE)) %>%
      addPolylines(data = la, stroke = TRUE, weight = 3, color = "#212121", opacity = 1) %>% 
      addLabelOnlyMarkers(data = la, lng = ~centroid_lng, lat = ~centroid_lat, label = ~as.character(lad16nm), 
                          labelOptions = labelOptions(noHide = T, textOnly = T, direction = "bottom",
                                                      style = list(
                                                        "color"="white",
                                                        "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>%
      addAwesomeMarkers(data = jcplus, popup = ~as.character(name), icon = icon_jcplus, group = "Jobcentre Plus", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
      addAwesomeMarkers(data = gambling, popup = ~as.character(name), icon = icon_gambling, group = "Gambling premises", options = markerOptions(riseOnHover = TRUE, opacity = 0.75)) %>% 
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
      paste("data_dowload.csv")
    },
    content = function(file) {
      write.csv(area_data(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)