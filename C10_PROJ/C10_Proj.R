setwd("E:/DataScience/Rwork/data/final/en_US")

library(data.table)
library(readr)

myfiles <- "E:/DataScience/Rwork/data/final/en_US/en_US.twitter.txt"
cleanFiles<-function(file,newfile){
        writeLines(iconv(readLines(file, skipNul = TRUE)),newfile)
}
fname <- "E:/DataScience/Rwork/data/final/en_US/sample.txt"
con <- file(fname, open="r")
cleanFiles (fname, "newsample.txt")
close(con)

x<-readLines("sample.txt", skipNul = TRUE)

x<-readLines("en_US.twitter.txt", skipNul = TRUE)
x <- as.data.frame(x)
set.seed(1234)
mysample <- x[sample(1:nrow(x), 2000,replace=FALSE),]
mysample <- as.data.frame(mysample)
write.table(mysample,"sample2k.txt",row.names=FALSE, col.names = FALSE, quote = FALSE)


df_tw <- readLines("sample2k.txt")
df_tw <- as.data.frame(df_tw)
names(df_tw) <- "ttext"
length(which(!complete.cases(df_tw)))
df_tw$ttext <- as.character(df_tw$ttext)
df_tw$tlength <- nchar(df_tw$ttext)

library(quanteda)
# Tokenize text 
df_tw.token <- tokens(df_tw$ttext, 
                         what = "word", 
                         remove_punct = TRUE, 
                         remove_numbers = TRUE,
                         remove_symbols = TRUE,
                         remove_hyphens = TRUE)
# convert to lower case
df_tw.token <- tokens_tolower(df_tw.token)
        
# Remove Stop words
df_tw.token <- tokens_select(df_tw.token, stopwords(), selection = "remove")

# Filter Profanity words
prof_list <- read.csv("profanity_words.txt", header = FALSE)
prof_list$V1 <- as.character(prof_list$V1)
df_tw.token <- tokens_select(df_tw.token, prof_list$V1, selection = "remove")

# Stemming
df_tw.token <- tokens_wordstem(df_tw.token, language = "english")

# Create DFM
df_tw.token.dfm <- dfm(df_tw.token, tolower = FALSE)
df_tw.token.matrix <- as.matrix(df_tw.token.dfm)
#df_tw.token.df <- data.frame(df_tw.token.dfm)
df_tw.token.df <- data.frame(df_tw.token.matrix)
names(df_tw.token.df) <- make.names(names(df_tw.token.df))



############################################################################
#### Sampe from Full set 

tweet_text <- readLines("en_US.twitter.txt", skipNul = TRUE)
set.seed(1234)
tweet_text <- tweet_text[rbinom(length(tweet_text)*.05, length(tweet_text), 0.5)]

blog_text <- readLines("en_US.blogs.txt", skipNul = TRUE)
set.seed(1234)
blog_text <- blog_text[rbinom(length(blog_text)*.05, length(blog_text), 0.5)]

news_text <- readLines("en_US.news.txt", skipNul = TRUE)
set.seed(1234)
news_text <- news_text[rbinom(length(news_text)*.05, length(news_text), 0.5)]

write.csv(tweet_text, file ="sample.tweet.txt", row.names = FALSE, col.names = NULL, quote = FALSE)
write.csv(blog_text, file ="sample.blog.txt", row.names = FALSE, col.names = NULL, quote = FALSE)
write.csv(news_text, file ="sample.news.txt", row.names = FALSE, col.names = NULL, quote = FALSE)


# Read data from Sample saved
tweet_text <- readLines("sample.tweet.txt")
blog_text <- readLines("sample.blog.txt")
news_text <- readLines("sample.news.txt")

tweet_text<- tweet_text[2:length(tweet_text)]
blog_text<- blog_text[2:length(blog_text)]
news_text<- news_text[2:length(news_text)]

df_txt1 <- data.frame(DataSource = as.factor("Tweeter"), Text = tweet_text)
df_txt2 <- data.frame(DataSource = as.factor("Blog"), Text = blog_text)
df_txt3 <- data.frame(DataSource = as.factor("News"), Text = news_text)
corp <- rbind(df_txt1,df_txt2,df_txt3)

length(which(!complete.cases(corp)))
corp$Text <- as.character(corp$Text)
corp$Length <- nchar(corp$Text)
prop.table(table(corp$DataSource))

summary(corp$Length)
summary(corp$Length[corp$DataSource=="Tweeter"])
summary(corp$Length[corp$DataSource=="Blog"])
summary(corp$Length[corp$DataSource=="News"])


#dim(corp)

rm(tweet_text, blog_text, news_text, df_txt1, df_txt2, df_txt3)

library(ggplot2)
ggplot(corp, aes(x=Length, fill= DataSource)) +
        theme_bw() +
        geom_histogram(binwidth = 10) +
        coord_cartesian(xlim = c(0, 1000)) +
        labs(y= "Text Count", x= "Length of Text",
             title = "Distro of Text length from Datasources")


library(caret)
set.seed(1234)
#idx <- createDataPartition(corp$DataSource, times = 1, p = 0.7, list = FALSE)
idx <- createDataPartition(corp$DataSource, times = 1, p = 0.02, list = FALSE)
train <- corp[idx,]
test <- corp[-idx,]


# Remove non ASCII words "â"
train$Text <- iconv(train$Text, from = "UTF-8", to = "ASCII" )
sum(is.na(train$Text))/nrow(train) #Proposition of non English words ~ 10%
train <- train[!(is.na(train$Text)),]


library(quanteda)
# Preprocess Corpus
preProcessCorpus <- function (corpusText) {
        # Tokenize text 
        text.tokens <- tokens(corpusText, 
                              what = "word", 
                              remove_punct = TRUE, 
                              remove_numbers = TRUE,
                              remove_symbols = TRUE,
                              remove_hyphens = TRUE)
        
        # convert to lower case
        text.tokens <- tokens_tolower(text.tokens)
        
        # Remove Stop words
        text.tokens <- tokens_select(text.tokens, stopwords(), selection = "remove")
        
        # Filter Profanity words
        prof_list <- read.csv("profanity_words.txt", header = FALSE)
        prof_list$V1 <- as.character(prof_list$V1)
        text.tokens <- tokens_select(text.tokens, prof_list$V1, selection = "remove")
        
        # Stemming
        text.tokens <- tokens_wordstem(text.tokens, language = "english")
        
} 

train.tokens <- preProcessCorpus(train$Text)



#NGrams
myDfm <- dfm(train.tokens, ngrams = 1, verbose = FALSE)
x <- textstat_frequency(myDfm) 

myDfm2 <- dfm(train.tokens, ngrams = 2, verbose = FALSE)
y <- textstat_frequency(myDfm2) 

myDfm3 <- dfm(train.tokens, ngrams = 3, verbose = FALSE)
z <- textstat_frequency(myDfm3) 

# g1 <- data.frame(x[1:20,1:2])
# g1$DataSource <- "1gram"
# g2 <- data.frame(y[1:20,1:2])
# g2$DataSource <- "2gram"
# g3 <- data.frame(z[1:20,1:2])
# g3$DataSource <- "3gram"

# ng <- rbind(g1, g2, g3)
# 
# ggplot(ng, aes(x= reorder(feature, frequency), y=frequency)) +
#         theme_bw() +
#         geom_bar(stat="identity", width = .2)+
#         facet_grid(~DataSource) +
#         labs(y= "Text Count", x= "Word",
#              title = "Top 25 Frequently used words") +
#         coord_flip() 


g1 <- x[1:20,1:2]
g2 <- y[1:20,1:2]
g3 <- z[1:20,1:2]

p1 <- ggplot(g1, aes(x= reorder(feature, frequency), y=frequency)) +
        theme_bw() +
        geom_bar(stat="identity", width = .2)+
        labs(y= "Text Count", x= "Word",
             title = "1 GRAM") +
        coord_flip() 


p2 <- ggplot(g2, aes(x= reorder(feature, frequency), y=frequency)) +
        theme_bw() +
        geom_bar(stat="identity", width = .2)+
        labs(y= "Text Count", x= "Word",
             title = "2 GRAMS") +
        coord_flip() 


p3 <- ggplot(g3, aes(x= reorder(feature, frequency), y=frequency)) +
        theme_bw() +
        geom_bar(stat="identity", width = .2)+
        labs(y= "Text Count", x= "Word",
             title = "3 GRAMS") +
        coord_flip() 

library(gridExtra)
grid.arrange (p1, p2, p3, nrow = 1, top = "Top 25 Frequent NGRAM")
grid.arrange (p1, p2, p3, widths = c(1,1.3,1.7), nrow = 1, top = "Top 25 Frequent NGRAM")


############################################################################
# Create DFM
train.tokens.dfm <- dfm(train.tokens, tolower = FALSE)
dim(train.tokens.dfm)
# for 10% of Train data (ie. 10% of 5% full data set)
# train.tokens.matrix <- as.matrix(train.tokens.dfm) # 2.4GB memory
# train.tokens.df <- data.frame(train.tokens.matrix) # Error: cannot allocate vector of size 167 Kb
# names(train.tokens.df) <- make.names(names(train.tokens.df))

# train.tokens.matrix <- as.matrix(train.tokens.dfm)
# train.tokens.df <- data.frame(train.tokens.matrix)
# rm(train.tokens.matrix)
# names(train.tokens.df) <- make.names(names(train.tokens.df))


# #Explore
# sm <- apply(train.tokens.df, 2, sum)
# sm <- as.data.frame(sm)
# sm2 <- data.frame(word = rownames(sm), counts = sm)
# names(sm2) <- c("word", "counts")
# rownames(sm2) <- NULL
# head(sm2[order(sm2$counts, decreasing = TRUE),], 25)
# g1 <- head(sm2[order(sm2$counts, decreasing = TRUE),], 25)

#train.token.df <- cbind(DataSource = train$DataSource, train.token.df)
set.seed(1234)

# Add bigrams to our feature matrix.
train.tokens <- tokens_ngrams(train.tokens, n = 1:2)
train.tokens[[100]]

# Transform to dfm and then a matrix.
train.tokens.dfm <- dfm(train.tokens, tolower = FALSE)
train.tokens.matrix <- as.matrix(train.tokens.dfm)
train.tokens.dfm


# Normalize all documents via TF.
train.tokens.df <- apply(train.tokens.matrix, 1, term.frequency)


# Calculate the IDF vector 
train.tokens.idf <- apply(train.tokens.matrix, 2, inverse.doc.freq)


# Calculate TF-IDF
train.tokens.tfidf <-  apply(train.tokens.df, 2, tf.idf, 
                             idf = train.tokens.idf)


# Transpose the matrix
train.tokens.tfidf <- t(train.tokens.tfidf)


# Fix incomplete cases
incomplete.cases <- which(!complete.cases(train.tokens.tfidf))
train.tokens.tfidf[incomplete.cases,] <- rep(0.0, ncol(train.tokens.tfidf))


# Make a clean data frame.
train.tokens.tfidf.df <- cbind(Label = train$Label, data.frame(train.tokens.tfidf))
names(train.tokens.tfidf.df) <- make.names(names(train.tokens.tfidf.df))


############################################################################
cv.folds <- createMultiFolds(train$DataSource, k = 10)

cv.cntrl <- trainControl(method = "repeatedcv", number = 5,
                         repeats = 2, index = cv.folds)


#TF ID
# function for calculating relative term frequency (TF)
term.frequency <- function(row) {
        row / sum(row)
}
# function for calculating inverse document frequency (IDF)
inverse.doc.freq <- function(col) {
        corpus.size <- length(col)
        doc.count <- length(which(col > 0))
        
        log10(corpus.size / doc.count)
}

# function for calculating TF-IDF.
tf.idf <- function(x, idf) {
        x * idf
}

rm(train.token.matrix)
rm(train.tokens.df)
rm(train.tokens.tfidf)
gc()

