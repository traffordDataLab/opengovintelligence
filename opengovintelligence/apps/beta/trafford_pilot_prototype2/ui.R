## OGI - Trafford pilot prototype ##

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
                             h4("Choose a local authority"),
                             selectInput("la", label = "Select a local authority",
                                         choices = c("Bolton","Bury","Manchester","Oldham","Rochdale","Salford","Stockport","Tameside","Trafford","Wigan"),
                                         selected = "Trafford"),
                             h4("and a measure"),
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
