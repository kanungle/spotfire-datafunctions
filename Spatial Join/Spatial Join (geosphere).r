# Neil Kanungo
# TIBCO Software
# February 2023
# Spatial Join Data Function

library(geosphere)
library(dplyr)
library(tidyr)

# Input Parameters: table1, table2, buffer

# Create tables with ID columns
colnames(table1) <- casefold(colnames(table1),upper=TRUE)
colnames(table2) <- casefold(colnames(table2),upper=TRUE)
table1 <- unique(table1)
table2 <- unique(table2)
table1 <- table1[complete.cases(table1[,c("LATITUDE","LONGITUDE")]),]
table2 <- table2[complete.cases(table2[,c("LATITUDE","LONGITUDE")]),]
table1$table1.id <- 1:nrow(table1)
table2$table2.id <- 1:nrow(table2)

# Calculate Distance Matrix
result <- distm(cbind(table1$LONGITUDE, table1$LATITUDE), cbind(table2$LONGITUDE, table2$LATITUDE), fun = distHaversine)

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
result <- result[which(result$DISTANCE <= buffer),]
result <- subset(result,select=-c(table1.id,table2.id))

# Debug output
print(head(result,15))
