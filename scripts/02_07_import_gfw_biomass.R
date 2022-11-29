# 02_07_import_gfw_biomass.R

# execute the shared setup file
source("scripts/00_include.R")
library(utils)

fileURL <- "https://linguistics.sfo3.digitaloceanspaces.com/compressed_source_data/gfw_global_biomass.zip"
fileBaseName <- "Aboveground_Live_Woody_Biomass_Density"
# is this a test run?
gfw_test_run <- FALSE
sampleSize <- 5 # only applicable when doing a test run

# retrieve and unzip the source file into the temp directory
unzippedDirectory <- getSourceZip(fileURL)
gfw_file_path <- unzippedDirectory
# read csv file with file links into a df
gfw_files <- read_csv(paste(unzippedDirectory,"/",fileBaseName,".csv", sep=""))

downloadDirectory <- paste(gfw_file_path, "files", sep="/")
system(paste("mkdir",downloadDirectory,sep=" "))
system(commandString)

# loop through df to import the individual GeoTiff files into a single GRASS raster
# while calculating the average biomass in Mg/Ha for each 30-arc-second raster
# pixel from the source 0.9 arc-second pixels

if (gfw_test_run){
  records <- sample_n(gfw_files,size=sampleSize,replace=FALSE)
  files <- records[["Mg_ha_1_download"]]
  ids <- records[["tile_id"]]
} else {
  files <- gfw_files[["Mg_ha_1_download"]]
  ids <- gfw_files[["tile_id"]]
}

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

startTime <- now()
for (i in 1:length(files)) {
  outputFile <- paste(downloadDirectory,"/",ids[i],".tif", sep="")
  outputRaster <- fileBaseName
  
  print("")
  print("")
  print("######################################################################")
  print(paste("[",i,"/",length(files),"] Starting Processing: ", outputFile))
  print("######################################################################")
  commandString <- paste("wget -nc --progress=dot:giga --directory-prefix=",downloadDirectory,
                         " --output-document=",outputFile,
                         " \"",files[i],"\"", sep="" )
  #print(commandString)
  
  # resample the source pixels outside of GRASS as the 'gdal_translate" 
  # function is much faster than the GRASS 'r.resamp.rast' function that
  # could be used to accomplish the same goal
  tempTiff <- paste(downloadDirectory, "/temp.tif", sep="")
  system(paste("gdal_translate -if GTiff -of GTiff -ot Float32 -r average -tr 0.00833333333333 0.00833333333333 ", 
               outputFile," ", 
               tempTiff, sep=""))
  if (i == 1) {
    execGRASS("r.in.gdal",
              flags=c("o","verbose","overwrite"),
              parameters=list(input=tempTiff,
                              output=fileBaseName),
              echoCmd=TRUE
    )
    #execGRASS("r.info",
    #          parameters=list(map=fileBaseName),
    #          echoCmd=TRUE
    #)
  } else {
    execGRASS("r.in.gdal",
              flags=c("o","verbose","overwrite"),
              parameters=list(input=tempTiff,
                              output="tempRast"),
              echoCmd=TRUE
    )
    execGRASS("r.patch",
              flags=c("overwrite","verbose"),
              parameters=list(input=paste(fileBaseName,"tempRast",sep=","),
                              output=fileBaseName),
              echoCmd=TRUE
    )
  }
  elapsedTime <- round(difftime(now(),startTime,units="mins"), digits=1)
  estTotalTime <- round(elapsedTime / (i/length(files)), digits=0)
  print("")
  print("")
  print("######################################################################")
  print(paste("[",i,"/",length(files),"] (",elapsedTime,"/~",estTotalTime,"minutes) Finished Processing: ", outputFile))
  print("######################################################################")
  print("")
  print("")
  
}

execGRASS("r.colors",
          flags=c("verbose"),
          parameters=list(map=fileBaseName,
                          color="greens"),
          echoCmd=TRUE
)

execGRASS("r.info",
          parameters=list(map=fileBaseName),
          echoCmd=TRUE
)

execGRASS("g.region", 
          flags=c("verbose"), 
          parameters=list(region = "global_5-arc-minute"), 
          echoCmd=TRUE)

ps_preview(title="Global woody biomass (average Mg/Ha)",
           raster=fileBaseName,
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           rasterLegend = TRUE)



unlink_.gislock

