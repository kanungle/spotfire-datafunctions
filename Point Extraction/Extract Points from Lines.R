# Neil Kanungo
# TIBCO Software
# February 2023
# Extract Points from Lines

# Load Libraries
library(rgdal)
library(sf)
library(geosphere)
library(dplyr)

# Hide warnings
options(warn=-1)

# Create initial dataframe
myLines = as.data.frame(identifier)

# Create row.id
myLines$row.id = 1:nrow(myLines)

# read the WKB data of te currentLine
wkb_lines = readWKB(geometry)

# convert the WKB data to simple features
lines_sf = st_as_sf(wkb_lines)

# extract the coordinates of the lines
lines_df = as.data.frame(st_coordinates(lines_sf))

# Drop geometry from memory
myLines = subset(myLines,select=c(row.id,identifier))

# Join Line ID to Coordinates
lines_df = left_join(lines_df,myLines, by=c("L1"="row.id"))

# Create Output Dataframe
output = data.frame(Longitude=as.numeric(),
                       Latitude=as.numeric(),
                       Identifier=as.character(),
                       Measure=as.numeric())

for (line in unique(lines_df$L1)) {
  # Select points of a single line
  currentLine = lines_df[lines_df$L1 == line,]
  
  # Calculate distances between those points
  for (point in 1:(nrow(currentLine)-1)){
    distance[point] = distHaversine(cbind(currentLine$X[point:(point+1)],currentLine$Y[point:(point+1)]))
  }
  currentLine$distance[2:(nrow(currentLine))] = distance
  currentLine$distance[1]=0
  
  # Cumulatively sum the distance measures
  currentLine$distance = cumsum(currentLine$distance)
  
  # Find the total line length
  lineLength = floor(max(currentLine$distance))
  
  # Merge in interval lengths
  newDistances = data.frame(distance=seq(from=0,to=lineLength,by=interval))
  currentLine = full_join(currentLine,newDistances)
  currentLine$identifier = currentLine$identifier[1]
  currentLine$L1 = currentLine$L1[1]
  currentLine <- arrange(currentLine,distance)
  currentLine <- unique(currentLine)
  
  # Interpolate missing Latitude and Longitudes
  missingRows <- which(is.na(currentLine$X))
  Lon <- approx(currentLine$distance,currentLine$X,xout=currentLine$distance[missingRows])
  Lat <- approx(currentLine$distance,currentLine$Y,xout=currentLine$distance[missingRows])
  currentLine$X[missingRows]<-Lon$y
  currentLine$Y[missingRows]<-Lat$y
  
  # Drop unneeded columns
  currentLine = subset(currentLine,select=-L1)
  
  # Rename columns
  colnames(currentLine) = c("Longitude","Latitude","Identifier","Measure")
  
  # Merge into output dataframe
  output = rbind(output,currentLine)
}

#Debug
print(output)

# Copyright (c) 2023. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file
