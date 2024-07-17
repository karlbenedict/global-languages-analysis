# 02_10_import_CRU.R

# execute the shared setup file
source("scripts/00_include.R")

fileURL <- "https://linguistics.sfo3.digitaloceanspaces.com/compressed_source_data/CRU_data.zip"

# retrieve and unzip the source file into the temp directory and store the directory name where the unzipped files are located
unzippedDirectory <- getSourceZip(fileURL)

# Generate lists of the path-filenames for each specified parameter and time range
yearRange <- seq(1950, 1979)
params <- c("CRU_maximum_temperature", 
            "CRU_mean_temperature",
            "CRU_minimum_temperature", 
            "CRU_total_precipitation" )

# import the global CRU Temp data into the 4326 location based on the 
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

summaries <- hash()
rasters <- hash()
for (param in params) { 
  print(param)
  fileList <- c()
  fileMatchPattern <- paste("^", param, sep="")
  workingFileList <- list.files(unzippedDirectory, pattern=fileMatchPattern, full.names=FALSE)
  i = 1
  for (year in yearRange) {
    # for each annual collection of 12 monthly gridded parameter values
    # - Retrieve the specific file containing the current parameter for the current year
    # - Read the corresponding NetCDF file using the 'tidync' library
    # - Activate the dimension that corresponds with the data values (this is the default), done for safety
    # - Extract the short parameter name from the read dataset
    # - Build a 3d array of monthly data values by processing each annual file and adding its 12-months of data as 12 additional arrays in the third dimension of a combined 3d array
    # - Calculate the average data values across all of the monthly arrays that have been combined into the 3d array - yielding an output array with the average values of the same dimensions of the original first two dimensions (i.e. the lat-lon grid)
    # - add the resulting array of average data values to a 'hash' of parameter names combined with their corresponding average value array
    yearSubset <- workingFileList[str_detect(workingFileList, as.character(year))]
    fileList <- append(fileList, yearSubset)
    cruPathFile <- paste(unzippedDirectory, yearSubset[1], sep = "/")
    print(paste("processing file: ", cruPathFile))
    cru <- tidync(cruPathFile)
    activate(cru, "D1,D2,D0")
    param_name <- cru$variable$name[4]
    
    working_array <- cru %>%
      hyper_array()
    print(paste("parameter name: ", names(working_array), sep=" "))
    if (i == 1) {
      working_combined <- working_array[[1]]
    } else {
      working_combined <- abind(working_combined, working_array[[1]])
    }
    print(dim(working_combined))
    i = i + 1
  }
  working_avg <- apply(working_combined, c(1,2),mean, na.rm=TRUE)
  print(working_avg)
  summaries[[param]] <- working_avg
  print(dim(summaries[[param]]))
  rasters[[param]] <- flip(t(raster(summaries[[param]], xmn=-90, xmx=90, ymn=-180, ymx=180, crs="+proj=longlat +datum=WGS84")), direction="y")
  image(summaries[[param]])
  plot(rasters[[param]])
  # write out the average raster to a GeoTIFF for subsequent import into GRASS
  out_raster_path <- paste(unzippedDirectory, "/!avg_",min(yearRange), "-", max(yearRange), "_", param, ".tif", sep="")
  rf <- writeRaster(rasters[[param]], filename=out_raster_path, format="GTiff", overwrite=TRUE)
  # import the saved GeoTIFF into GRASS for subsequent processing and preview the resulting raster dataset
  # set to higher-resolution region to align with other raster datasets
  execGRASS("g.region", 
            flags=c("verbose"), 
            parameters=list(region = "global_30-arc-second"), 
            echoCmd=TRUE)
  
 execGRASS("r.in.gdal",
            flags=c("overwrite","verbose","o"),
            parameters=list(input = out_raster_path,
                            output = param),
            echoCmd=TRUE
  )
  execGRASS("r.info",
            parameters=list(map=param),
            echoCmd=TRUE
  )
  # set to the lower resolution region to streamline visualization
  execGRASS("g.region", 
            flags=c("verbose"), 
            parameters=list(region = "global_5-arc-minute"), 
            echoCmd=TRUE)
  ps_preview(title=param,
             raster=param,
             vPoints=c("languages"),
             vPoints_colors = c("red"),
             rasterLegend = TRUE)
}
keys(summaries)

unlink_.gislock

