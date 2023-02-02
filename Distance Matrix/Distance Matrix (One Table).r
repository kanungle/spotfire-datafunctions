# Neil Kanungo
# TIBCO Software
# February 2023
# Distance Matrix (One Table)

# Load Libraries
library(geosphere)
library(dplyr)
library(tidyr)

# Define a data frame of points
df <- data.frame(lat = lat, lon = lon, id = id)
df <- df[complete.cases(df[,c("lat","lon")]),]
df$row.id <- 1:nrow(df)

# Calculate the pairwise distances between all points
output <- as.data.frame(distm(df[,c("lat", "lon")], fun = distHaversine))
cols <- ncol(output)

# Join back id's
output$row.id <- 1:nrow(output)
output <- left_join(output,df,by=c("row.id"="row.id"))

# Unpivot data
names(output) <- gsub(x = names(output), pattern = "V", replacement = "") 
output <- output %>% pivot_longer(cols=1:cols,names_to="compare.id", values_to="Distance")
output$compare.id <- as.integer(output$compare.id)

# Join back id's again
output <- left_join(output,df,by=c("compare.id"="row.id"))

# Clean up output columns
output <- subset(output, select=-c(row.id,compare.id))
colnames(output) <- c("From_Latitude","From_Longitude","From_Identifier","Distance","To_Latitude","To_Longitude","To_Identifier")
output <- output[,c(1,2,3,5,6,7,4)] #Reorder columns
