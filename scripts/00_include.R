library(rgrass)
library(sp)
library(lubridate)
library(stringi)
library(gdalUtilities)
library(rgdal)
library(raster)
library(tidyverse)
library(readr)
library(forcats)
library(readxl)
library(tools)

# legacy - delete if not needed later
#use_sp() # https://gis.stackexchange.com/questions/341451/rgrass7-no-stars-import-yet

# setup environment variables
rm(list = ls())
Sys.setenv(LC_ALL = "en_US.UTF-8",
           LANG = "en_US.UTF-8",
           CPL_ZIP_ENCODING = "UTF-8")



# define the local path to the project root folder ####################################################################
setwd(paste(Sys.getenv("HOME"), "global-languages-analysis", sep="/"))
projectRoot <- paste(Sys.getenv("HOME"), "global-languages-analysis", sep="/")
gisBase <- "/usr/lib/grass82"
gisDBase <- paste(Sys.getenv("HOME"), "global-languages-analysis", "grassdata", sep="/")

varNames <- c("GISBASE",
              "GISDBASE",
              "GISRC",
              "GIS_LOCK",
              "GRASS_PAGER",
              "LD_LIBRARY_PATH",
              "LOCATION_NAME",
              "MAPSET",
              "PROJ_LIB",
              "PYTHONPATH"
)

tempDatedFolder <- function() {
  fixedTime <- now()
  tempdir <- paste(projectRoot,"/", "temp/", sep = "")
  temppath <- paste(tempdir, "working_", paste(date(fixedTime), "T", hour(fixedTime), ":", minute(fixedTime), ":", second(fixedTime), "_", stri_rand_strings(1, 5), sep = ""), sep = "")
  dir.create(temppath)
  temppath
}

# generate postscript preview image from specified raster, point, line, and area vectors
ps_preview <- function(raster="", 
                       vPoints=c(), 
                       vPoints_colors=c(),
                       vLines=c(), 
                       vLines_colors=c(),
                       vAreas=c(), 
                       vAreas_colors=c(), 
                       vAreas_fcolors=c(), 
                       geogrid=TRUE, 
                       scalebar=FALSE, 
                       mapinfo=TRUE,
                       rasterLegend=FALSE,
                       title="Default map preview"){
  # this function must be executed within a defined GRASS environment context
  workingDir <- tempDatedFolder()
  commandFile <- paste(workingDir, "commands.txt", sep="/")
  headerFile <- paste(workingDir, "header.txt", sep="/")
  outputFile <- paste(workingDir, "output.ps", sep="/")
  print(paste("The output will be generated in the following temp folder:", workingDir, sep=" "))
  print(paste("The command file will be:", commandFile, sep=" "))
  print(paste("The header file will be:", headerFile, sep=" "))

  cat("%_", fill=TRUE, file=headerFile, append=TRUE)
  cat(title, fill=TRUE, file=headerFile, append=TRUE)
  cat("Basemap: %c", fill=TRUE, file=headerFile, append=TRUE)
  
  vectorLayers <- c()
    
  if (raster == "") {
    print("No raster will be added")
  } else {
    print(paste("The basemap raster is:", raster, sep=" "))
    cat(c(paste("raster", raster, sep=" ")), fill=TRUE, file=commandFile, append=TRUE)
  }
  if (length(vPoints)>0) {
    print("The points(s) and associated colors are:")
    for (i in 1:length(vPoints)){
      print(paste("     ",vPoints[i], vPoints_colors[i]))
      vectorLayers <- c(vectorLayers,vPoints[i])
      cat(paste("vpoints",vPoints[i],sep=" "), fill=TRUE, file=commandFile, append=TRUE)
      cat(paste("    color",vPoints_colors[i], sep=" "), fill=TRUE, file=commandFile, append=TRUE)
      cat("    size .25" , fill=TRUE, file=commandFile, append=TRUE)
      cat("end", fill=TRUE, file=commandFile, append=TRUE)
    }
  } else {
    print("No vector points will be added")
  }
  if (length(vAreas)>0) {
    print("The vector areas(s) and associated line and fill colors are:")
    for (i in 1:length(vAreas)){
      print(paste("     ",vAreas[i], vAreas_colors[i], vAreas_fcolors[i]))
      vectorLayers <- c(vectorLayers,vAreas[i])
      cat(paste("vareas",vAreas[i],sep=" "), fill=TRUE, file=commandFile, append=TRUE) 
      cat(paste("    color",vAreas_colors[i],sep=" "), fill=TRUE, file=commandFile, append=TRUE)
      cat(paste("    fcolor",vAreas_fcolors[i],sep=" "), fill=TRUE, file=commandFile, append=TRUE)
      cat(paste("    width .1",vAreas_fcolors[i],sep=" "), fill=TRUE, file=commandFile, append=TRUE)
      cat("end", fill=TRUE, file=commandFile, append=TRUE)
    } 
  } else {
    print("No vector areas will be added")
  }
  if (length(vLines)>0) {
    print("The vector(s) and associated colors are:")
    for (i in 1:length(vLines)){
      print(paste("     ",vLines[i], vLines_colors[i]))
      vectorLayers <- c(vectorLayers,vAreas[i])
      cat(paste("vlines",vLines[i],sep=" "), fill=TRUE, file=commandFile, append=TRUE)
      cat(paste("    color",vLines_colors[i], sep=" "), fill=TRUE, file=commandFile, append=TRUE)
      cat("    width .1" , fill=TRUE, file=commandFile, append=TRUE)
      cat("end", fill=TRUE, file=commandFile, append=TRUE)
    }
  } else {
    print("No vector lines will be added")
  }
  if (geogrid) {
    cat("geogrid 10 d", fill=TRUE, file=commandFile, append=TRUE)
    cat("    color gray", fill=TRUE, file=commandFile, append=TRUE)
    cat("    width .1" , fill=TRUE, file=commandFile, append=TRUE)
    cat("end", fill=TRUE, file=commandFile, append=TRUE)
  }
  if (scalebar) {
    cat("scalebar f", fill=TRUE, file=commandFile, append=TRUE)
    cat("    length 90", fill=TRUE, file=commandFile, append=TRUE)
    cat("    units auto" , fill=TRUE, file=commandFile, append=TRUE)
    cat("    height .25" , fill=TRUE, file=commandFile, append=TRUE)
    cat("    segment 5" , fill=TRUE, file=commandFile, append=TRUE)
    cat("end", fill=TRUE, file=commandFile, append=TRUE)
  }
  if (mapinfo) {
    cat("mapinfo", fill=TRUE, file=commandFile, append=TRUE)
    cat("    color black", fill=TRUE, file=commandFile, append=TRUE)
    cat("    border black" , fill=TRUE, file=commandFile, append=TRUE)
    cat("    fontsize 4" , fill=TRUE, file=commandFile, append=TRUE)
    cat("    where 7.75 0.375" , fill=TRUE, file=commandFile, append=TRUE)
    cat("end", fill=TRUE, file=commandFile, append=TRUE)
  }
  if (rasterLegend) {
    cat("colortable y", fill=TRUE, file=commandFile, append=TRUE)
    cat("    where .25 5.5", fill=TRUE, file=commandFile, append=TRUE)
    cat("    width 8.5" , fill=TRUE, file=commandFile, append=TRUE)
    cat("    height .24" , fill=TRUE, file=commandFile, append=TRUE)
    cat("    fontsize 4" , fill=TRUE, file=commandFile, append=TRUE)
    cat("end", fill=TRUE, file=commandFile, append=TRUE)
  }
  
  cat("Vector layers: ", fill=FALSE, file=headerFile, append=TRUE)
  cat(paste(vectorLayers, collapse=", "), fill=TRUE, file=headerFile, append=TRUE)
  cat("Produced by: Karl Benedict, %d", fill=TRUE, file=headerFile, append=TRUE)
  cat("%_", fill=TRUE, file=headerFile, append=TRUE)

  cat("header" , fill=TRUE, file=commandFile, append=TRUE)
  cat(paste("    file ", headerFile, sep=""), fill=TRUE, file=commandFile, append=TRUE)
  cat("    fontsize 5" , fill=TRUE, file=commandFile, append=TRUE)
  cat("    color black" , fill=TRUE, file=commandFile, append=TRUE)
  cat("end", fill=TRUE, file=commandFile, append=TRUE)
  
  cat("paper" , fill=TRUE, file=commandFile, append=TRUE)
  cat("    width 9" , fill=TRUE, file=commandFile, append=TRUE)
  cat("    height 6" , fill=TRUE, file=commandFile, append=TRUE)
  cat("    left .25" , fill=TRUE, file=commandFile, append=TRUE)
  cat("    right .25" , fill=TRUE, file=commandFile, append=TRUE)
  cat("    top .25" , fill=TRUE, file=commandFile, append=TRUE)
  cat("    bottom .25" , fill=TRUE, file=commandFile, append=TRUE)
  cat("end", fill=TRUE, file=commandFile, append=TRUE)
  execGRASS("ps.map",
            flags=c("verbose"),
            parameters=list(input=commandFile,
                            output=outputFile),
            echoCmd=TRUE
  )
}

# clear the specified set of environmental variable values
clearVars <- function(varList) {
  for (envVar in varList) {
    Sys.unsetenv(envVar)
  }
}

# retrieve the zip file specified in the fileURL parameter, put
# it into the temp directory, and unzip it. Return the namem of
# the uncompressed directory containing the zip archive contents
getSourceZip <- function(fileURL){
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
  return(unzippedDirectory)
}

# write supplied output into an external file
outputMessage <- function(output_file, keyword, message, append = TRUE) {
  outfile <- file(output_file, "at")
  message <- paste(format_ISO8601(now()), keyword, message, sep = "|")
  message()
  message("===========================================================")
  message(message)
  message("===========================================================\n")
  writeLines(c(paste(message,"|-|", sep = "")),  outfile)
  close(outfile)
}
