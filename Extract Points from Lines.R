# Neil Kanungo
# TIBCO Software
# February 2023
# Extract Points from (Poly)lines

library(sp)
library(maptools)
library(rgdal)
library(wkb)
library(geosphere)
library(dplyr)

Proj4<- CRS("+proj=longlat +datum=WGS84 +no_defs") 
sl <- readWKB(sl, as.character(seq_along(sl)), proj4string=Proj4)
beginmeasure <- data.frame(beginmeasure)
endmeasure <- data.frame(endmeasure)
id <- data.frame(id)
newlines <- data.frame()
sl <- as(sl, "SpatialLines")
i <- 0
for (lines in sl@lines) {
	for (line in lines@Lines) {
		i <- i+1
		#extract spatial points from each spatial line
		coords <- line@coords
		segments <- data.frame(coords)
		Longitude <- segments[,1]
		Latitude <- segments[,2]
		n <- nrow(segments)
		
		#calculate the distance between each spatial point
		Measure <- distGeo(segments[1:n-1,],segments[2:n,],6378137,1/298.257223563)*100/2.54/12
		Measure <- data.frame(Measure)
		
		#ensure that the beginning and ending measure match with input data
		Measure <- Measure["Measure"] * ((endmeasure[i,] - beginmeasure[i,])/sum(Measure["Measure"]))
		
		#add beginning measure to calculated measures to line up the spatial points
		Measure <- cumsum(Measure["Measure"]) + beginmeasure[i,]
		
		#add the beginning measure to match the number of points
		Measure <- rbind(beginmeasure[i,],Measure["Measure"])
		segments <- data.frame(Longitude,Latitude,Measure)
		
		#add the interval distance as new rows
		intervals <- data.frame(Measure=seq(floor(beginmeasure[i,]),ceiling(endmeasure[i,]),by=dist.interval))
		segments <- full_join(segments,intervals,by="Measure")
		
		#add the RiverID
		segments <- data.frame(segments,RiverID=id[i,])
		
		#interpolate missing lat/longs
		missingRows <- which(is.na(segments$Longitude))
		Lon <- approx(segments$Measure,segments$Longitude,xout=segments$Measure[missingRows])
		Lon <- as.data.frame(Lon)
		segments$Longitude[missingRows]<-Lon[,2]
		Lat <- approx(segments$Measure,segments$Latitude,xout=segments$Measure[missingRows])
		Lat <- as.data.frame(Lat)
		segments$Latitude[missingRows]<-Lat[,2]
				
		#append new rows
		segments <- arrange(segments,Measure)
		newlines <- rbind(newlines,segments)
	}
}
