# Neil Kanungo
# TIBCO Software
# February 2023
# Distance Matrix (Two Table)

library(geosphere)
library(dplyr)
library(tidyr)

# Input Parameters: lat1, lon1, lat2, lon2, id1, id2
# Output Parameters: result

# Create tables with ID columns
table1 <- data.frame(Latitude = lat1,
                     Longitude = lon1,
                     ID=id1)
table2 <- data.frame(Latitude=lat2,
                     Longitude=lon2,
                     ID=id2)
table1 <- unique(table1)
table2 <- unique(table2)
table1 <- table1[complete.cases(table1[,c("Latitude","Longitude")]),]
table2 <- table2[complete.cases(table2[,c("Latitude","Longitude")]),]
table1$table1.id <- 1:nrow(table1)
table2$table2.id <- 1:nrow(table2)

# Calculate Distance Matrix
result <- distm(cbind(table1$Longitude, table1$Latitude), cbind(table2$Longitude, table2$Latitude), fun = distHaversine)

# Prep Output data
result <- as.data.frame(result)
cols <- ncol(result)
result$table1.id <- 1:nrow(result)

## Merge results of spatial join with table1's attributes
result <- left_join(result,table1, by=c('table1.id'='table1.id'), keep=FALSE)
result <- result %>% pivot_longer(cols=1:cols,names_to="table2.id", values_to="DISTANCE")
result$table2.id <- as.integer(gsub("V","",result$table2.id))

## Merge results of spatial join with table2's attributes
result <- left_join(result,table2, by=c('table2.id'='table2.id'), keep=FALSE)

# Filter below specified buffer distance, drop unneeded columns/rows
result <- subset(result,select=-c(table1.id,table2.id))

# Debug output
print(head(result,15))