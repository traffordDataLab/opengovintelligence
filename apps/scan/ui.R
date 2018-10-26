## Work<ness app ##

ui <- navbarPage(
  title = div(tags$a(href = "https://www.trafforddatalab.io/", target = "_blank", 
                     tags$img(src = "https://trafforddatalab.github.io/assets/logo/trafforddatalab_logo.svg", height = "25", width = "99")), 
              "Work<ness app"), windowTitle = "Work<ness app",
  tabPanel(title = "Clusters",
           div(class="shinyContainer",
               tags$head(includeCSS("styles_base.css"), includeCSS("styles_shiny.css"), includeCSS("styles_map.css"), includeCSS("styles_popup.css"),
                         tags$style(HTML("table.imd td:nth-child(2), table.imd td:nth-child(3) { text-align: right; }"))),
               leafletOutput("cluster_map", width = "100%", height = "100%"),
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
  tabPanel(title = "Suggested workflow", 
           fluidRow(
             column(8, offset = 1,
                    includeMarkdown("workflow.md"), style = "color:#212121"))),
  tabPanel(title = "About", 
           fluidRow(
             column(8, offset = 1,
                    includeMarkdown("about.md"), style = "color:#212121"))))
