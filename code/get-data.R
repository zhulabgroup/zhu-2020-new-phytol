# get (download and unzip) raw data
# create data folder which will be git-ignored
dir.create("data/", F, T)

# GFAD
dir.create("data/GFAD", F, TRUE)
download.file(
  "http://dare.iiasa.ac.at/29/1/GFAD_V1-0.zip",
  "data/GFAD/GFAD_V1-0.zip"
)
unzip("data/GFAD/GFAD_V1-0.zip",
  exdir = "data/GFAD"
)
download.file(
  "http://hs.pangaea.de/model/Poulter-etal_2018/GFAD_V1-1.zip",
  "data/GFAD/GFAD_V1-1.zip"
)
unzip("data/GFAD/GFAD_V1-1.zip",
  exdir = "data/GFAD"
)

# GIS (boundary files)
dir.create("data/GIS", F, T)
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_coastline.zip",
  "data/GIS/ne_10m_coastline.zip"
)
unzip("data/GIS/ne_10m_coastline.zip",
  exdir = "data/GIS/ne_10m_coastline"
)
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_graticules_30.zip",
  "data/GIS/ne_10m_graticules_30.zip"
)
unzip("data/GIS/ne_10m_graticules_30.zip",
  exdir = "data/GIS/ne_10m_graticules_30"
)
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_wgs84_bounding_box.zip",
  "data/GIS/ne_10m_wgs84_bounding_box.zip"
)
unzip("data/GIS/ne_10m_wgs84_bounding_box.zip",
  exdir = "data/GIS/ne_10m_wgs84_bounding_box"
)
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_ocean.zip",
  "data/GIS/ne_10m_ocean.zip"
)
unzip("data/GIS/ne_10m_ocean.zip",
  exdir = "data/GIS/ne_10m_ocean"
)

# ForC data
