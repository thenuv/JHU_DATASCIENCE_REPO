## JHU - Getting and cleaning data course project

# Description : This script reads data collected from wearables and organises them to provide a data set that can be used for analysis.
#
# Scope : Data is filtered to the required Mean and Standard deviation measurements
#
# Assumptions : current directory set to location where datafiles exist
#       
# Version : 1.0
# Created on : 2018.07.10
# Author : thenuv

# Load Libraries
library("tidyr")
library("stringr")
library("readr")
library("dplyr")
library("data.table")


# Import Activity Lables
activitylabes <- fread("activity_labels.txt", sep = " ", header= FALSE)
names(activitylabes) <- c("activitycode", "activitydesc")


# Import Variable names from features file 
featureslist <- fread("features.txt", sep = " ", header= FALSE)
names(featureslist) <- c("colid", "variablename")

# Flag the required variables for Mean and SD as TRUE
featureslist <- mutate(featureslist , required = variablename %in% c(grep("mean\\(\\)", variablename, value=TRUE), grep("std\\(\\)", featureslist$variablename , value = TRUE)))

# Import and merge Subject's data captured for training and testing
subjects <- fread("test/subject_test.txt", sep = " ", header= FALSE)
subjects2 <- fread("train/subject_train.txt", sep = " ", header= FALSE)
subjects <- rbind(subjects , subjects2)
names(subjects) <- "subjectid"
subjects$rowid <- seq.int(nrow(subjects))
rm(subjects2)

# Import and merge Activity details for training and test data
activitydetail <- fread("test/y_test.txt", sep = " ", header= FALSE)
activitydetail2 <- fread("train/y_train.txt", sep = " ", header= FALSE)
activitydetail <- rbind(activitydetail, activitydetail2)
names(activitydetail) <- "activitycode"
activitydetail$rowid <- seq.int(nrow(activitydetail))
rm(activitydetail2)

# Import and merge Measurements of the variables for training and test data
measuretest <- fread("test/X_test.txt", sep = " ", header= FALSE)
measuretest2 <- fread("train/X_train.txt", sep = " ", header= FALSE)
measuretest <- rbind(measuretest , measuretest2)
rm(measuretest2)

# Store Required columns (mean and sd)
colnames <- select(featureslist, variablename, required, colid ) %>% filter(required == TRUE)  %>% select(variablename, colid)

# Assing the measurements for variables restricting to the required columns
measuretest <- select(measuretest, colnames$colid) 

# Label the column names to represent the variable name
setnames(measuretest , colnames$variablename)
measuretest$rowid <- seq.int(nrow(measuretest))

# Set descriptive Activity name for the activity detail data
activitydetail <- merge(activitydetail, activitylabes)
activitydetail <- arrange(activitydetail, rowid)

# Merge Subjects and Activity details
researchdataset <- merge(subjects, activitydetail, by.x = "rowid", by.y = "rowid")

# Merge Measurement data with Subject & Activity
researchdataset <- merge(researchdataset, measuretest, by.x = "rowid", by.y = "rowid")

# Create a new data set with Summary of Average for SUBJECT, ACTIVITY on the Variables
researchdataset_avg <- researchdataset %>% select (-1,-3) %>% group_by( subjectid, activitydesc) %>% summarise_all(mean, na.rm=T)

# Create a csv file for the above
write.csv (researchdataset_avg, file= 'wearable_data_avg_summary.csv', row.names=FALSE)

# z<- fread("wearable_data_avg_summary.csv", sep = ",", header= TRUE)








