# download raw data
dir.create("data-raw/", F, T)

# GFAD
download.file(
  "http://dare.iiasa.ac.at/29/1/GFAD_V1-0.zip",
  "data-raw/GFAD_V1-0.zip"
)
download.file(
  "http://hs.pangaea.de/model/Poulter-etal_2018/GFAD_V1-1.zip",
  "data-raw/GFAD_V1-1.zip"
)

# GIS (boundary files)
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_coastline.zip",
  "data-raw/ne_10m_coastline.zip"
)
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_graticules_30.zip",
  "data-raw/ne_10m_graticules_30.zip"
)
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_wgs84_bounding_box.zip",
  "data-raw/ne_10m_wgs84_bounding_box.zip"
)
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_ocean.zip",
  "data-raw/ne_10m_ocean.zip"
)
