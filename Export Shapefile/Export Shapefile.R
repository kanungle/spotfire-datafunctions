geometry <- geotable$Geometry
attributes.df <- subset(geotable, select = -c(Geometry))
export_path <- "C:/users/nkanungo/desktop/shapefile" 
poly.type <- "polygons"
proj4<-NA
#---------------------------
# Neil Kanungo
# TIBCO Software
# February 2023
# Export Shapefile


# Required Input Parameters: geometry, attributes.df, export_path, poly.type
# Optional Input Parameters: proj4

# Load Libraries
library(wkb)
library(rgdal)
library(sp)

# Set export paths for shapefile and layer name
export_path <- gsub("/", "\\\\", export_path)
if (substr(export_path, nchar(export_path), nchar(export_path)) == "\\") {
  export_path <- paste0(export_path, "Spotfire Output.SHP")
} else {
  export_path <- paste0(export_path, "\\Spotfire Output.SHP")
}
export_layer <- "Spotfire Layer"

# Convert shape type to uppercase
poly.type <- casefold(poly.type,upper=TRUE)

# Convert geometry column to Well-Known Binary
if (is.null(proj4)) {proj4 <- "+proj=longlat +datum=WGS84"}
wkb.data <- readWKB(geometry, proj4string=CRS(proj4))

# Create Spatial Data Frame
if (grepl("POLYGON", poly.type, fixed = TRUE)){
  spdf <- SpatialPolygonsDataFrame(wkb.data, data = data.frame(attributes.df))
} else if (grepl("LINE", poly.type, fixed = TRUE)){
  spdf <- SpatialLinessDataFrame(wkb.data, data = data.frame(attributes.df))
} else if (grepl("POINT", poly.type, fixed = TRUE)){
  spdf <- SpatialPointsDataFrame(wkb.data, data = data.frame(attributes.df))
} else {
  print("SHAPE TYPE NOT RECOGNIZED.")
}

# Write Shapefile
writeOGR(obj=spdf, dsn=export_path, layer=export_layer, driver="ESRI Shapefile")