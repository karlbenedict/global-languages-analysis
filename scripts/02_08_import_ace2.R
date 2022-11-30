# 02_08_import_ace2.R

# execute the shared setup file
source("scripts/00_include.R")
library(R.utils)

fileURL <- "https://linguistics.sfo3.digitaloceanspaces.com/compressed_source_data/ACE2_GDEM.zip"
fileBaseName <- "ACE2_elevation"
# is this a test run?
ace2_test_run <- FALSE
sampleSize <- 15 # only applicable when doing a test run

# retrieve and unzip the source file into the temp directory
unzippedDirectory <- getSourceZip(fileURL)
ace2_file_path <- unzippedDirectory

headersDir <- paste(unzippedDirectory,"/dedc-ace-v2-hdr-files/hdr_files", sep="")
dataDirBase <- paste(unzippedDirectory,"/30-sec/dedc-ace-v2_", sep="")
workingDir <- paste(unzippedDirectory,"/temp", sep="")
commandString <- paste("mkdir ", workingDir, sep="")
#print(commandString)
system(commandString)

tempLocation <- "ACE2_temp"
compositeACE2_raster <- "ACE2_elevation"
ACE2_region <- "ACE2_global_10km"

generatePaths <- function(locString){
  filePath <- paste(dataDirBase,locString,"_30sec/both/",locString,"_BOTH_30S.ACE2.gz",sep="")
  headerPath <- paste(headersDir,"/",locString,"_30S.ACE2.hdr",sep="")
  return(c(filePath,headerPath))
}

importACE2 <- function(locString,fileCount){
  paths <- generatePaths(locString)
  filepath <- paths[1]
  headerpath <- paths[2]
  print(filepath)
  print(headerpath)
  print("")
  
  # extract/copy raw file and associated hdr file into temp directory for processing
  rawDest <- paste(workingDir,"/temp.raw",sep="")
  hdrDest <- paste(workingDir,"/temp.hdr", sep="")
  gunzip(filepath, destname=rawDest, overwrite=TRUE, remove=FALSE)
  commandString <- paste("cp -f ",headerpath," ",hdrDest, sep="")
  #print(commandString)
  system(commandString)
  
  # If this is the first dataset create the temp ACE2 location for import
  if (fileCount == 1) {
    commandString <- paste("rm -rf ",gisDBase,"/",tempLocation,sep="")
    #print(commandString)
    system(commandString)
    
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
    
    # create new temp ACE2 location from first ACE2 file import command
    execGRASS("r.in.gdal",
              flags=c("overwrite","verbose"),
              parameters=list(input=rawDest,
                              output=compositeACE2_raster,
                              location=tempLocation),
              echoCmd=TRUE
    )
    
    location <- tempLocation
    mapset <- "PERMANENT"
    initGRASS(
      gisBase = gisBase,
      home = projectRoot,
      gisDbase = gisDBase,
      location = location,
      mapset = mapset,
      override = TRUE
    )
    execGRASS("v.proj",
              flags=c("overwrite"),
              parameters=list(input="bounds4326", 
                              location="4326"))
    execGRASS("g.region",
              flags=c("a","s","overwrite"),
              parameters=list(vector="bounds4326",
                              res="1000",
                              save = ACE2_region))
    execGRASS("g.region",
              flags=c("p"))
    execGRASS("v.proj",
              flags=c("overwrite"),
              parameters=list(input="languages", 
                              location="4326"))
    try(execGRASS("r.mask",
              flags=c("r"),
              echoCmd=TRUE
    ))
    
    
  } else {
    # otherwise use the new temp location as the destination for the new
    # temp raster that will be merged with the combined raster
    location <- tempLocation
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
              parameters=list(region = ACE2_region), 
              echoCmd=TRUE)
    
    tempRaster <- "temp"
    execGRASS("r.in.gdal",
              flags=c("overwrite","verbose"),
              parameters=list(input=rawDest,
                              output=tempRaster),
              echoCmd=TRUE
    )
    execGRASS("r.patch",
              flags=c("overwrite","verbose"),
              parameters=list(input=paste(compositeACE2_raster,tempRaster,sep=","),
                              output=compositeACE2_raster),
              echoCmd=TRUE
    )
  }
}

sSeq <- seq(from=15,to=90,by=15)
nSeq <- seq(from=0,to=75,by=15)
eSeq <- seq(from=0,to=165,by=15)
wSeq <- seq(from=15,to=180,by=15)

k <- 0
for (i in sSeq){
  for (j in wSeq){
    if ((ace2_test_run && k<sampleSize) || (! ace2_test_run)){
      k <- k+1
      locString <- paste(sprintf("%02i",i),"S",sprintf("%03i",j),"W",sep="")
      importACE2(locString,k)
    }
  }
  for (j in eSeq){
    if ((ace2_test_run && k<sampleSize) || (! ace2_test_run)){
      k <- k+1
      locString <- paste(sprintf("%02i",i),"S",sprintf("%03i",j),"E",sep="")
      importACE2(locString,k)
    }
  }
}
for (i in nSeq){
  for (j in wSeq){
    if ((ace2_test_run && k<sampleSize) || (! ace2_test_run)){
      k <- k+1
      locString <- paste(sprintf("%02i",i),"N",sprintf("%03i",j),"W",sep="")
      importACE2(locString,k)
    }
  }
  for (j in eSeq){
    if ((ace2_test_run && k<sampleSize) || (! ace2_test_run)){
      k <- k+1
      locString <- paste(sprintf("%02i",i),"N",sprintf("%03i",j),"E",sep="")
      importACE2(locString,k)
    }
  }
}

location <- tempLocation
mapset <- "PERMANENT"
initGRASS(
  gisBase = gisBase,
  home = projectRoot,
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

execGRASS("r.colors",
          flags=c("verbose"),
          parameters=list(map=compositeACE2_raster,
                          color="etopo2"),
          echoCmd=TRUE
)

execGRASS("r.info",
          parameters=list(map=compositeACE2_raster),
          echoCmd=TRUE
)


execGRASS("g.region", 
          flags=c("verbose"), 
          parameters=list(region = ACE2_region,
                          res="10000"), 
          echoCmd=TRUE)

ps_preview(title="Global ACE2 Elevation Model (m)",
           raster=compositeACE2_raster,
           rasterLegend = TRUE)

# reproject the generated raster back into the 4326 location using a custom
# gdalwarp function defined in 00_include.R
warpRaster(sourceLocation="ACE2_temp",
           sourceMapset="PERMANENT",
           sourceRaster="ACE2_elevation",
           destCRS="EPSG:4326",
           destLocation="4326",
           destMapset="PERMANENT",
           destRegion="global_30-arc-second",
           destRaster="ACE2_elevation")

location <- 4326
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
ps_preview(title="Global ACE2 Elevation Model (m)",
           raster=compositeACE2_raster,
           rasterLegend = TRUE)


unlink_.gislock

