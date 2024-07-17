# 02_02_import_ipums.R

# execute the shared setup file
source("scripts/00_include.R")

fileURL <- "https://linguistics.sfo3.digitaloceanspaces.com/compressed_source_data/ipums.zip"

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

file <- list.files(path=unzippedDirectory, pattern="*.shp$", full.names=TRUE)
outVect <- file_path_sans_ext(basename(file))

execGRASS("v.in.ogr",
          flags=c("o","overwrite","verbose"),
          parameters=list(input=file,
                          output=outVect),
          echoCmd=TRUE
)

execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=outVect),
          echoCmd=TRUE
)

# generate a version of the countries boundaries that has interior boundaries
# dissolved. This is intended to provide a boundary that can be used for 
# clipping and masking other layers. 
dissolvedVect <- paste(outVect,"_dissolved",sep="")

execGRASS("v.db.addcolumn",
          flags=c("verbose"),
          parameters=list(map=outVect,
                          columns="dissolve int"),
          echoCmd=TRUE
)

execGRASS("v.db.update",
          flags=c("verbose"),
          parameters=list(map=outVect,
                          column="dissolve",
                          value="1"),
          echoCmd=TRUE
)

execGRASS("v.dissolve",
          flags=c("overwrite","verbose"),
          parameters=list(input=outVect,
                          column="dissolve",
                          output=dissolvedVect),
          echoCmd=TRUE
)

execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=dissolvedVect),
          echoCmd=TRUE
)

# generate a generalized version of the dissolved boundaries to speed processing
# and rendering.  
generalizedVect <- paste(dissolvedVect,"_generalized",sep="")
execGRASS("v.generalize",
          flags=c("overwrite","verbose"),
          parameters=list(input=dissolvedVect,
                          output=generalizedVect,
                          method="douglas",
                          threshold=0.083),
          echoCmd=TRUE
)


ps_preview(title="World boundaries",
           raster="bmng.rgb",
           vAreas=c("world_countries_2017_dissolved","world_countries_2017_dissolved_generalized","world_countries_2017"),
           vAreas_colors=c("red","yellow","gray"),
           vAreas_fcolors = c("none","none","none"))

unlink_.gislock