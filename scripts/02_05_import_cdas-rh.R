# 02_05_import_cdas-rh.R

# execute the shared setup file
source("scripts/00_include.R")

fileURL <- "https://linguistics.sfo3.digitaloceanspaces.com/compressed_source_data/noaa_necp_cdas_1_monthly.zip"

# retrieve and unzip the source file into the temp directory
unzippedDirectory <- getSourceZip(fileURL)

# import the global CDAS RH data into the 4326 location based on the 
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

sourceGrid <- paste("NETCDF:\"",unzippedDirectory, "/data.nc\":qa", sep="")
outRast <- "cdas_qa"

execGRASS("r.in.gdal",
          flags=c("overwrite","verbose","o"),
          parameters=list(input = sourceGrid,
                          output = outRast),
          echoCmd=TRUE
)

# calculate the average relative humidity (QA) for 1950-1980, represented by
# the monthy bands numbered 13-492
outlayername <- paste(outRast,"_30_yr_avg", sep="")
bands <- seq(13,492)
i <- 1
expression <- paste(outlayername," = (", sep = "")
for (band in bands) {
  expression <-  paste(expression, "cdas_qa.", band, sep = "")
  if (i < length(bands)) {
    expression <-  paste(expression,  " + ", sep = "")
  }
  else {
    expression <- paste(expression,") /", length(bands), sep = "")
  }
  i <- i + 1
}
execGRASS("r.mapcalc",
          flags=c("overwrite","verbose"),
          parameters=list(expression=expression,
                          region="union"),
          echoCmd=TRUE
)
execGRASS("r.info",
          parameters=list(map=outlayername),
          echoCmd=TRUE
)

execGRASS("g.region", 
          flags=c("verbose"), 
          parameters=list(region = "global_5-arc-minute"), 
          echoCmd=TRUE)

ps_preview(title="30-year average specific humidity (QA)",
           raster=outlayername,
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           rasterLegend = TRUE)

execGRASS("g.remove",
          flags=c("e","verbose","f"),
          parameters=list(type="raster",
                          pattern="^cdas_qa[.]{1}[0-9]{1,3}$"),
          echoCmd=TRUE
)



unlink_.gislock

