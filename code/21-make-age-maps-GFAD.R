# library(ncdf4)
library(raster)

# get fractions of 4 PFT
frac_NEEV_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 1)
frac_NEDC_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 2)
frac_BRDC_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 3)
plot(frac_BRDC_brick[[2]]) # diff protocol inf diff admin unit?
frac_BREV_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 4)

# mosaic fractions from all age classes
frac_NEEV <- sum(frac_NEEV_brick)
frac_NEDC <- sum(frac_NEDC_brick)
frac_BRDC <- sum(frac_BRDC_brick)
frac_BREV <- sum(frac_BREV_brick)

# compute total fraction of vegetation (not always 100%)
frac_veg <- sum(brick(frac_NEEV, frac_NEDC, frac_BRDC, frac_BREV))
plot(frac_veg)

# a function to multiply fraction by average age
calc_age <- function(bri) {
  bri[[1]] <- bri[[1]] * (1 + 10) / 2
  bri[[2]] <- bri[[2]] * (11 + 20) / 2
  bri[[3]] <- bri[[3]] * (21 + 30) / 2
  bri[[4]] <- bri[[4]] * (31 + 40) / 2
  bri[[5]] <- bri[[5]] * (41 + 50) / 2
  bri[[6]] <- bri[[6]] * (51 + 60) / 2
  bri[[7]] <- bri[[7]] * (61 + 70) / 2
  bri[[8]] <- bri[[8]] * (71 + 80) / 2
  bri[[9]] <- bri[[9]] * (81 + 90) / 2
  bri[[10]] <- bri[[10]] * (91 + 100) / 2
  bri[[11]] <- bri[[11]] * (101 + 110) / 2
  bri[[12]] <- bri[[12]] * (111 + 120) / 2
  bri[[13]] <- bri[[13]] * (121 + 130) / 2
  bri[[14]] <- bri[[14]] * (131 + 140) / 2
  bri[[15]] <- bri[[15]] * (141 + 150) / 2
  return(bri)
}

# compute fraction x age
agexfrac_NEEV_brick <- calc_age(frac_NEEV_brick)
agexfrac_NEDC_brick <- calc_age(frac_NEDC_brick)
agexfrac_BRDC_brick <- calc_age(frac_BRDC_brick)
agexfrac_BREV_brick <- calc_age(frac_BREV_brick)

# mosaic fraction x age from all age classes
agexfrac_NEEV <- sum(agexfrac_NEEV_brick)
agexfrac_NEDC <- sum(agexfrac_NEDC_brick)
agexfrac_BRDC <- sum(agexfrac_BRDC_brick)
agexfrac_BREV <- sum(agexfrac_BREV_brick)

# compute total fraction x age
agexfrac_veg <- sum(brick(agexfrac_NEEV, agexfrac_NEDC, agexfrac_BRDC, agexfrac_BREV))
plot(agexfrac_veg)

# divide by fraction of vegetation
age_veg <- agexfrac_veg / frac_veg
plot(age_veg) # this is the age map we want

## admin unit
admin <- raster("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", varname = "adminunit")
plot(admin)

par(mfrow = c(1, 2))
plot(age_veg)
plot(admin)
par(mfrow = c(1, 1))

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

## reproject
crs(age_veg)
age_veg_proj <- projectRaster(age_veg, crs = CRS("+proj=robin"), over = TRUE)

coast_lines_proj <- spTransform(coast_lines, CRS("+proj=robin"))
bb_poly_proj <- spTransform(bb_poly, CRS("+proj=robin"))
grat30_lines_proj <- spTransform(grat30_lines, CRS("+proj=robin"))
ocean_poly_proj <- spTransform(ocean_poly, CRS("+proj=robin"))

## Color
library(RColorBrewer)
colfunc.gfad <- colorRampPalette(c("#F0E687", "#085025"))

# # plot (without projection)
# pdf("figs/age-map-newcolor.pdf")
# plot(age_veg,
#   axes = FALSE, box = FALSE, col = colfunc.gfad(15), zlim = c(0, 150), breaks = seq(0, 150, 10),
#   axis.args = list(at = seq(0, 150, 30), labels = seq(0, 150, 30))
# )
# plot(ocean_poly, col = "#1D334A", border = NA, add = TRUE) # 1D334A
# plot(coast_lines, col = "white", add = TRUE, lwd = 0.0001)
# plot(grat30_lines, col = "lightblue", add = TRUE)
# plot(bb_lines, col = "black", add = TRUE)
# dev.off()

# # plot (with projection)
# pdf("figs/age-map-robinson-newcolor-newlegend.pdf")
# plot(age_veg_proj,
#   axes = FALSE, box = FALSE, col = colfunc.gfad(15), zlim = c(0, 150), breaks = seq(0, 150, 10),
#   axis.args = list(at = seq(0, 150, 30), labels = seq(0, 150, 30), font = 2),
#   legend.args = list(text = paste("Forest Age (Year)"), side = 4, font = 2, line = 2.5)
# )
# plot(ocean_poly_proj, col = "#1D334A", border = NA, add = TRUE) # 1D334A
# plot(coast_lines_proj, col = "white", add = TRUE, lwd = 0.0001)
# # plot(grat30_lines_proj, col="lightblue", add=TRUE)
# plot(bb_poly_proj, bor = "black", add = TRUE)
# dev.off()
#
# pdf("figs/histogram-newfont.pdf", height = 4, width = 7)
# hist(na.omit(values(age_veg)), nclass = 15, fre = FALSE, main = "", ylab = "Percentage of pixels", xlab = "Forest Age (Year)", col = colfunc.gfad(15), border = "white", xaxt = "n", yaxt = "n", font.lab = 2)
# axis(side = 1, at = seq(0, 150, 30), labels = seq(0, 150, 30), font = 2)
# axis(side = 2, at = seq(0, 0.015, 0.003), labels = seq(0, 0.15, 0.03), font = 2)
# dev.off()

# overlay plot
# pdf("figs/age-map-robinson-overlay-140+.pdf")
par(mar = c(2, 2, 2, 2))
par(fig = c(0, 10, 0, 10) / 10)

plot(age_veg_proj, axes = FALSE, box = FALSE, col = colfunc.gfad(15), legend = F)
plot(ocean_poly_proj, col = "#1D334A", border = NA, add = TRUE) # 1D334A
plot(coast_lines_proj, col = "white", add = TRUE, lwd = 0.0001)
# plot(grat30_lines_proj, col="lightblue", add=TRUE)
plot(bb_poly_proj, bor = "black", add = TRUE)
plot(age_veg_proj,
  axes = FALSE, box = FALSE, col = colfunc.gfad(15), zlim = c(0, 150), breaks = seq(0, 150, 10),
  legend.only = TRUE, smallplot = c(0.82, 0.84, 0.5, 0.68),
  axis.args = list(at = c(0, 30, 60, 90, 120, 140, 150), labels = c("0", "30", "60", "90", "120", "140", "140+"), font = 2, cex.axis = 0.6),
  legend.args = list(text = "Forest age (yr)", side = 3, font = 2, line = 0.5, cex = 0.8)
)

# par(fig=c(0.5,3,3,5.5)/10)
par(fig = c(5, 9.5, 2.2, 4.8) / 10)
par(new = T)

hist(na.omit(values(age_veg_proj)), nclass = 15, fre = FALSE, main = "", ylab = "", xlab = "", ylim = c(0, 0.015), col = colfunc.gfad(15), border = "white", axes = FALSE)
axis(side = 1, at = c(0, 50, 100, 140, 150), label = rep("", 5), tck = -0.02, line = 0)
axis(side = 4, at = seq(0, 0.015, 0.005), label = rep("", 4), tck = -0.01, line = 0)
axis(side = 1, at = c(0, 50, 100, 140, 150), labels = c("0", "50", "100", "140", ">140"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 1, at = c(150), labels = c("140+"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 4, at = seq(0, 0.015, 0.005), labels = c("0%", "5%", "10%", "15%"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
mtext("Forest age (yr)", side = 1, line = 0.2, font = 2, cex = 0.4)
mtext("Percentage of pixels", side = 4, line = 0.2, font = 2, cex = 0.4)
