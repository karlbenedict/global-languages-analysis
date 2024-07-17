# execute the shared setup file
source("scripts/00_include.R")

fixedTime <- now()
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
execGRASS("r.info", 
          flags=c("verbose"), 
          parameters=list(map="bmng.rgb"),
          echoCmd=TRUE)
execGRASS("g.region", 
          flags=c("verbose","p"), 
          parameters=list(res="00:02:30"), 
          echoCmd=TRUE)
execGRASS("r.out.png", 
          flags=c("verbose","overwrite"), 
          parameters=list(input="Aboveground_Live_Woody_Biomass_Density",
                          output=paste(projectRoot,"/temp/tempPNG_", date(fixedTime), "T", hour(fixedTime), ":", minute(fixedTime), ":", second(fixedTime), "_", stri_rand_strings(1, 5),sep="")), 
          echoCmd=TRUE)
#ps_preview(title="title",
#           raster="bmng.rgb",
#           rasterLegend = TRUE)

