# Neil Kanungo
# TIBCO Software
# February 2023
# Spatial Join Data Function

library(sf)
library(dplyr)
library(tidyr)
library(lwgeom)

# Input Parameters: table1, table2, buffer, EPSG

# Create tables with ID columns
table1 <- unique(table1)
table2 <- unique(table2)
colnames(table1) <- casefold(colnames(table1),upper=TRUE)
colnames(table2) <- casefold(colnames(table2),upper=TRUE)
table1$table1.id <- 1:nrow(table1)
table2$table2.id <- 1:nrow(table2)

# Create two simple feature point datasets
points1 <- st_as_sf(data.frame(x=table1$LATITUDE, y=table1$LONGITUDE), coords=c("x", "y"), crs=EPSG)
points2 <- st_as_sf(data.frame(x=table2$LATITUDE, y=table2$LONGITUDE), coords=c("x", "y"), crs=EPSG)

points1 <- st_transform(points1, prjEPSG) ## Parameterized (for now)
points2 <- st_transform(points2, prjEPSG)

# Create a buffer around each point with a radius of given meters
buf2 <- st_buffer(points2, dist=buffer) ## TODO - Figure out how to use meters

# Perform the spatial join using the buffered points
result <- st_intersects(points1, buf2,sparse=FALSE)


# Prep Output data
result <- as.data.frame(result)
cols <- ncol(result)
result$table1.id <- 1:nrow(result)

## Merge results of spatial join with table1's attributes
result <- left_join(result,table1, by=c('table1.id'='table1.id'), keep=FALSE)
result <- result %>% pivot_longer(cols=1:cols,names_to="table2.id", values_to="keep.bool")
result$table2.id <- as.integer(gsub("V","",result$table2.id))

## Merge results of spatial join with table2's attributes
result <- left_join(result,table2, by=c('table2.id'='table2.id'), keep=FALSE)

## Calculate distances
distances <- as.data.frame(st_distance(points1,points2))
distances$table1.id <- 1:nrow(distances)
distances <- distances %>% pivot_longer(cols=1:cols,names_to="table2.id", values_to="DISTANCE")
distances$DISTANCE <- as.double(distances$DISTANCE)
distances$table2.id <- as.integer(gsub("V","",distances$table2.id))

# Merge distance calcs with spatial join results, drop unneeded columns/rows
result <- left_join(result,distances, by=c('table1.id'='table1.id','table2.id'='table2.id'),keep=FALSE)
result <- result[result$keep.bool,]
result <- subset(result,select=-c(table1.id,table2.id,keep.bool))

# Debug output
print(head(result,15))
