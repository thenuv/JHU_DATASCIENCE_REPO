# JHU - Datascience : Exploratory Analysis 
# Assignment 2 : Read Air pollution data and Plot graphs to PNG
# Question 6: Compare emissions from motor vehicle sources in Baltimore City with Los Angeles County, California
#               Which city has seen greater changes over time in motor vehicle emissions?
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

#Subset
#Motor Vechile SCC
r1<- subset(SCC,EI.Sector %in% unique(grep("Road", EI.Sector, value = TRUE)))
r2<- subset(SCC,SCC.Level.Three %in% unique(grep("Road", SCC.Level.Three, value = TRUE)))
r3<- subset(SCC,SCC.Level.Four %in% unique(grep("Road", SCC.Level.Four, value = TRUE)))
r_all <- union(r1$SCC, r2$SCC)
r_all <- union(r_all, r3$SCC)
r_all  <- as.data.frame(r_all)
names(r_all) = "SCC"
r_all$SCC <- as.character(r_all$SCC)


df_Baltimore <- subset(NEI, fips=="24510" & SCC %in% r_all$SCC)
df_LosAngeles <- subset(NEI, fips=="06037" & SCC %in% r_all$SCC)

df_B <- with(df_Baltimore, aggregate(Emissions ~ year, FUN = mean, na.rm =  TRUE))
df_L <- with(df_LosAngeles, aggregate(Emissions ~ year, FUN = mean, na.rm =  TRUE))
p6 <- merge(df_B, df_L, by = "year")

rng <- range(p6$Emissions.x, p6$Emissions.y)


#Plot 
png(filename = "plot6.png", width=480, height = 480)

with (p6, plot(year, Emissions.x, pch=20, type="o", col="brown", ylim = rng, main=" Motor Vechile Emission : Baltimore vs Los Angeles", xlab= "Year", ylab="Emission PM2.5") )
with (p6, lines(year, Emissions.y, pch=20, type="o", col="darkgreen"))
legend("topright", lty=c(1, 1), col= c("brown", "darkgreen"), legend = c("Baltimore", "Los Angeles" ))

#abline(lm(p6$Emissions.x ~ p6$year), col="brown") # Regression Line
#abline(lm(p6$Emissions.y ~ p6$year), col="darkgreen") # Regression Line

dev.off()

#Cleanup
rm(p6, r_all, r1, r2, r3, df_Baltimore, df_B, df_LosAngeles, df_L, rng)
rm(NEI)
rm(SCC)

