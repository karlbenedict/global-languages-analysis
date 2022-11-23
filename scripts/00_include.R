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

tempDatedFolder <- function(basepath, gisDbase, location, mapset) {
  fixedTime <- now()
  tempdir <- paste(basepath,"/", "temp/", sep = "")
  dir.create(tempdir)
  temppath <- paste(tempdir, "grassTemp_", paste(date(fixedTime), "T", hour(fixedTime), ":", minute(fixedTime), ":", second(fixedTime), "_", stri_rand_strings(1, 5), sep = ""), sep = "")
  dir.create(temppath)
  print(paste("Temp home directory: ", temppath, sep = ""))
  temppath
}

clearVars <- function(varList) {
  for (envVar in varList) {
    Sys.unsetenv(envVar)
  }
}

GRASSwrapper <- function(location, mapset, command, params, flags) {
  initGRASS(
    gisBase = gisBase,
    home = tempdir(),  #tempDatedFolder(projectRoot),
    gisDbase = gisDBase,
    location = location,
    mapset = mapset,
    override = TRUE
  )
  doGRASS(command, flags=flags, parameters=params, echoCmd=TRUE)
  stringexecGRASS("g.region -p")
}

