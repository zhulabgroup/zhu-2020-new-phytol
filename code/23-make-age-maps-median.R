# library(ncdf4)
library(raster)

# get fractions of 4 PFT
frac_NEEV_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 1)
frac_NEDC_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 2)
frac_BRDC_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 3)
frac_BREV_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 4)

# add fractions of all PFTs
frac_sum <- frac_NEEV_brick + frac_NEDC_brick + frac_BRDC_brick + frac_BREV_brick
plot(frac_sum)

# read median age
frac_sum_df <- read.csv("data/GFAD/median-age.csv")[, -1]

# make raster
median_ras <- rasterFromXYZ(frac_sum_df[, c(1, 2, 18)], crs = proj4string(frac_sum))
plot(median_ras)
median_ras[median_ras == 0] <- NA


### Plot

## add boundaries, graticules, and bounding box
# reference: http://geog.uoregon.edu/bartlein/courses/geog490/week07-RMaps.html

shape_path <- "./data/GIS/"
coast_shapefile <- paste(shape_path, "ne_10m_coastline/ne_10m_coastline.shp", sep = "")
grat30_shapefile <- paste(shape_path, "ne_10m_graticules_30/ne_10m_graticules_30.shp", sep = "")
bb_shapefile <- paste(shape_path, "ne_10m_wgs84_bounding_box/ne_10m_wgs84_bounding_box.shp", sep = "")
ocean_shapefile <- paste(shape_path, "ne_10m_ocean/ne_10m_ocean.shp", sep = "")

library(rgdal)
layer <- ogrListLayers(coast_shapefile)
# ogrInfo(coast_shapefile, layer=layer)
coast_lines <- readOGR(coast_shapefile, layer = layer)
# summary(coast_lines)

layer <- ogrListLayers(grat30_shapefile)
# ogrInfo(grat30_shapefile, layer=layer)
grat30_lines <- readOGR(grat30_shapefile, layer = layer)
# summary(grat30_lines)

layer <- ogrListLayers(bb_shapefile)
# ogrInfo(bb_shapefile, layer=layer)
bb_poly <- readOGR(bb_shapefile, layer = layer)
# summary(bb_poly)
bb_lines <- as(bb_poly, "SpatialLines")

layer <- ogrListLayers(ocean_shapefile)
# ogrInfo(ocean_shapefile, layer=layer)
ocean_poly <- readOGR(ocean_shapefile, layer = layer)
# summary(ocean_poly)

## Color
library(RColorBrewer)
colfunc <- colorRampPalette(c("#F0E687", "#085025"))

## reproject
crs(median_ras)
median_ras_proj <- projectRaster(median_ras, crs = CRS("+proj=robin"), over = TRUE)

coast_lines_proj <- spTransform(coast_lines, CRS("+proj=robin"))
bb_poly_proj <- spTransform(bb_poly, CRS("+proj=robin"))
grat30_lines_proj <- spTransform(grat30_lines, CRS("+proj=robin"))
ocean_poly_proj <- spTransform(ocean_poly, CRS("+proj=robin"))

# plot 1 (with projection)
plot(median_ras_proj, axes = FALSE, box = FALSE, col = colfunc(15), legend = F)
plot(ocean_poly_proj, col = "#1D334A", border = NA, add = TRUE) # 1D334A
plot(coast_lines_proj, col = "white", add = TRUE, lwd = 0.0001)
# plot(grat30_lines_proj, col="lightblue", add=TRUE)
plot(bb_poly_proj, bor = "black", add = TRUE)
plot(median_ras_proj,
  axes = FALSE, box = FALSE, col = colfunc(15), zlim = c(0, 15), breaks = seq(0, 15, 1),
  legend.only = TRUE, smallplot = c(0.82, 0.84, 0.5, 0.68),
  axis.args = list(at = c(0, 3, 6, 9, 12, 14, 15), labels = c("0", "30", "60", "90", "120", "140", ">140"), font = 2, cex.axis = 0.6),
  legend.args = list(text = "Forest age (yr)", side = 3, font = 2, line = 0.5, cex = 0.8)
)

# plot 2 (with projection)
hist(na.omit(values(median_ras_proj)), nclass = 15, fre = FALSE, main = "", ylab = "", xlab = "", ylim = c(0, 0.30), col = colfunc(15), border = "white", axes = FALSE)
axis(side = 1, at = c(0, 5, 10, 14, 15), label = rep("", 5), tck = -0.02, line = 0)
axis(side = 4, at = seq(0, 0.30, 0.1), label = rep("", 4), tck = -0.01, line = 0)
axis(side = 1, at = c(0, 5, 10, 14, 15), labels = c("0", "50", "100", "140", ">140"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 1, at = c(15), labels = c(">140"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 4, at = seq(0, 0.30, 0.1), labels = c("0%", "10%", "20%", "30%"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
mtext("Forest age (yr)", side = 1, line = 0.2, font = 2, cex = 0.4)
mtext("Percentage of pixels", side = 4, line = 0.2, font = 2, cex = 0.4)

# overlay
pdf("figures/age-map-median.pdf")
par(mar = c(2, 2, 2, 2))
par(fig = c(0, 10, 0, 10) / 10)

plot(median_ras_proj, axes = FALSE, box = FALSE, col = colfunc(15), legend = F)
plot(ocean_poly_proj, col = "#1D334A", border = NA, add = TRUE) # 1D334A
plot(coast_lines_proj, col = "white", add = TRUE, lwd = 0.0001)
# plot(grat30_lines_proj, col="lightblue", add=TRUE)
plot(bb_poly_proj, bor = "black", add = TRUE)
plot(median_ras_proj,
  axes = FALSE, box = FALSE, col = colfunc(15), zlim = c(0, 15), breaks = seq(0, 15, 1),
  legend.only = TRUE, smallplot = c(0.82, 0.84, 0.5, 0.68),
  axis.args = list(at = c(0, 3, 6, 9, 12, 14, 15), labels = c("0", "30", "60", "90", "120", "140", ">140"), font = 2, cex.axis = 0.6),
  legend.args = list(text = "Forest age (yr)", side = 3, font = 2, line = 0.5, cex = 0.8)
)

# par(fig=c(0.5,3,3,5.5)/10)
par(fig = c(5, 9.5, 2.3, 4.8) / 10)
par(new = T)

hist(na.omit(values(median_ras_proj)), nclass = 15, fre = FALSE, main = "", ylab = "", xlab = "", ylim = c(0, 0.30), col = colfunc(15), border = "white", axes = FALSE)
axis(side = 1, at = c(0, 5, 10, 14, 15), label = rep("", 5), tck = -0.02, line = 0)
axis(side = 4, at = seq(0, 0.30, 0.1), label = rep("", 4), tck = -0.01, line = 0)
axis(side = 1, at = c(0, 5, 10, 14, 15), labels = c("0", "50", "100", "140", ">140"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 1, at = c(15), labels = c(">140"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 4, at = seq(0, 0.30, 0.1), labels = c("0%", "10%", "20%", "30%"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
mtext("Forest age (yr)", side = 1, line = 0.2, font = 2, cex = 0.4)
mtext("Percentage of pixels", side = 4, line = 0.2, font = 2, cex = 0.4)
dev.off()
