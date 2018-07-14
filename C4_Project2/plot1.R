# JHU - Datascience : Exploratory Analysis 
# Assignment 2 : Read Air pollution data and Plot graphs to PNG
# Question 1: Have total emissions from PM2.5 decreased in the United States from 1999 to 2008? 
#
# Version : 1.0
# Created on : 2018.07.14
# Author : thenuv


# Download & unzip the source file
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

# Read Data
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# Plot 
p1<-with(NEI, aggregate(Emissions ~ year, FUN = mean, na.rm=TRUE))
png(filename = "plot1.png", width=480, height = 480)
with (p1, plot(year, Emissions, pch=20, type="o", col="blue", main="PM2.5 Emission Trend in U.S."))
dev.off()

# Cleanup
rm(p1)
rm(NEI)
rm(SCC)
