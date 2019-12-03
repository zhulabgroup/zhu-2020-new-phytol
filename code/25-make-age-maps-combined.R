#### GFAD data

# library(ncdf4)
library(raster)

# tag <-  "Mean"
tag <-"Median"

if (tag == "Mean") {
  # get fractions of 4 PFT
  frac_NEEV_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 1)
  frac_NEDC_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 2)
  frac_BRDC_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 3)
  frac_BREV_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 4)
  
  # mosaic fractions from all age classes
  frac_NEEV <- sum(frac_NEEV_brick)
  frac_NEDC <- sum(frac_NEDC_brick)
  frac_BRDC <- sum(frac_BRDC_brick)
  frac_BREV <- sum(frac_BREV_brick)
  
  # compute total fraction of vegetation (not always 100%)
  frac_veg <- sum(brick(frac_NEEV, frac_NEDC, frac_BRDC, frac_BREV))
  
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
  
  # divide by fraction of vegetation
  age_veg <- agexfrac_veg / frac_veg
  
} else if (tag == "Median") {
  # read median age
  age_veg_df <- read.csv("./data/GFAD/median-age.csv")[, -1] # this file generated using 22-calc-median-age.R
  
  # make raster
  age_veg <- rasterFromXYZ(age_veg_df[, c(1, 2, 18)], crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  age_veg[age_veg == 0] <- NA
  age_veg<-age_veg*10
}

#### ForC data
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
crs(forc_df)<-"+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

forc_ras<-rasterize(forc_df,age_veg,forc_df$stand.age.fewer)

#### Boundaries, coastline, and bounding box
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

#### reproject
age_veg_proj <- projectRaster(age_veg, crs = CRS("+proj=robin"), over = TRUE)
forc_proj <- spTransform(forc_df, CRS("+proj=robin"))
forc_ras_proj<-projectRaster(forc_ras,crs = CRS("+proj=robin"), over = TRUE)

coast_lines_proj <- spTransform(coast_lines, CRS("+proj=robin"))
bb_poly_proj <- spTransform(bb_poly, CRS("+proj=robin"))
ocean_poly_proj <- spTransform(ocean_poly, CRS("+proj=robin"))

#### Color
library(RColorBrewer)
colfunc.gfad <- colorRampPalette(c("#F0E687", "#085025"))
colfunc.forc <- colorRampPalette(c("#F6DDCC", "#B03A2E"),alpha=TRUE)
colfunc.forc.transparent <- colorRampPalette(c("#F6DDCC80", "#B03A2E80"),alpha=TRUE)

### Make figure
filename<-paste("figs/age-map-forC and GFAD (",tag,").pdf",sep="")
pdf(filename)

#layout
par(mar = c(0, 0, 0, 0))
par(fig = c(0, 10, 0, 10) / 10)
plot.new()

# ForC
par(fig = c(0, 1, 9, 10) / 10)
par(new=T)
plot(-1:1, -1:1,  xaxt = 'n', yaxt = 'n', bty = 'n', pch = '', ylab = '', xlab = '')
text(0,0, "(a)", font=2)

par(fig = c(0, 10, 5.75, 10) / 10)
par(new=T)
plot(forc_ras_proj, axes = FALSE, box = FALSE, alpha=0, legend = F)

par(fig = c(0, 10, 5.75, 10) / 10)
par(new=T)
plot(ocean_poly_proj, col = "#1D334A", border = NA, add = TRUE) # 1D334A
plot(coast_lines_proj, col = "white", add = TRUE, lwd = 0.0001)
plot(bb_poly_proj, bor = "black", add = TRUE)

par(fig = c(0, 10, 5.75, 10) / 10)
par(new=T)
plot(forc_proj, axes = FALSE,  pch=19,cex=0.5,col = colfunc.forc.transparent(15),add=T)

par(fig = c(0, 10, 5.75, 10) / 10)
par(new=T)
plot(forc_ras_proj,
     axes = FALSE, box = FALSE, col = colfunc.forc(15), zlim = c(0, 150), breaks = seq(0, 150, 10),
     legend.only = TRUE, smallplot = c(0.88, 0.9, 0.4, 0.85),
     axis.args = list(at = c(0, 30, 60, 90, 120, 140, 150), labels = c("0", "30", "60", "90", "120", "140", "140+"), font = 2, cex.axis = 0.6),
     legend.args = list(text = "Forest age (yr)", side = 3, font = 2, line = 0.5, cex = 0.8)
)

par(fig = c(5, 9.5, 5.5, 7) / 10)
par(new = T)
hist(forc_df$stand.age.fewer, nclass = 15, fre = FALSE, main = "", ylab = "", xlab = "", ylim = c(0, 0.015), col = colfunc.forc(15), border = "white", axes = FALSE)
axis(side = 1, at = c(0, 50, 100, 140, 150), label = rep("", 5), tck = -0.02, line = 0)
axis(side = 4, at = seq(0, 0.015, 0.005), label = rep("", 4), tck = -0.01, line = 0)
axis(side = 1, at = c(0, 50, 100, 140, 150), labels = c("0", "50", "100", "140", "140+"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 1, at = c(150), labels = c("140+"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 4, at = seq(0, 0.015, 0.005), labels = c("0%", "5%", "10%", "15%"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
mtext("Forest age (yr)", side = 1, line = 0.2, font = 2, cex = 0.4)
mtext("Percentage of sites", side = 4, line = 0.2, font = 2, cex = 0.4)


# GFAD
par(fig = c(0, 1, 4, 5) / 10)
par(new=T)
plot(-1:1, -1:1,  xaxt = 'n', yaxt = 'n', bty = 'n', pch = '', ylab = '', xlab = '')
text(0,0, "(b)", font=2)

par(fig = c(0, 10, 5.75, 10) / 10)
par(new=T)
plot(age_veg_proj, axes = FALSE, box = FALSE, alpha=0, legend = F)

par(fig = c(0, 10, 0.75, 5) / 10)
par(new=T)
plot(ocean_poly_proj, col = "#1D334A", border = NA,add=T) # 1D334A
plot(coast_lines_proj, col = "white", add = TRUE, lwd = 0.0001)
plot(bb_poly_proj, bor = "black", add = TRUE)

par(fig = c(0, 10, 0.75, 5) / 10)
par(new=T)
plot(age_veg_proj, axes = FALSE, box = FALSE, col = colfunc.gfad(15), legend = F)

par(fig = c(0, 10, 0.75, 5) / 10)
par(new=T)
plot(age_veg_proj,
     axes = FALSE, box = FALSE, col = colfunc.gfad(15), zlim = c(0, 150), breaks = seq(0, 150, 10),
     legend.only = TRUE, smallplot = c(0.88, 0.9, 0.4, 0.85),
     axis.args = list(at = c(0, 30, 60, 90, 120, 140, 150), labels = c("0", "30", "60", "90", "120", "140", "140+"), font = 2, cex.axis = 0.6),
     legend.args = list(text = "Forest age (yr)", side = 3, font = 2, line = 0.5, cex = 0.8)
)

par(fig = c(5, 9.5, 0.5, 2) / 10)
par(new = T)
hist(na.omit(values(age_veg)), nclass = 15, fre = FALSE, main = "", ylab = "", xlab = "", ylim = c(0, 0.015), col = colfunc.gfad(15), border = "white", axes = FALSE)
axis(side = 1, at = c(0, 50, 100, 140, 150), label = rep("", 5), tck = -0.02, line = 0)
axis(side = 4, at = seq(0, 0.015, 0.005), label = rep("", 4), tck = -0.01, line = 0)
axis(side = 1, at = c(0, 50, 100, 140, 150), labels = c("0", "50", "100", "140", "140+"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 1, at = c(150), labels = c("140+"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
axis(side = 4, at = seq(0, 0.015, 0.005), labels = c("0%", "5%", "10%", "15%"), tck = -0.01, font = 2, cex.axis = 0.4, line = -1.3, lwd = 0)
mtext("Forest age (yr)", side = 1, line = 0.2, font = 2, cex = 0.4)
mtext("Percentage of pixels", side = 4, line = 0.2, font = 2, cex = 0.4)

dev.off()