# Neil Kanungo
# TIBCO Software
# February 2023
# Spatially Join Points

library(sf)

buffer
lat1
lon1
lat2
lon2
EPSG

# Create two simple feature point datasets
points1 <- st_as_sf(data.frame(x=lat1, y=lon1), coords=c("x", "y"), crs=EPSG)
points2 <- st_as_sf(data.frame(x=lat2, y=lon2), coords=c("x", "y"), crs=EPSG)

st_crs(points1) <- 3857
st_crs(points2) <- 3857

# Create a buffer around each point with a radius of 0.5 units
buf1 <- st_buffer(points1, dist=0.5)
buf2 <- st_buffer(points2, dist=0.5)

# Perform the spatial join using the buffered points
result <- st_join(buf1, buf2)
result <- st_transform(result, crs=3857)
result <- st_coordinates(result)