# get (download and unzip) raw data
dir.create('data/', FALSE, TRUE)

# GFAD
dir.create('data/GFAD', FALSE, TRUE)
download.file('http://dare.iiasa.ac.at/29/1/GFAD_V1-0.zip', 'data/GFAD/GFAD_V1-0.zip')
unzip('data/GFAD/GFAD_V1-0.zip', exdir = 'data/GFAD')
download.file('http://hs.pangaea.de/model/Poulter-etal_2018/GFAD_V1-1.zip', 'data/GFAD/GFAD_V1-1.zip')
unzip('data/GFAD/GFAD_V1-1.zip', exdir = 'data/GFAD')

# GIS (boundary files)
dir.create('data/GIS', F, T)

# ForC data
