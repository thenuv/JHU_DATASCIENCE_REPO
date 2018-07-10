______________________________________________________________________________________________________________
## JHU Data Science : Getting and Cleaning Data Course Assingment

______________________________________________________________________________________________________________
###  Data from wearables by human activity.

	This Assingment is based on the data collected based on Human activity recognition on smartphones. 
	(http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
	The data is downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
	This file has information on how the data from source is transformed to meet the requirement of this assignment.
	

______________________________________________________________________________________________________________
### Scope :

*	The data is extracted and build for the variables representing mean and standard deviation.
	Rest of them are filtered out. 
	
*	The final data set has the summary of average by subject and activity. 
	Though the details are processed as part of the script, its not stored/uploaded.
	

______________________________________________________________________________________________________________
### Assumptions :

*	The file names of the data set downloaded are expected to be same and not modified. 
*	The working directory is set to the location where data files exists.(with sub folders test & train)
	

______________________________________________________________________________________________________________
### Files as part of this package:

* codeBook.md : Variables of the data set with a brief description and their unit of measurement
	https://github.com/thenuv/JHU_DATASCIENCE_REPO/blob/master/ProgrammingAssignment3/codeBook.md

* run_analysis.R : R script to cleanse, organise and build the data set.
	https://github.com/thenuv/JHU_DATASCIENCE_REPO/blob/master/ProgrammingAssignment3/run_analysis.R

* wearable_data_avg_summary.csv : Final out put data set summarizing the average of variables by subject, activity.
	https://github.com/thenuv/JHU_DATASCIENCE_REPO/blob/master/ProgrammingAssignment3/wearable_data_avg_summary.csv

	
______________________________________________________________________________________________________________
### Processing done by run_analysis.R :

* Loads libries required (dplyr, readr etc...)
* Imports Activity Lables
* Imports Variable names from features file 
* Sets the flag for the required variables storing Mean and SD as TRUE
* Imports and merge Subject's data captured for training and testing. sets row id.
* Imports and merge Activity details for training and test data. sets row id.
* Imports and merge Measurements of the variables for training and test data.
* Filters the measurements for variables restricting to the required columns.
* Label the column names to represent the variable name. sets row id for the data frame.
* Set descriptive Activity name for the activity detail data.
* Merges Subjects and Activity details using rowid.
* Merges Measurement data with Subject & Activity using row id into data frame named "researchdataset".
* Creates a new data frame "researchdataset_avg" with Summary of Average for SUBJECT, ACTIVITY on the Variables.
* Creates a csv file "wearable_data_avg_summary.csv" from data frame "researchdataset_avg".

______________________________________________________________________________________________________________
### Reference : 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

______________________________________________________________________________________________________________