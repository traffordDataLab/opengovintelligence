## Scan ##

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
                              tabPanel("About",
                                       br(),
                                       p("For guidance on using this app please refer to the", a(href = "http://www.trafforddatalab.io/opengovintelligence/documentation/scan_README.html", target = "_blank", "documentation")),
                                       div(img(src = "https://www.traffordDataLab.io/opengovintelligence/eu_flag.png", width="50", alt="Flag of the European Union", style="float: left; margin-right: 6px; margin-top: 5px;"), "Funded by the EU's Horizon 2020 programme, grant No 693849"),
                                       br(),
                                       p("Discover more about the", a(href = "https://www.trafforddatalab.io/opengovintelligence", target = "_blank", "Trafford Worklessness Pilot")))))))
  )
