library(ncdf4)
library(raster)

age <- nc_open('data/GFAD/GFAD_V1-0.nc')
age.arr <- ncvar_get(age, varid = 'age')

ncvar_get(age, 'lon')

age.ras <- raster('data/GFAD/GFAD_V1-0.nc', varname = 'age', band = 2)
age.ras

pdf('figs/test-map.pdf')
plot(age.ras)
dev.off()
