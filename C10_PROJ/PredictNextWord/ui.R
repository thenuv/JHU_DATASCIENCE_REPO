#
#
# 
# 
#

library(shiny)
library(dplyr)
library(stringr)
library(quanteda)
library(ggplot2)

source('predictNextWord.R')

trigram <- read.csv("trigram.txt", stringsAsFactors = FALSE, nrows = 20)[,c("feature", "frequency")]
p3 <- ggplot(trigram, aes(x= reorder(feature, frequency), y=frequency)) +
        theme_bw() +
        geom_bar(stat="identity", width = .2, color ="slateblue")+
        labs(y= "Text Count", x= "Word",
             title = "3 GRAMS") +
        coord_flip() 


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  titlePanel("Next Possible Word"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
        textInput("txt1", "Type some words", value = "new york"),
        hr(),
        submitButton("Submit")
        ),
    
    # Show a plot of the generated distribution
    mainPanel(
       #plotOutput("distPlot"),

       tabsetPanel (type = "tabs",
                    
                    tabPanel("Output",
                             h3("Predicted Next Word :"),
                             h2(textOutput("nextword"), style="color:blue"),
                             hr(),
                             plotOutput("plotwords"),
                             hr(),
                             tableOutput("possiblewords")
                    ),
                    
                    tabPanel("Info", br(),
                             h3("Overview"),
                             h5("This application gives the possible next word with prediction based on Katz Back Off model. A 5% sample of data from News, Blogs & Twitter was randomly picked using binomial logic to get a proportionate data of total volume. The sample corpus was used to build the ngrams."),
                             hr(),
                             h3("Model Info"),
                             h5("Katz Back Off model is applied to predict the next word the user could type based on the history from sample corpus. The discount rates gamma2 and gamma3 were set at 0.5."),
                             hr(),
                             h3("How to Use"),
                             h5("Type in few words in the Text box in the left of the application and submit. The output tab will display the possible next word with a graph for top 5 words with higher probability. A table below displays first 10 possible words with their probability."),
                             hr(),
                             h3("Top 20 Trigram"),
                             plotOutput("plottrigram", width = "60%")
                             )
       )
    )
  )
))
