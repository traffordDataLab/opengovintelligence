## Scan app ##

ui <- bootstrapPage(
  tags$head(includeCSS("styles.css"),
            tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
            leafletOutput("map",  width = "100%", height = "100%"),
            absolutePanel(id = "shinyControls", class = "panel panel-default controls", fixed = TRUE, draggable = FALSE, height = "auto",
                          tags$h3("Scan ", tags$small(" hot and cold spots of worklessness")),
                          fluidRow(
                            tabsetPanel(
                              tabPanel("Controls",
                                       br(),
                                       selectInput(inputId = "la", label = NULL, 
                                                   choices = c("Greater Manchester", levels(df$lad17nm)), selected = "Greater Manchester"),
                                       radioButtons(inputId = "measure", label = NULL,
                                                    choices = c("Residents claiming JSA or Universal Credit",
                                                                "Working-age adults with no qualifications",
                                                                "Households with lone parent not in employment",
                                                                "Social rented households"),
                                                    selected = "Residents claiming JSA or Universal Credit"),
                                       hr(),
                                       uiOutput("info")),
                              tabPanel("Help",
                                       br(),
                                       p("This application uses a technique called 'Local Indicators of Spatial Association' (", a(href = "https://doi.org/10.1111/j.1538-4632.1995.tb00338.x", target = "_blank", "Anselin, 1995"), ") to identify hot and cold spots of worklessness."),
                                       p("Further information about the app can be found ", a(href = "http://www.trafforddatalab.io/opengovintelligence/", target = "_blank", "here"), "."))))))
  )
