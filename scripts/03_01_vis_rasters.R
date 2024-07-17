# 03_01_vis_rasters.R
# generate visualizations of individual data layers

# execute the shared setup file
source("scripts/00_include.R")

sourceRasters <- list(c("ACE2_elevation","ACE2 Global Elevation (m)"),
                   c("Aboveground_Live_Woody_Biomass_Density","Aboveground Live Woody Biomass Density (Mgrams/Ha)"),
                   c("bmng.rgb","NASA Blue Marble Next Generation"),
                   c("cdas_qa_30_yr_avg","Global Specific Humidity (CDAS)"),
                   c("glc2000_v1_1_reclass","Global Land Cover"))
fixedTime <- now()

for (inRast in sourceRasters){
  cat("", fill=TRUE)
  cat("##### Processing ", inRast[1]," #########################", sep="", fill=TRUE)
  print(inRast)
  # start in the 4326 location for the source files to be converted
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
            flags=c("verbose","p"), 
            parameters=list(res="00:02:30"), 
            echoCmd=TRUE)
  execGRASS("r.out.png", 
            flags=c("verbose","overwrite"), 
            parameters=list(input=inRast[1],
                            output=paste(projectRoot,"/output/images/",substr(inRast[1],1,25),"_", date(fixedTime), "T", hour(fixedTime), ":", minute(fixedTime),".png", sep="")), 
            echoCmd=TRUE)
  ps_preview(title=inRast[2],
             raster=inRast[1],
             output=TRUE)
  
  
  cat("", fill=TRUE)
}

