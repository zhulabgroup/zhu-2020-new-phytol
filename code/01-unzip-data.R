# unzip raw data
# create data folder which will be git-ignored
dir.create("data/", F, T)

# GFAD
dir.create("data/GFAD", F, TRUE)
unzip("data-raw/GFAD_V1-0.zip",
  exdir = "data/GFAD"
)
unzip("data-raw/GFAD_V1-1.zip",
  exdir = "data/GFAD"
)

# GIS (boundary files)
dir.create("data/GIS", F, T)
unzip("data-raw/ne_10m_coastline.zip",
  exdir = "data/GIS/ne_10m_coastline"
)
unzip("data-raw/ne_10m_graticules_30.zip",
  exdir = "data/GIS/ne_10m_graticules_30"
)
unzip("data-raw/ne_10m_wgs84_bounding_box.zip",
  exdir = "data/GIS/ne_10m_wgs84_bounding_box"
)
unzip("data-raw/ne_10m_ocean.zip",
  exdir = "data/GIS/ne_10m_ocean"
)

# ForC data
dir.create("data/ForC", F, T)
unzip("data-raw/ForC_simplified.zip",
  exdir = "data/ForC/", junkpaths = T
) # junkpaths = j in zip
