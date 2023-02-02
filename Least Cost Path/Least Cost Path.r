#load table camion
camion<-read_excel(pathexcel)

#Load raster
r2<- raster (image)

#calculate altitude per cell
altDiff <- function(x) x[2]/vehi - x[1]/vehi
hd <- transition(r2, altDiff, 8, symm= FALSE)
slope <- geoCorrection(hd)

#Calculate the speed
adj <- adjacent(r2, cells = 1:ncell(r2), pairs = TRUE, directions = 8)
speed <- slope
speed[adj] <- 6 * exp(-3.5 * abs(slope[adj] + 0.05))
Conductance <- geoCorrection(speed)

#creation tables
puit<-SpatialPoints(cbind(long2,lat2), CRS("+init=epsg:4326"))
camion2<-SpatialPoints(cbind(camion$long,camion$lat), CRS("+init=epsg:4326"))

#search for the closest point
puit$nearest_in_set2 <- apply(gDistance(puit,camion2, byid=TRUE), 2, which.min)
numcol<-puit$nearest_in_set2[1]
longlat.camion<-camion2[numcol,]
closestpt<-as.data.frame(longlat.camion)
pt<-SpatialPoints(cbind(closestpt), CRS("+init=epsg:4326"))

#Enter closest start point and end point Lon/LAt/WGS84
A <- c(closestpt$coords.x1,closestpt$coords.x2)
B <- c(long2,lat2)

#Routing calculation
iti <- shortestPath(Conductance, A, B, output = "SpatialLines")
table<-coordinates(iti)

#calculate distance of the path in m
path<- spTransform(iti, CRS("+init=epsg:3857"))
dist<-gLength(path, byid=FALSE)

# Shapefile creation of the path 
d <- data.frame(id=as.factor(1:length(iti)))
iti_wgs84<- SpatialLinesDataFrame(iti, data=d)

#path data table for Spotfire
wkb <- writeWKB(iti_wgs84)

#path data table for Spotfire
r2test<-rasterToContour(r2)
contourwkb<-writeWKB(r2test)

#delete existing shapefile folder
unlink(shape_folder,recursive=T)

#Export of the shapefile of the path
writeOGR(obj=iti_wgs84, dsn=shape_folder, layer=shape_layer, driver="ESRI Shapefile")