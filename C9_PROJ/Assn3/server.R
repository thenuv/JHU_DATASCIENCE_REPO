#
# Sever script for defining data set, return the data and plot for the Rank selected in UI.
#

library(shiny)
library(leaflet )

# 
shinyServer(function(input, output) {
        
        # Define Data Set 
        df_univ <- data.frame(
                Latitude = c(39.3299, 42.3601, 37.4275, 42.377, 40.8075, 40.344, 42.4534, 41.3163, 41.7886, 34.1377),
                Longitude = c(-76.6205,-71.0942,-122.1697,-71.1167,-73.9626,-74.6514,-76.4735,-72.9223,-87.5987,-118.1253),
                UniversityName = c(
                        "Johns Hopkins University",
                        "Massachusetts Institute of Technology",
                        "Stanford University",
                        "Harvard University",
                        "Columbia University",
                        "Princeton University",
                        "Cornell University",
                        "Yale University",
                        "University of Chicago",
                        "California Institute of Technology"),
                Rank     =c(9,1,2,3,10,6,7,8,5,4)
        )

                
        # Function to get Address with coordinates
        addressFromGeocode <- function(latitude, longitude) {
                require(RJSONIO)
                url <- "https://maps.googleapis.com/maps/api/geocode/json?latlng="
                url <- URLencode(paste(url, latitude, ",", longitude, "&sensor=false", sep =""))
                x <- fromJSON(url, simplify = FALSE)               
                if (x$status == "OK") {
                        out <- x$results[[1]]$formatted_address
                } else {
                        out <- " " 
                }
                Sys.sleep(0.2)
                out
        }
        
        
        unv_rnk <- reactive({
                x <- as.numeric(input$lst1)
                as.character(df_univ[,3][df_univ$Rank==x])
        })
        
        unv_add <- reactive({
                x <- as.numeric(input$lst1)
                lat <- as.numeric(df_univ[,1][df_univ$Rank==x])
                lng <- as.numeric(df_univ[,2][df_univ$Rank==x])
        
                addressFromGeocode(lat, lng)

        })
        
        unv_loc <- reactive({
                x <- as.numeric(input$lst1)
                lat <- as.numeric(df_univ[,1][df_univ$Rank==x])
                lng <- as.numeric(df_univ[,2][df_univ$Rank==x])
                txt <-  as.character(df_univ[,3][df_univ$Rank==x])
                
                ul <- leaflet() %>%
                        addTiles() %>%
                        addMarkers(lat = lat, 
                                   lng = lng, 
                                   popup = txt,
                                   label = txt
                                   )
        })
        
        output$univrank <- renderText({ paste("2018 University Rank :", input$lst1) })
        
        output$univname <- renderText({
                unv_rnk()
                })
        
        output$univadd <- renderText({
                unv_add()
        })
        
        output$plot1 <- renderLeaflet({
                unv_loc()
        })
        
})
