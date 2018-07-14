# JHU - Datascience : Exploratory Analysis 
# Assignment 2 : Read Air pollution data and Plot graphs to PNG
# Question 5: How have emissions from motor vehicle sources changed from 1999-2008 in Baltimore City?
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

#Subset (Road related data)
r1<- subset(SCC,EI.Sector %in% unique(grep("Road", EI.Sector, value = TRUE)))
r2<- subset(SCC,SCC.Level.Three %in% unique(grep("Road", SCC.Level.Three, value = TRUE)))
r3<- subset(SCC,SCC.Level.Four %in% unique(grep("Road", SCC.Level.Four, value = TRUE)))
r_all <- union(r1$SCC, r2$SCC)
r_all <- union(r_all, r3$SCC)
r_all  <- as.data.frame(r_all)
names(r_all) = "SCC"
r_all$SCC <- as.character(r_all$SCC)

df_Baltimore <- subset(NEI, fips=="24510")
p5 <- subset(df_Baltimore, SCC %in% r_all$SCC)
p5 <- with(p5, aggregate(Emissions ~ year, FUN = mean, na.rm =  TRUE))


#Plot 
png(filename = "plot5.png", width=480, height = 480)

with (p5, plot(year, Emissions, pch=20, type="o", col="steelblue", main="PM2.5 Emission Trend from Motor Vechile Sources", xlab= "Year" ))

dev.off()

#Cleanup
rm(p5, r_all, r1, r2, r3)
rm(NEI)
rm(SCC)

