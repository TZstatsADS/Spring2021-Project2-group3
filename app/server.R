
source("global.R")
library(shinydashboard)

shinyServer(function(input, output, session) {
    
    ## homepage box output #############################################
    output$box1 = renderValueBox({
        valueBox(
            count_open,"open public activities",color = "red")
    })
    output$box2 = renderValueBox({
        valueBox(
            count_closed,"closed public activities",color = "aqua")
    })       
    output$box3 = renderValueBox({
        valueBox(
            count_total,"total considered",icon=NULL,
            color = "red")
    })   
    
    ## map output #############################################
    # outdoor activity tab
    iceskating <- reactive({
        df.activity %>% filter(category == "iceskating")
    })
    
    basketball <- reactive({
        df.activity %>% filter(category == "basketball")
    })
    
    cricket <- reactive({
        df.activity %>% filter(category == "cricket")
    })

    handball <- reactive({
        df.activity %>% filter(category == "handball")
    })

    runningTrack <- reactive({
        df.activity %>% filter(category == "runningTrack")
    })
    
    
    output$map <- renderLeaflet({
        #covid cases parameters
        parameter <- if(input$choice == "positive cases") {
            data$people_positive
            } else if(input$choice == "cumulative cases") {
                data2$COVID_CASE_COUNT
            } else {
                data2$COVID_DEATH_COUNT
            }
    
        #create palette
        pal <- colorNumeric(
            palette = "Reds",
            domain = parameter)
    
        #create labels
        #Cleaned by emphasizing %Pos, case rate is other option
        labels <- paste(
            data$zip, " - ",
            data$modzcta_name, "<br/>",
            "Confirmed Cases: ", data$people_positive,"<br/>",
            "Cumulative cases: ", data2$COVID_CASE_COUNT,"<br/>",
            "Cumulative deaths: ", data2$COVID_DEATH_COUNT,"<br/>",
            "Tested number:",data$people_tested,"<br/>",
            "<b>Infection Rate: ", perp_zipcode[nrow(perp_zipcode),],"%</b><br/>",
            "Expected Infection Rate Next Week: ", predictions_perp,"%<br/>") %>%
            lapply(htmltools::HTML)
    
        map <- geo_data %>%
            select(-geometry) %>%
            leaflet(options = leafletOptions(minZoom = 8, maxZoom = 18)) %>%
            setView(-73.93, 40.80, zoom = 10) %>%
            addTiles() %>%
            addProviderTiles("CartoDB.Positron") %>%
            addPolygons(
                fillColor = ~pal(parameter),
                weight = 1,
                opacity = .5,
                color = "white",
                dashArray = "2",
                fillOpacity = 0.7,
                highlight = highlightOptions(weight = 1,
                                             color = "yellow",
                                             dashArray = "",
                                             fillOpacity = 0.7,
                                             bringToFront = TRUE),
                label = labels) %>%
            addLegend(pal = pal, 
                      values = ~parameter,
                      opacity = 0.7, 
                      title = htmltools::HTML(input$radio),
                      position = "bottomright")
    })
    
    observeEvent(input$choices, {
        
        #define labels for every activity    
        label.iceskating <- paste(
            "Name: ", iceskating()$Name, "</br>",
            "category: ", iceskating()$category, "</br>",
            "Address: ", iceskating()$Location, "</br>",
            "Accessibility: ", iceskating()$Accessible, "</br>",
            "Phone Number: ", iceskating()$Phone.x) %>%
            lapply(htmltools::HTML)

        label.basketball <- paste(
            "Name: ", basketball()$Name, "</br>",
            "category: ", basketball()$category, "</br>",
            "Address: ", basketball()$Location, "</br>",
            "Accessibility: ", basketball()$Accessible) %>%
            lapply(htmltools::HTML)
        
        label.cricket <- paste(
            "Name: ", cricket()$Name, "</br>",
            "category: ", cricket()$category, "</br>",
            "Address: ", cricket()$Location, "</br>",
            "Number of Fields: ", cricket()$Num_of_Fields) %>%
            lapply(htmltools::HTML)
        
        label.handball <- paste(
            "Name: ", handball()$Name, "</br>",
            "category: ", handball()$category, "</br>",
            "Address: ", handball()$Location, "</br>",
            "Number of Courts: ", handball()$Num_of_Courts) %>%
            lapply(htmltools::HTML)
        
        label.runningTrack <- paste(
            "Name: ", runningTrack()$Name, "</br>",
            "category: ", runningTrack()$category, "</br>",
            "Address: ", runningTrack()$Location, "</br>",
            "Type: ", runningTrack()$RunningTracks_Type, "</br>",
            "Size: ", runningTrack()$Size) %>%
            lapply(htmltools::HTML)


        if(input$choices == "iceskating") {
            leafletProxy("map") %>%
                clearMarkers() %>%
                clearMarkerClusters() %>%
                addMarkers(data = iceskating(), lng=~lon, lat=~lat, 
                             label=label.iceskating) 
        } else if(input$choices == "basketball") {
            leafletProxy("map") %>%
                clearMarkers() %>%
                clearMarkerClusters() %>%
                addMarkers(data = basketball(), lng = ~lon, lat = ~lat,
                                #color = "blue", fillOpacity = 0.6,
                                label = label.basketball,
                                clusterOptions = markerClusterOptions())
        } else if(input$choices == "cricket") {
            leafletProxy("map") %>%
                clearMarkers() %>%
                clearMarkerClusters() %>%
                addMarkers(data = cricket(), lng=~lon, lat=~lat, 
                                 #color="green", fillOpacity = 0.6,
                                 label = label.cricket)
        } else if(input$choices == "handball") {
            leafletProxy("map") %>%
                clearMarkers() %>%
                clearMarkerClusters() %>%
                addMarkers(data = handball(), lng=~lon, lat=~lat, 
                                 #color="gold", fillOpacity = 0.6,
                                 label = label.handball,
                                 clusterOptions = markerClusterOptions())
        } else {
            leafletProxy("map") %>%
                clearMarkers() %>%
                clearMarkerClusters() %>%
                addMarkers(data = runningTrack(), lng=~lon, lat=~lat, 
                                 #color="violet", fillOpacity = 0.6,
                                 label = label.runningTrack)
        }
    })
    
    ## plot output #############################################
    observeEvent(input$Borough,{
        updateSelectInput(session,"Zip_code",
                          choices=unique(cp_merged$zipcode[cp_merged$Borough==input$Borough]))
    }) 
    
    
    output$plot=renderPlotly({
        cp_merged%>%
            dplyr::filter(., (zipcode == input$Zip_code) | (zipcode == "Citywide"))%>%
            ggplot(aes_string(x="week", y=input$Rate_type,color = "zipcode"))+
            geom_jitter(size=1.5)+
            scale_x_date(date_breaks = "2 week", date_labels = "%m-%d-%Y")+
            scale_color_manual(values=c("light blue", "pink"))+
            theme_bw()+
            theme(axis.text.x=element_text(angle=30,hjust=1))+
            ylab("")+
            xlab("Date")+
            ggtitle("Rate trend")+
            geom_smooth(size=.1,fill="light grey")+
            geom_point(aes(alpha="Prediction of Next Week",x=predictions_perp$week[1], y=predictions_combo[convert(input$Rate_type),input$Zip_code]),color="grey",show.legend=TRUE)+
            #guides(color=guide_legend("my title")) +
            #geom_text(aes(label="Prediction"))+
            theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),legend.title = element_blank())
    })
    
    output$plot2=renderPlotly({
        cbd_merged%>%
            dplyr::filter(., (Borough == input$Borough2))%>%
            ggplot(aes_string(x="date", y= "Case", color = "Borough"))+
            geom_jitter(size=1.5)+
            scale_x_date(date_breaks = "1 week", date_labels = "%m-%d-%Y")+
            scale_color_manual(values= "thistle2")+
            theme_bw()+
            theme(axis.text.x=element_text(angle=30,hjust=1))+
            ylab("")+
            xlab("Date")+
            ggtitle("Case trend")+
            theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),legend.title = element_blank())
    })
        
    ## search table output #############################################
    output$search_result = DT::renderDataTable({
        df.activity %>%
            select(Name,Location,Accessible,category)
    },selection = 'single')
    
      
})
