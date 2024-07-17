# 02_01_import_BMNG.R

# execute the shared setup file
source("scripts/00_include.R")

library(tools)
library(raster)


# download and unzip source data for import
fileURL <- "https://linguistics.sfo3.digitaloceanspaces.com/compressed_source_data/bmng.zip"
downloadDirectory <- paste(getwd(), "/temp", sep="")
# download
commandString <- paste("wget -nc --directory-prefix=",downloadDirectory," ",fileURL, sep="" )
print(commandString)
system(commandString)
# uncompress
zipFile <- paste(downloadDirectory,basename(fileURL),sep="/")
unzippedDirectory <- file_path_sans_ext(zipFile)
commandString <- paste("unzip -u",zipFile, "-d", downloadDirectory, sep=" " )
print(commandString)
system(commandString)


# Import the BMNG data into the 4326:global_30-arc-second location:region and 
# then reproject the imported imagery into mollweide:moll_global_10km
files <- list.files(path=unzippedDirectory, pattern="*.tif", full.names=TRUE)
patchList <- c()
for (file in files) {
  infile <- file
  outRaster <- file_path_sans_ext(basename(file))
  print(paste(infile, "->", outRaster, sep=""))

  # import the imagery into the 4326 location
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
  
  execGRASS("g.region", 
            flags=c("p"), 
            echoCmd=TRUE)
  
  execGRASS("r.in.gdal", 
            flags=c("overwrite","verbose", "o"), 
            parameters=list(input = infile,
                            output = outRaster),
            echoCmd=TRUE)
  
  execGRASS("r.composite", 
            flags=c("overwrite","verbose"), 
            parameters=list(red=paste(outRaster,".red",sep=""),
                            green=paste(outRaster,".green",sep=""),
                            blue=paste(outRaster,".blue",sep=""),
                            output = paste(outRaster,".rgb",sep="")),
            echoCmd=TRUE)
            
  execGRASS("r.info", 
            flags=c("verbose"), 
            parameters=list(map=paste(outRaster,".red",sep="")),
            echoCmd=TRUE)
  execGRASS("r.info", 
            flags=c("verbose"), 
            parameters=list(map=paste(outRaster,".rgb",sep="")),
            echoCmd=TRUE)
  patchList <- c(patchList,paste(outRaster,".rgb",sep=""))
  execGRASS("r.out.png", 
            flags=c("verbose", "overwrite"), 
            parameters=list(input=paste(outRaster,".rgb",sep=""),
                            output=paste("output/images/", outRaster, "_4326.png", sep="")),
            echoCmd=TRUE)
  
 }

layers <- paste(print(patchList),collapse=",")
execGRASS("g.region",
          flags=c("p"),
          parameters=list(raster=layers),
          echoCmd=TRUE
          )
execGRASS("r.patch",
          flags=c("overwrite","verbose"),
          parameters=list(input=layers,
                          output="bmng.rgb"),
          echoCmd=TRUE
)
execGRASS("r.out.png", 
          flags=c("verbose", "overwrite"), 
          parameters=list(input="bmng.rgb",
                          output="output/images/bmng_4326.png"),
          echoCmd=TRUE)


unlink_.gislock