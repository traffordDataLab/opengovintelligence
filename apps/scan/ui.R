## Scan app ##

ui <- fluidPage(
  tags$head(includeCSS("styles.css")),
  fluidRow(id = "header",
    column(2,
           h5(a(href = "https://www.trafforddatalab.io", target = "_blank", title = "Trafford Data Lab",
                img(src = "https://trafforddatalab.github.io/assets/logo/trafforddatalab_logo.svg", height = "31"), alt = "Trafford Data Lab"))),
    column(9,
           h3("Scan ",
              tags$small(" hot and cold spots of worklessness")))),
  fluidRow(title = "Map",
           leafletOutput("map",  width = "100%", height = 760),
           absolutePanel(id = "shinyControls", class = "panel panel-default controls", fixed = TRUE, draggable = FALSE, height = "auto",
                         br(),
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
                                      p("Further information about the app can be found ", a(href = "http://www.trafforddatalab.io/opengovintelligence/", target = "_blank", "here"), ".")))))),
  fluidRow(id = "footer", class = "footer",
    column(1, 
           a(href = "http://www.opengovintelligence.eu/", img(src = "eu_flag.png", style = "float: left; margin-right: 12px; height: 5em;"), alt = "Flag of the European Union")),
    column(3,
           p("This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement No 693849.")),
    column(2, offset = 6,
           p("Explore worklessness further using our other",
             a(href = "http://www.opengovintelligence.eu/", target = "_blank", "OpenGovIntelligence"), " apps: ",
             a(href = "http://www.trafforddatalab.io/opengovintelligence/summarise.html", target = "_blank", "Summarise"),
             " and ", a(href = "http://www.trafforddatalab.io/opengovintelligence/signpost.html", target = "_blank", "Signpost"), ".")))
  )


