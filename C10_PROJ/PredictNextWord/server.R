#
#
# 
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

        PossibleText <- data.frame(Word = c("word1", "word2", "word3", "word4", "word5"))
        PossibleText$Word <- as.character(PossibleText$Word) 
        
        nxt_txt <- reactive({
                y <- tolower(input$txt1)
                z <- predictNextWord(y)
                #p <- as.character(z$ngram[1])
                #paste(y, p)
                z

        })
        output$nextword <- renderText({
                x <- nxt_txt()
                as.character(x$ngram[1])
                
        })
        
        output$possiblewords <- renderTable({
                nxt_txt()
        })
        
        output$plotwords <- renderPlot({
                i <- nxt_txt()
                barplot(i$prob[1:5], 
                        main = "Probability of Next word", 
                        names.arg = i$ngram[1:5], 
                        ylab="Probality", 
                        col = "tan"
                        )
        })

        output$plottrigram <- renderPlot({
                p3
        })

})
