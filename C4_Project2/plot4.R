# JHU - Datascience : Exploratory Analysis 
# Assignment 2 : Read Air pollution data and Plot graphs to PNG
# Question 4: Across the United States, how have emissions from coal combustion-related sources changed from 1999-2008?
#
# Version : 1.0
# Created on : 2018.07.14
# Author : thenuv

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

#Subset - Collect Coal related data
c1<- subset(SCC,EI.Sector %in% unique(grep("Coal", EI.Sector, value = TRUE)))
c2<- subset(SCC,SCC.Level.Three %in% unique(grep("Coal", SCC.Level.Three, value = TRUE)))
c3<- subset(SCC,SCC.Level.Four %in% unique(grep("Coal", SCC.Level.Four, value = TRUE)))
c_all <- union(c1$SCC, c2$SCC)
c_all <- union(c_all, c3$SCC)
c_all <- as.data.frame(c_all)
names(c_all) = "SCC"
c_all$SCC <- as.character(c_all$SCC)

p4 <- subset(NEI, SCC %in% c_all$SCC)
p4 <- with(p4, aggregate(Emissions ~ year, FUN = mean, na.rm =  TRUE))


#Plot 
png(filename = "plot4.png", width=480, height = 480)

with (p4, plot(year, Emissions, pch=20, type="o", col="green", main="PM2.5 Emission Trend from Coal combustion Sources", xlab= "Year" ))
dev.off()

#Cleanup
rm(p4, c_all, c1, c2, c3)
rm(NEI)
rm(SCC)

