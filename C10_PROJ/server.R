#
# JHU Capstone Project to Predict Next Possible Word
#
# This server script gets the user input and call the function to predict the next possible word.
# captures the time take to process and returns the next word, a plot with top 5 words & top 10 probable words
# 

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

        nxt_txt <- reactive({
                bt <<- Sys.time()
                y <- tolower(input$txt1)
                z <- predictNextWord(y)
                et <<- Sys.time()
                
                z

        })
        output$nextword <- renderText({
                
                # bt <- Sys.time()
                withProgress(message = 'Predicting : ', 
                             detail = "Please wait", 
                             value = 1,
                             x <- nxt_txt()
                             )
                # et <- Sys.time()
                
                if (is.na(x[1,1]) | x[1,1]== "Unobserved") {
                        "Please try some other word"
                } else {
                         elapsed <<- round(et - bt, 4)
                         #paste(as.character(x$ngram[1]), round(et - bt, 4), "secs")
                         as.character(x$ngram[1])
                }        
        })

        output$timetaken <- renderText({
                x <- nxt_txt()
                paste("Response time :", as.character(elapsed), "seconds")
                #paste(as.character(x$ngram[1]),as.character(elapsed),  "secs")
        })        

        output$possiblewords <- renderTable({
                nxt_txt()
        })
        
        output$plotwords <- renderPlot({
                x <- nxt_txt()
                if (is.na(x[1,1]) | x[1,1]== "Unobserved") {
                        NULL
                } else {
                        barplot(x$prob[1:5], 
                                main = "Probability of Next word", 
                                names.arg = x$ngram[1:5], 
                                ylab="Probality", 
                                col = "tan"
                        )
                }
        })

        output$plottrigram <- renderPlot({
                
                trigram <- read.csv("trigram.txt", stringsAsFactors = FALSE, nrows = 20)[,c("feature", "frequency")]
                
                p3 <- ggplot(trigram, aes(x= reorder(feature, frequency), y=frequency)) +
                        theme_bw() +
                        geom_bar(stat="identity", width = .2, color ="slateblue")+
                        labs(y= "Text Count", x= "Word",
                             title = "3 GRAMS") +
                        coord_flip() 
                p3
        })

})
