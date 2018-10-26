## Scan app ##

ui <- navbarPage(
  title = div(img(src = "https://trafforddatalab.github.io/assets/logo/trafforddatalab_logo.svg", height="25", width="99"), "Scan"), windowTitle = "Scan",
  tabPanel(title = "Map",
           div(class="shinyContainer",
               tags$head(includeCSS("styles_base.css"), includeCSS("styles_shiny.css"), includeCSS("styles_map.css"), includeCSS("styles_popup.css"),
                         tags$style(HTML("table.imd td:nth-child(2), table.imd td:nth-child(3) { text-align: right; }"))),
               leafletOutput("map", width = "100%", height = "100%"),
               absolutePanel(id = "shinyControls", class = "panel panel-default controls", fixed = TRUE, draggable = FALSE,
                             br(),
                             selectInput(inputId = "la",
                                         label = NULL,
                                         choices = c("Greater Manchester", levels(df$lad17nm)),
                                         selected = "Greater Manchester"),
                             radioButtons(inputId = "measure",
                                          label = NULL,
                                          choices = c("Residents claiming JSA or Universal Credit",
                                                      "Working-age adults with no qualifications",
                                                      "Households with lone parent not in employment",
                                                      "Social rented households"),
                                          selected = "Residents claiming JSA or Universal Credit"),
                             hr(),
                             uiOutput("info")))),
  tabPanel(title = "About", 
           fluidRow(
             column(9, offset = 1,
                    includeMarkdown("about.md"), style = "color:#212121"))))
