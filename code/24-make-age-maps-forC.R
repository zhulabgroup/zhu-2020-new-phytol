library(tidyverse)
forc_df <- read_csv("data/ForC/ForC_simplified.csv") %>%
  mutate(stand.age = as.numeric(stand.age)) %>%
  filter(
    variable.name == "biomass_ag",
    is.numeric(stand.age),
    !is.na(stand.age),
    stand.age < 999,
    stand.age > 0,
    !is.na(lon),
    !is.na(lat)
  ) %>%
  mutate(stand.age.fewer=stand.age) %>% 
  mutate(stand.age.fewer=ifelse(stand.age.fewer>140,150,stand.age.fewer)) %>% 
  dplyr::select(lon,lat,stand.age.fewer)

summary(forc_df)

## make spatial points data frame and raster
library(sp)
library(raster)
coordinates(forc_df) = ~lon+lat
crs(forc_df)<-"+proj=longlat"

forc_ras<-rasterize(forc_df,raster(),forc_df$stand.age.fewer)

## Boundaries, coastline, and bounding box
# reference: http://geog.uoregon.edu/bartlein/courses/geog490/week07-RMaps.html

shape_path <- "./data/GIS/"
coast_shapefile <- paste(shape_path, "ne_10m_coastline/ne_10m_coastline.shp", sep = "")
bb_shapefile <- paste(shape_path, "ne_10m_wgs84_bounding_box/ne_10m_wgs84_bounding_box.shp", sep = "")
ocean_shapefile <- paste(shape_path, "ne_10m_ocean/ne_10m_ocean.shp", sep = "")

library(rgdal)
layer <- ogrListLayers(coast_shapefile)
coast_lines <- readOGR(coast_shapefile, layer = layer)

layer <- ogrListLayers(bb_shapefile)
bb_poly <- readOGR(bb_shapefile, layer = layer)
bb_lines <- as(bb_poly, "SpatialLines")

layer <- ogrListLayers(ocean_shapefile)
ocean_poly <- readOGR(ocean_shapefile, layer = layer)

## reproject
forc_proj <- spTransform(forc_df, CRS("+proj=robin"))
forc_ras_proj<-projectRaster(forc_ras,crs = CRS("+proj=robin"), over = TRUE)
coast_lines_proj <- spTransform(coast_lines, CRS("+proj=robin"))
bb_poly_proj <- spTransform(bb_poly, CRS("+proj=robin"))
ocean_poly_proj <- spTransform(ocean_poly, CRS("+proj=robin"))

## Color
library(RColorBrewer)
colfunc.forc <- colorRampPalette(c("#F6DDCC", "#B03A2E"),alpha=TRUE)
colfunc.forc.transparent <- colorRampPalette(c("#F6DDCC80", "#B03A2E80"),alpha=TRUE)

#### Plot
# pdf("figs/age-map-robinson-overlay-forC.pdf")
par(mar = c(2, 2, 2, 2))
par(fig = c(0, 10, 0, 10) / 10)

plot(forc_ras_proj, axes = FALSE, box = FALSE, alpha=0, legend = F)
plot(ocean_poly_proj, col = "#1D334A", border = NA,add=T) # 1D334A
plot(coast_lines_proj, col = "white", add = TRUE, lwd = 0.0001)
plot(bb_poly_proj, bor = "black", add = TRUE)
plot(forc_proj, axes = FALSE,  pch=19,cex=0.5,col = colfunc.forc.transparent(15),add=T)
plot(forc_ras_proj,
     axes = FALSE, box = FALSE, col = colfunc.forc(15), zlim = c(0, 150), breaks = seq(0, 150, 10),
     legend.only = TRUE, smallplot = c(0.82, 0.84, 0.5, 0.68),
     axis.args = list(at = c(0, 30, 60, 90, 120, 140, 150), labels = c("0", "30", "60", "90", "120", "140", "140+"), font = 2, cex.axis = 0.6),
     legend.args = list(text = "Forest age (yr)", side = 3, font = 2, line = 0.5, cex = 0.8)
)

par(fig = c(5, 9.5, 2.2, 4.8) / 10)
par(new = T)

hist(forc_df$stand.age.fewer, nclass = 15, fre = FALSE, main = "", ylab = "", xlab = "", ylim = c(0, 0.015), col = colfunc.forc(15), border = "white", axes = FALSE)
axis(side = 1, at = c(0, 50, 100, 140, 150), label = rep("", 5), tck = -0.02, line = 0)
axis(side = 4, at = seq(0, 0.015, 0.005), label = rep("", 4), tck = -0.01, line = 0)
axis(side = 1, at = c(0, 50, 100, 140, 150), labels = c("0", "50", "100", "140", ">140"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 1, at = c(150), labels = c("140+"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 4, at = seq(0, 0.015, 0.005), labels = c("0%", "5%", "10%", "15%"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
mtext("Forest age (yr)", side = 1, line = 0.2, font = 2, cex = 0.4)
mtext("Percentage of sites", side = 4, line = 0.2, font = 2, cex = 0.4)
dev.off()