# setwd("E:/DataScience/Rwork/data/final/en_US")

#Load Library, N Grams
# library(dplyr)
# library(stringr)
# library(quanteda)

getTriGramObservation <- function(bi_phrase, trigram) {
        t <- data.frame(ngrams=vector(mode = 'character', length = 0),
                        freq=vector(mode = 'integer', length = 0))
        i <- gsub(" ",  "_", paste(bi_phrase, ""))
        #idx <- grep(i, trigram$feature)
        idx <- grep(paste("^",i, sep=""), trigram$feature)
        if (length (idx) > 0 ) {
                t <- trigram[idx, ]
        }
        return(t)
}

getTriGramObservedProb <- function(obsTriGram, biGram, inputText, discount = 0.5 ) {
        if (nrow(obsTriGram)<1 ) return (NULL)
        obsCnt <- filter(biGram, feature == inputText)$frequency[1]
        #obsCnt <- sum(as.numeric(bigram[bigram$feature =="new_york", 2]))
        ## obsTriProb <- mutate(obsTriGram, prob = ((frequency - discount) / obsCnt ) )
        obsTriProb <- mutate(obsTriGram, prob = ((frequency - discount) / sum(frequency) ) )
        colnames(obsTriProb) <- c("ngram", "freq", "prob")

        return(obsTriProb)
}

# Unobserved
getUnobsTriGramTails <- function(obsTriGram, uniGram) {
        obs_trig_tails <- str_split_fixed(obsTriGram, "_", 3)[, 3]
        unobs_trig_tails <- uniGram[!(uniGram$feature %in% obs_trig_tails), ]$feature
        return(unobs_trig_tails)
}

# Alpha Bigram
getAlphaBigram <- function(uniGram, biGrams, Disc=0.5) {
        # get all bigrams that start with unigram
        #regex <- sprintf("%s%s%s", "^", uniGram$ngram[1], "_")
        i <- sprintf("%s%s%s", "^", uniGram$feature[1], "_")
        #i <- paste(uniGram$feature[1], "_", sep = "")
        bigsThatStartWithUnig <- biGrams[grep(i, biGrams$feature),]
        #bigsThatStartWithUnig <- biGrams[grep(paste("^",i, sep=""), biGrams$feature),]
        if(nrow(bigsThatStartWithUnig) < 1) return(0)
        alphaBi <- 1 - (sum  (bigsThatStartWithUnig$frequency - Disc) / uniGram$frequency)
        #alphaBi <- 1 - (sum  (as.numeric(levels(bigsThatStartWithUnig$frequency)[bigsThatStartWithUnig$frequency]) - Disc) / uniGram$frequency)
        return(alphaBi)
}

#3
getBoBigrams <- function(bigPre, unobsTrigTails) {
        w_i_minus1 <- str_split(bigPre, "_")[[1]][2]
        boBigrams <- paste(w_i_minus1, unobsTrigTails, sep = "_")
        return(boBigrams)
}

getObsBoBigrams <- function(bigPre, unobsTrigTails, bigrs) {
        boBigrams <- getBoBigrams(bigPre, unobsTrigTails)
        obs_bo_bigrams <- bigrs[bigrs$feature %in% boBigrams, ]
        return(obs_bo_bigrams)
}

getUnobsBoBigrams <- function(bigPre, unobsTrigTails, obsBoBigram) {
        boBigrams <- getBoBigrams(bigPre, unobsTrigTails)
        unobs_bigs <- boBigrams[!(boBigrams %in% obsBoBigram$feature)]
        return(unobs_bigs)
}

getObsBigProbs <- function(obsBoBigrams, unigs, bigDisc=0.5) {
        first_words <- str_split_fixed(obsBoBigrams$feature, "_", 2)[, 1]
        first_word_freqs <- unigs[unigs$feature %in% first_words, ]
        obsBigProbs <- (obsBoBigrams$frequency - bigDisc) / first_word_freqs$frequency
        obsBigProbs <- data.frame(ngram=obsBoBigrams$feature, prob=obsBigProbs)
        
        return(obsBigProbs)
}

getQboUnobsBigrams <- function(unobsBoBigrams, unigs, alphaBig) {
        # get the unobserved bigram tails
        qboUnobsBigs <- str_split_fixed(unobsBoBigrams, "_", 2)[, 2]
        w_in_Aw_iminus1 <- unigs[!(unigs$feature %in% qboUnobsBigs), ]
        # convert to data.frame with counts
        qboUnobsBigs <- unigs[unigs$feature %in% qboUnobsBigs, ]
        denom <- sum(qboUnobsBigs$frequency, na.rm = TRUE)
        # converts counts to probabilities
        qboUnobsBigs <- data.frame(ngram=unobsBoBigrams,
                                   prob=(alphaBig * qboUnobsBigs$frequency / denom))
        
        return(qboUnobsBigs)
}

#4
getAlphaTrigram <- function(obsTrigs, bigram, triDisc=0.5) {
        if(nrow(obsTrigs) < 1) return(1)
        alphaTri <- 1 - sum((obsTrigs$freq - triDisc) / bigram$freq[1])
        
        return(alphaTri)
}


#
getUnobsTriProbs <- function(bigPre, qboObsBigrams,
                             qboUnobsBigrams, alphaTrig) {
        qboBigrams <- rbind(qboObsBigrams, qboUnobsBigrams)
        qboBigrams <- qboBigrams[order(-qboBigrams$prob), ]
        #qboBigrams <- qboBigrams[complete.cases(qboBigrams),]
        sumQboBigs <- sum(qboBigrams$prob)
        first_bigPre_word <- str_split(bigPre, "_")[[1]][1]
        unobsTrigNgrams <- paste(first_bigPre_word, qboBigrams$ngram, sep="_")
        unobsTrigProbs <- alphaTrig * qboBigrams$prob / sumQboBigs
        unobsTrigDf <- data.frame(ngram=unobsTrigNgrams, prob=unobsTrigProbs)
        
        return(unobsTrigDf)
}


KBO_BiGram <- function(unigram, bigram, gamma2, inpText) {
        
        i <- sprintf("%s%s%s", "^", inpText, "_")
        bigsThatStartWithUnig <- bigram[grep(i, bigram$feature),]
        
        
        if(nrow(bigsThatStartWithUnig) > 0) {
                # Observed Bigram Approach
                obs_bigram <- bigsThatStartWithUnig
                obs_bigram$prop <- (obs_bigram$frequency-gamma2)/sum(obs_bigram$frequency)
                obs_bigram <- obs_bigram[complete.cases(obs_bigram),]
                #obs_bigram <- obs_bigram[order(-obs_bigram$prop),]
                n <- nrow(obs_bigram)
                if (n >10 ) n <- 10
                #barplot(obs_bigram$prop[1:n], names.arg = obs_bigram$feature[1:n], main="Observed Bigram")
                
                names(obs_bigram) <- c("ngram", "freq", "prob")
                obs_bigram$ngram <- word(gsub("_", " ", obs_bigram$ngram), -1)
                return(obs_bigram[1:n, c(1,3)])
                
        } else {
                #Unobserved BiGram
                
                return(data.frame(feature = "Unobserved", frequency = 0))
        }
        
}

predictNextWord <- function (inputText){

        # Validate input
        inpText <- tolower(trimws(inputText))
        
        if (inpText == "") {
                return("Please enter a valid text")
        }
        if (!is.na(word(inpText, -2))) {
                # inpText <- tokens(word(inpText, -2:-1))
                # tokens_wordstem(inpText, language = "english")
                # print(inpText)
                # inpText <-paste(as.character(inpText)[1], as.character(inpText)[2], sep = "_")
                # print("Trigram Approach")
                inpText <-paste(word(inpText, -2), word(inpText, -1), sep = "_")
                trigram_approach <- TRUE
                
        } else if (!is.na(word(inpText, -1))) {
                #print("Bigram Approach")
                inpText <- word(inpText, -1)
                trigram_approach <- FALSE
                # inpText <- tokens(word(inpText, -1))
                # tokens_wordstem(inpText, language = "english")
                # print(inpText)
                # inpText <- as.character(inpText)[1]
        } 

        #
        gamma2 <- 0.5
        gamma3 <- 0.5

        #Load Library, N Grams
        # library(dplyr)
        # library(stringr)
        # library(quanteda)
        

        unigram <- read.csv("unigram.txt", stringsAsFactors = FALSE)[,c("feature", "frequency")]
        unigram  <- unigram[complete.cases(unigram),]
        unigram$frequency <- suppressWarnings(as.numeric(unigram$frequency))
        
        bigram <- read.csv("bigram.txt", stringsAsFactors = FALSE)[,c("feature", "frequency")]
        bigram  <- bigram[complete.cases(bigram),]
        bigram$frequency <- suppressWarnings(as.numeric(bigram$frequency))

        # Call Function to predict Bigram when one word is given
        if (!trigram_approach) {
                pred <- KBO_BiGram (unigram, bigram, gamma2, inpText)
                return(pred)
        }
        
        trigram <- read.csv("trigram.txt", stringsAsFactors = FALSE)[,c("feature", "frequency")]
        trigram  <- trigram[complete.cases(trigram),]
        trigram$frequency <- suppressWarnings(as.numeric(trigram$frequency))

        
        # Call functions to predict using KBO Model (Trigram)
        
        #Observed Values
        obsTriGram <- getTriGramObservation(inpText, trigram)
        qbo_obs_trig <- getTriGramObservedProb(obsTriGram[,1:2], bigram, inpText, gamma3)
        # head(qbo_obs_trig)

        #Unobserved Tri Grams
        unobs_trig_tails <- getUnobsTriGramTails(obsTriGram$feature, unigram)
        #str(unobs_trig_tails)
        
        #Get Alpha Bigram
        unig <- str_split(inpText, "_")[[1]][2]
        unig <- unigram[unigram$feature == unig,]
        alpha_big <- getAlphaBigram(unig, bigram, gamma2)
        #str(alpha_big)
        
        #Observed Bi Grams
        bo_bigrams <- getBoBigrams(inpText, unobs_trig_tails)  # get backed off bigrams
        obs_bo_bigrams <- getObsBoBigrams(inpText, unobs_trig_tails, bigram)
        unobs_bo_bigrams <- getUnobsBoBigrams(inpText, unobs_trig_tails, obs_bo_bigrams)
        qbo_obs_bigrams <- getObsBigProbs(obs_bo_bigrams, unigram, gamma2) 
        
        #Unobserved Bi Grams
        qbo_unobs_bigrams <- getQboUnobsBigrams(unobs_bo_bigrams, unigram, alpha_big)
        qbo_bigrams <- rbind(qbo_obs_bigrams, qbo_unobs_bigrams)
        # str(qbo_bigrams)
        
        #Get Alpha Trigram
        biGram <- bigram[bigram$feature %in% inpText, ]
        alpha_trig <- getAlphaTrigram(obsTriGram, biGram, gamma3)
        # str(alpha_trig)
        
        #
        qbo_unobs_bigrams <- qbo_unobs_bigrams[complete.cases(qbo_unobs_bigrams),]
        qbo_unobs_trigrams <- getUnobsTriProbs(inpText, qbo_obs_bigrams,
                                               qbo_unobs_bigrams, alpha_trig)
        #str(qbo_unobs_trigrams)

        # Return data frame of top 10 possible words
        qbo_obs_trigrams <- qbo_obs_trig[,c(1,3)]
        qbo_trigrams <- rbind(qbo_obs_trigrams, qbo_unobs_trigrams)
        qbo_trigrams <- qbo_trigrams[order(-qbo_trigrams$prob), ]  # sort by desc prob
        
        # prediction <- str_split(qbo_trigrams$ngram[1], "_")[[1]][3]
        # print(prediction)
        
        qbo_trigrams <- qbo_trigrams[complete.cases(qbo_trigrams),]
        n <- nrow(qbo_trigrams)
        if (n > 10)     n <- 10

        #qbo_trigrams[1:10,]
        pred <- qbo_trigrams[1:n,]
        pred$ngram <- word(gsub("_", " ", pred$ngram), -1)
        #pred <- data.frame("NextPossibleWord" = word(gsub("_", " ", qbo_trigrams$ngram), -1) ,"Probability" = qbo_trigrams$prob)
        
        # qbo_bigrams <- qbo_bigrams[order(-qbo_bigrams$prob), ]  # sort by desc prob
        # pred2 <- qbo_bigrams[1:5,]
        # pred2$ngram <- word(gsub("_", " ", pred2$ngram), -1)
        # # print(head(qbo_bigrams, 5))
        # # print(head(qbo_trigrams, 5))
        # # print(head(pred, 5))
        # # print(head(pred2, 5))
        # 
        # pred <- rbind(pred, pred2)
        pred <- pred[order(-pred$prob), ]
        #print(unique(pred))
        return(pred)
}

#predictNextWord("new york")