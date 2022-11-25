# 02_04_import_landcover.R

# execute the shared setup file
source("scripts/00_include.R")

fileURL <- "https://linguistics.sfo3.digitaloceanspaces.com/compressed_source_data/ma_climate_land_cover.zip"

# retrieve and unzip the source file into the temp directory
unzippedDirectory <- getSourceZip(fileURL)

# import the MA global landcover data into the 4326 location based on the 
# global_30-arc-second region
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
          parameters=list(region = "global_30-arc-second"), 
          echoCmd=TRUE)

sourceGrid <- paste(unzippedDirectory,"Global Land Cover/landcover_glc2000/glc2000_v1_1", sep="/")
outRast <- "glc2000_v1_1"

execGRASS("r.in.gdal",
          flags=c("overwrite","verbose"),
          parameters=list(input = sourceGrid,
                          output = outRast),
          echoCmd=TRUE
)
execGRASS("r.info",
          parameters=list(map = outRast),
          echoCmd=TRUE
)

# generate a reclassified landcover raster with categories used in the analysis
reclassRast <- paste(outRast, "_reclass", sep="")
execGRASS("r.recode",
          flags=c("overwrite","verbose"),
          parameters=list(input = outRast,
                          output = reclassRast,
                          rules = paste(projectRoot, "scripts/reclass_MA_glc.txt", sep = "/")),
          echoCmd=TRUE
)
execGRASS("r.info",
          parameters=list(map = reclassRast),
          echoCmd=TRUE
)

execGRASS("g.region", 
          flags=c("verbose"), 
          parameters=list(region = "global_5-arc-minute"), 
          echoCmd=TRUE)

ps_preview(title="Reclassified global land cover data",
           raster=reclassRast,
           vPoints=c("languages"),
           vPoints_colors = c("red"))

unlink_.gislock

# Original Vegetation Classes
# VALUE	CLASSNAMES
# 1		Tree Cover, broadleaved, evergreen
# 2		Tree Cover, broadleaved, deciduous, closed
# 3		Tree Cover, broadleaved, deciduous, open
# 4		Tree Cover, needle-leaved, evergreen
# 5		Tree Cover, needle-leaved, deciduous
# 6		Tree Cover, mixed leaf type
# 7		Tree Cover, regularly flooded, fresh water
# 8		Tree Cover, regularly flooded, saline water
# 9		Mosaic: Tree Cover / Other natural vegetation
# 10	Tree Cover, burnt
# 11	Shrub Cover, closed-open, evergreen
# 12	Shrub Cover, closed-open, deciduous
# 13	Herbaceous Cover, closed-open
# 14	Sparse herbaceous or sparse shrub cover
# 15	Regularly flooded shrub and/or herbaceous cover
# 16	Cultivated and managed areas
# 17	Mosaic: Cropland / Tree Cover / Other natural vege
# 18	Mosaic: Cropland / Shrub and/or grass cover
# 19	Bare Areas
# 20	Water Bodies
# 21	Snow and Ice
# 22	Artificial surfaces and associated areas
# 23	No data
# reclassify the original vegetation classes into:
#   1 = tall
#   2 = intermediate
#   3 = low
#   10 = water
#   11 = snow/ice
#   20 = cultivated areas
#   21 = artificial surfaces
#   22 = no data
