#
# This is a Shiny web application to locate Top Universities in US (2018). 
# 
# 

library(shiny)
library(leaflet )

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Top Universities"),
  
  sidebarLayout(
    sidebarPanel(

            selectInput("lst1", "Choose Rank of University", choices = 1:10, width = '60%', selected = 9),
            hr(),
            em(helpText("Data Source: ")),
            tags$a(href="https://www.topuniversities.com/university-rankings-articles/world-university-rankings/top-universities-us-2018", "QS Top Universities Ranking")
            
    ),
    
    # Show the data for the Rank selected with location map
    mainPanel(
       
            h1(textOutput("univrank")),
            hr(),
            h1(textOutput("univname")),
            h3(textOutput("univadd")),
            hr(),
            leafletOutput("plot1")
            
    )
  )
))
