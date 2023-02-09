# Neil Kanungo
# TIBCO Software
# February 2023
# Nearest Neighbors (Geo)

# Input Parameters: source_longitude, source_latitude, search_longitude, search_latitude
# Output Parameters: closest, lines.df

# Load Libraries
library(geosphere)

#----------------------------------
# FUNCTIONS
#----------------------------------
haversine_distance <- function(lat1, lon1, lat2, lon2) {
  d <- distHaversine(cbind(lon1, lat1), cbind(lon2, lat2))
  return(d)
}

closest_point <- function(point, points) {
  distances <- sapply(1:nrow(points), function(i) {
    haversine_distance(point[2], point[1], points[i, 2], points[i, 1])
  })
  closest_index <- which.min(distances)
  closest_point <- points[closest_index, ]
  print(closest_point)
  return(closest_point)
}

#-----------------------------------
# MAIN CODE
#-----------------------------------
# Bind columns to drop NA rows
source_df <- cbind(source_longitude, source_latitude)
search_df <- cbind(search_longitude, search_latitude)
source_df <- na.omit(source_df)
search_df <- na.omit(search_df)


# Create empty dataframe for Spotfire output
closest <- data.frame(source_longitude=as.numeric(),
                      source_latitude=as.numeric(),
                      found_longitude=as.numeric(),
                      found_latitude=as.numeric())

# Loop through source points and find nearest search point
for (p in 1:nrow(source_df)) {
  point <- c(source_df[p,1],source_df[p,2])
  points <- data.frame(lon = search_df[,1],
                       lat = search_df[,2])
  closest[p,1:2] <- point
  closest[p,3:4] <- closest_point(point, points)
}

# Create a data frame for plotting Lines
coords1 <- data.frame(LineID = 1:nrow(closest),
                      Latitude = closest$source_latitude,
                      Longitude = closest$source_longitude)

coords1$Type = "Source"

coords2 <- data.frame(LineID = 1:nrow(closest),
                      Latitude = closest$found_latitude,
                      Longitude = closest$found_longitude)

coords2$Type = "Found"

lines.df <- rbind(coords1,coords2)
lines.df <- lines.df[order(lines.df$LineID),]

# Result data frames
closest
lines.df