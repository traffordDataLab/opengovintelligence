## OGI - Trafford pilot app ##

library(shiny) ; library(tidyverse) ; library(ggplot2) ; library(DT)
source("https://trafforddatalab.github.io/assets/theme/ggplot2/theme_lab.R")

# Claimant rate by sex for Greater Manchester Wards, Local Authorities and Combined Authority (nomis API)
ucjsa <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=1673527867...1673527876,1673527878,1673527877,1673527879...1673527899,1673527901,1673527900,1673527902...1673527950,1673527953,1673527951,1673527952,1673527954...1673527997,1673527999,1673527998,1673528000,1673528002,1673528003,1673528001,1673528004...1673528050,1673528052,1673528051,1673528053...1673528081,1879048217...1879048223,1879048225,1879048226,1853882369&date=latestMINUS44-latest&gender=0...2&age=0&measure=2&measures=20100&select=date_name,geography_name,geography_code,gender_name,age_name,measure_name,measures_name,obs_value,obs_status_name") %>% 
  select(date = DATE_NAME,
         area_name = GEOGRAPHY_NAME,
         area_code = GEOGRAPHY_CODE, 
         measure = MEASURE_NAME, 
         category = GENDER_NAME,
         value = OBS_VALUE)

# Ward to Local Authority District lookup (ONS Open Geography Portal)
lookup <- read_csv("https://ons.maps.arcgis.com/sharing/rest/content/items/6417806dc4564ba5afcf15c3a5670ca6/data") %>% 
  select(area_code = WD15CD, 
         la_name = LAD15NM)

ucjsa_wards <- filter(ucjsa, !area_name %in% c("Greater Manchester","Bolton","Bury","Manchester","Oldham","Rochdale",
                                       "Salford","Stockport","Tameside","Trafford","Wigan")) %>% 
  left_join(lookup) %>% 
  mutate(label = paste0("(", la_name, ")")) %>% 
  unite(label, area_name, label, sep = " ") %>% 
  select(-la_name)

df <- filter(ucjsa, area_name %in% c("Greater Manchester","Bolton","Bury","Manchester","Oldham",
                                     "Rochdale","Salford","Stockport","Tameside","Trafford","Wigan")) %>% 
  rename(label = area_name) %>% 
  bind_rows(ucjsa_wards) %>% 
  mutate(date = as.Date(paste('01', date), format = '%d %B %Y'),
         label = as.factor(label),
         category = as.factor(category)) %>% 
  arrange(date)
  
# -------------------------------------------------------------------------------

ui <- fluidPage(
  titlePanel("OGI - Trafford pilot app"),
  br(),
  sidebarLayout(
    sidebarPanel(width = 3,
      uiOutput("choose_area"),
      checkboxInput("multiple", label = "or multiple areas", value = FALSE),
      selectInput("response", 
                  label = "Select a variable",
                  choices = levels(df$category), 
                  selected = "Total"),
      conditionalPanel(
        condition="input.multiple==true",
        h5("Output options"),
        checkboxInput("facet", label = "Facet by area", value = FALSE))),
    mainPanel(tabsetPanel(
                tabPanel("Plot",
                         plotOutput("ggplot_plot", width = "100%")),
                tabPanel("Data", DT::dataTableOutput("area_table"),
                         br(),
                         downloadButton("downloadData", "Download data")),
                tabPanel("About", 
                         br(),
                         p("This ", a("Shiny", href = "http://shiny.rstudio.com"), "application allows you to interrogate claimant rates by ward 
                           and benchmark them by local authority and combined authority rates."),
                         p("The data are published by the", a("Department for Work and Pensions", 
                                                              href = "https://www.gov.uk/government/organisations/department-for-work-pensions"), 
                           "and were extracted using the", a("nomis API", href = "https://www.nomisweb.co.uk/datasets/ucjsa", ".")))))
))

server <- function(input, output){
  
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
                   as.list(levels(df$label), selected = levels(df$label)))
  })
  
  area_data  <- reactive({
    if(is.null(input$GM_areas)) {
      return(NULL)
    }
    filter(df, label %in% input$GM_areas & category == input$response)
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
       p + geom_line(aes(colour = label)) +
          geom_point(aes(colour = label)) +
          labs(title = paste("Proportion of", tolower(input$response), "residents claiming JSA or Universal Credit")) +
          facet_wrap(~label) +
          theme(legend.position = "none")
      } else {
       p +  geom_line(aes(colour = label)) +
          geom_point(aes(colour = label)) +
          labs(title = paste("Proportion of", tolower(input$response), "residents claiming JSA or Universal Credit"))
      }
    } else {
      p + geom_line(colour = "#1b9e77") +
        geom_point(colour = "#1b9e77") +
        labs(title = paste("Proportion of", tolower(input$response), "residents claiming JSA or Universal Credit in", area_data()$label)) 
    }
    
  })
  
  output$area_table <- DT::renderDataTable({
    area_data()
    
  }, rownames = FALSE, options = list(pageLength = 10, dom = 'tip', autoWidth = TRUE))
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(area_data()$measure, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(area_data(), file, row.names = FALSE)
    }
  )
  
}

shinyApp(ui, server)