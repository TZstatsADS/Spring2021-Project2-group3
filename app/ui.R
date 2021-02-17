#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(DT)
source("global.R")
library(shinydashboard)
library(shinythemes)

shinyUI(fluidPage(
    navbarPage(title = "NYC Outdoor Activity Guidebook",
               fluid = TRUE,
               collapsible = TRUE,
               theme = shinytheme("superhero"),
               # ---------------------------------------------------------------
               # tab panel 1: Home
               tabPanel("Home", icon = icon("home"),
                        
                        
                        tags$div(
                          tags$h4("Everyone wants to stay healthy, but it's harder today than ever..."),
                          tags$h4("The COVID-19 Pandemic means parks, dogruns, and courts are often closed.")
                        ),
                        fluidRow(
                          valueBoxOutput("box1"),
                          valueBoxOutput("box2"),
                          valueBoxOutput("box3")),
                        tags$div(
                          tags$br(), tags$br(),
                          tags$h5("Our solution is to gather public park and field information in one convenient place,"),
                          tags$h5("Click on the Interactive Map to find spots near you, or search for specific ones in the Search tab.")
                        )
                        ,
                        HTML('<center><img src="running.jpg", height="300px"></center>')),
               # ---------------------------------------------------------------
               # tab panel 2: Map
               tabPanel("Interactive Map", icon = icon("globe"),
                        div(class="outer",
                            tags$head(includeCSS("styles.css")),
                            leafletOutput("map", width="100%", height="100%"),
                            absolutePanel(id="controls", class="panel panel-default",
                                          top=75, left=55, width=250, fixed=TRUE,dragged=TRUE, height="auto",
                                          shiny::span(tags$b(h4("check the types of case data you want: ")), style="color:#045a8d"),
                                          selectInput("choice",
                                                      label = "case type: ",
                                                      choices = c("positive cases","cumulative cases","cumulative death"), 
                                                      selected = "people_positive"),
                                          shiny::span(tags$b(h4("Select the outdoor activities you want to go:")), style="color:#045a8d"),
                                          selectInput("choices","Choose Activity:",
                                                             choices = c("","Ice Rinks"="iceskating","Basketball Courts"="basketball","Cricket Fields"="cricket",
                                                                         "Baseball and Handball"="handball","Running Tracks"="runningTrack"),
                                                             selected = c(""))
                                          
                                          )
                            )
                        ),
               # ---------------------------------------------------------------
               # tab panel 3: Plot
               tabPanel("Case Plot", icon = icon("bar-chart-o"),
                        sidebarPanel(
                          tabsetPanel(
                            tabPanel("Rate trend by zip code",
                                     selectInput("Borough",label = "Borough",
                                                 Borough, selected = "Citywide", multiple = FALSE),
                                     
                                     selectInput("Zip_code", label = "Zipcode",
                                                 unique(cp_merged$zipcode), selected = "Manhattan"),
                                     
                                     selectInput("Rate_type", label = "percentage of case or positive test",
                                                 ratetype, selected = "Case.rate"),
                            ),
                            tabPanel("Case trend by borough",
                                     selectInput("Borough2", label = "Borough",
                                                 Borough_case, selected = "Citywide"))
                          )),
                        mainPanel(
                          tabsetPanel(
                            tabPanel("Covid-19 Trend in NYC",
                                     # fluidRow(...)
                                     plotlyOutput("plot"),
                                     plotlyOutput("plot2")
                            )
                          )
                        )
               ),
               
               # ---------------------------------------------------------------
               # tab panel 4: Search
               tabPanel("Search", icon = icon("table"), 
                        tags$style(HTML("
                    .dataTables_wrapper .dataTables_length, .dataTables_wrapper .dataTables_filter, .dataTables_wrapper .dataTables_info, .dataTables_wrapper .dataTables_processing, .dataTables_wrapper .dataTables_paginate, .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
                    color: #ffffff;
                    }
                    
                    .dataTables_wrapper .dataTables_paginate .paginate_button{box-sizing:border-box;display:inline-block;min-width:1.5em;padding:0.5em 1em;margin-left:2px;text-align:center;text-decoration:none !important;cursor:pointer;*cursor:hand;color:#ffffff !important;border:1px solid transparent;border-radius:2px}

                    .dataTables_length select {
                           color: #0E334A;
                           background-color: #F5F5F5
                           }

                    .dataTables_filter input {
                            color: #0E334A;
                            background-color: #F5F5F5
                           }

                    thead {
                    color: #ffffff;
                    }

                     tbody {
                    color: #000000;
                    }

                   "
                        )),
                        
                        DT::dataTableOutput("search_result")), 
               
               # ---------------------------------------------------------------
               # tab panel 5: About
               tabPanel("About", icon = icon("list-alt"),
                        HTML('<center><img src="covid.jpg", height="400px"></center>'),
                        tags$div(
                          tags$h4("Data Sources"),
                          "NYC Outdoor Activity Data: ", tags$a(href="https://www.nycgovparks.org/bigapps/", "NYC Parks Open Data"), tags$br(),
                          "NYC Last-7-day Cases by Cipcode: ", tags$a(href="https://github.com/nychealth/coronavirus-data/blob/master/latest/last7days-by-modzcta.csv", "The Health Department of NYC"), tags$br(),
                          "NYC Total Cases by Zipcode: ", tags$a(href="https://github.com/nychealth/coronavirus-data/blob/master/totals/data-by-modzcta.csv", "The Health Department of NYC"), tags$br(),
                          "NYC Positive Case Rate by Borough and Zipcode: ", tags$a(href="https://github.com/nychealth/coronavirus-data/blob/master/trends/caserate-by-modzcta.csv", "The Health Department of NYC"),

                          
                          tags$br(),tags$br(),tags$h4("Contributor"),
                          "Ai, Haosheng | ha2583@columbia.edu", tags$br(),
                          "Chen, Ellen | zc2574@columbia.edu", tags$br(),
                          "Harris, Sean | sh3715@columbia.edu", tags$br(),
                          "He, Changhao | ch3557@columbia.edu", tags$br(),
                          "Pan, Yushi | yp2560@columbia.edu", 
                          
                          tags$br(), tags$br(), tags$h4("Code"),
                          "Code and input data used to generate this Shiny App are avaliable on ", tags$a(href="https://github.com/TZstatsADS/Spring2021-Project2-group3", "Github."),
                          tags$br(), tags$br()
                        )
                        )

    )
))
                            


               