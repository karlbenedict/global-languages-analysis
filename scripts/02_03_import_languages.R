# 02_03_import_languages.R

# execute the shared setup file
source("scripts/00_include.R")

fileURL <- "https://github.com/karlbenedict/global-languages-data/archive/refs/heads/master.zip" # master branch


# retrieve and unzip the source file into the temp directory
unzippedDirectory <- getSourceZip(fileURL)

# import the ipums shapefile into the 4326 location based on the 
# global_5-arc-minute region
location <- "4326"
mapset <- "PERMANENT"
initGRASS(
  gisBase = gisBase,
  home = projectRoot,
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)
execGRASS("g.region", 
          flags=c("verbose"), 
          parameters=list(region = "global_5-arc-minute"), 
          echoCmd=TRUE)

VRTfile <- paste(projectRoot, "temp/global-languages-data-master/attributes/current_language_data_VRT.xml", sep="/")
outVect <- "languages"

execGRASS("v.in.ogr",
          flags=c("o","overwrite","verbose"),
          parameters=list(input=VRTfile,
                          output=outVect),
          echoCmd=TRUE
)

execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=outVect),
          echoCmd=TRUE
)





# generate 100km buffer regions surrounding each language point 
# and reproject back into 4326 region
bufferedVect <- paste(outVect,"_buffered",sep="")

location <- "world_sinusoidal"
mapset <- "PERMANENT"

clearVars(varNames)
initGRASS(
  gisBase = gisBase,
  home = projectRoot,
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

execGRASS("v.proj",
          flags=c("overwrite", "verbose"),
          parameters=list(location = "4326",
                          mapset = "PERMANENT",
                          input = outVect,
                          output = outVect
          ),
          echoCmd=TRUE
)
execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=outVect),
          echoCmd=TRUE
)
execGRASS("v.buffer",
          flags=c("overwrite", "verbose"),
          parameters=list(input = outVect,
                          output = bufferedVect,
                          type = "point",
                          distance = 100000,
                          tolerance = .1
          ),
          echoCmd=TRUE
)
execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=bufferedVect),
          echoCmd=TRUE
)


# reproject back into 4326 and clip to land boundary regions
location <- "4326"
mapset <- "PERMANENT"
initGRASS(
  gisBase = gisBase,
  home = projectRoot,
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)
execGRASS("g.region",
          flags=c("verbose","p"),
          parameters=list(res="00:02:30"),
          echoCmd=TRUE
)


execGRASS("v.proj",
          flags=c("overwrite", "verbose"),
          parameters=list(location = "world_sinusoidal",
                          mapset = "PERMANENT",
                          input = bufferedVect,
                          output = bufferedVect
          ),
          echoCmd=TRUE
)
execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=bufferedVect),
          echoCmd=TRUE
)
clippedVect <- paste(bufferedVect,"_clipped", sep="")
execGRASS("v.clip",
          flags=c("overwrite"),
          parameters=list(input=bufferedVect,
                          output=clippedVect,
                          clip="world_countries_2017_dissolved"),
          echoCmd=TRUE
)
execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=clippedVect),
          echoCmd=TRUE
)

ps_preview(title="Buffered language location",
           raster="bmng.rgb",
           vAreas=c(clippedVect),
           vAreas_colors=c("red"),
           vAreas_fcolors = c("red"))

# generate clipped voronoi language polygons for environmental data extraction
location <- "4326"
mapset <- "PERMANENT"
initGRASS(
  gisBase = gisBase,
  home = projectRoot,
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)
execGRASS("g.region",
          flags=c("verbose","p"),
          parameters=list(res="00:02:30"),
          echoCmd=TRUE
)

voronoiVect <- paste(outVect,"_voronoi", sep="")
execGRASS("v.voronoi",
          flags=c("overwrite"),
          parameters=list(input = outVect,
                          output = voronoiVect),
          echoCmd=TRUE
)
execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=voronoiVect),
          echoCmd=TRUE
)
ps_preview(title="Voronoi polygons for languages",
           vPoints=c(outVect),
           vPoints_colors = c("red"),
           raster="bmng.rgb",
           vAreas=c(voronoiVect),
           vAreas_colors=c("red"),
           vAreas_fcolors = c("none"))

voronoiVectClipped <- paste(voronoiVect,"_clipped",sep="")
execGRASS("v.clip",
          flags=c("overwrite"),
          parameters=list(input = voronoiVect,
                          output = voronoiVectClipped,
                          clip=clippedVect),
          echoCmd=TRUE
)
execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=voronoiVectClipped),
          echoCmd=TRUE
)
ps_preview(title="Clipped voronoi polygons for languages",
           vPoints=c(outVect),
           vPoints_colors = c("red"),
           raster="bmng.rgb",
           vAreas=c(voronoiVectClipped),
           vAreas_colors=c("red"),
           vAreas_fcolors = c("none"))

unlink_.gislock