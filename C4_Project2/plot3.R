# JHU - Datascience : Exploratory Analysis 
# Assignment 2 : Read Air pollution data and Plot graphs to PNG
# Question 3: Of the four types of sources indicated by the type (point, nonpoint, onroad, nonroad) variable, 
#               which of these four sources have seen decreases in emissions from 1999-2008 for Baltimore City? 
#               Which have seen increases in emissions from 1999-2008?
#
# Version : 1.0
# Created on : 2018.07.14
# Author : thenuv


# Load Libraries
library(dplyr)
library(ggplot2)

#Download & unzip the source file
fileurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
filename <- "emission_data.zip"
filename1 <- "Source_Classification_Code.rds"
filename2 <- "summarySCC_PM25.rds"

if (!file.exists(filename)) {
        download.file(fileurl, filename)
}
if (!(file.exists(filename1) | file.exists(filename2))) {
        unzip(filename)
}

#Read Data
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

#Subset
df_Baltimore <- subset(NEI, fips=="24510")
p3 <- df_Baltimore %>% select(type, year, Emissions ) %>% group_by (type, year) %>% summarize (Emissions = mean(Emissions, na.rm = TRUE) )


#Plot 
png(filename = "plot3.png", width=720, height = 720)

g <- ggplot(p3, aes(year, Emissions)) + facet_grid(.~type)
g <- g + geom_line(col=c("red")) + ggtitle("PM2.5 Emission in Baltimore")  + xlab("Year")
g <- g + theme (plot.title = element_text(color= "blue", size = 14, face = "bold", hjust = 1/2), axis.title.x= element_text(face="bold"), axis.title.y = element_text(face="bold"))
print(g)

dev.off()

#Cleanup
rm(p3)
rm(df_Baltimore)
rm(NEI)
rm(SCC)
