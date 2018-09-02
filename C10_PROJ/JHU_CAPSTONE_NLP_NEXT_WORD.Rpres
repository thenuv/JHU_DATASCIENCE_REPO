THE NEXT POSSIBLE WORD
========================================================
author: Thenappan Veerappan
date: 09.01.2018
autosize: true

Overview
========================================================

This application gives the possible next word with prediction based on Katz Back Off model. A 5% sample of data from News, Blogs & Twitter was randomly picked using binomial logic to get a proportionate data of total volume. The sample corpus was used to build the ngrams. The prediction is done based on the pre processed ngram.



How to Use
========================================================
- Type in few words in the Text box in the left of the application and submit. 
- The output tab will display the possible next word with a graph for top 5 words with higher probability. 
- A table below displays first 10 possible words with their probability.



Preprocessing
========================================================
The Corpus is built with the following approach. 
- Sample data is partitioned to create 2 set of 70% and 30% for Training and Testing.
- Non ASCII words are removed
- Tokenization
- Convert Case
- Remove Stop words
- Profanity Filtering
- Steming


Prediction Model
========================================================

Katz Back Off model is applied to predict the next word the user could type based on the history from sample corpus. The discount rates gamma2 and gamma3 were set at 0.5 for redistributing the probablity of unobserved words. 


