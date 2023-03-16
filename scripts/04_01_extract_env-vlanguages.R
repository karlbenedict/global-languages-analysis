# 04_01_env-vlanguages.R
# extract environmental statistics into language voronoi polygons

# execute the shared setup file
source("scripts/00_include.R")

polygonsLayer <- "languages_voronoi_clipped"
fixedTime <- now()
outputDataFile <- paste(projectRoot,"/output/data/v-languages.csv", sep="")
outputSourceLanguages <- paste(projectRoot,"/output/data/languages.csv", sep="")

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


##### Elevation stats #########################################################
rasterLayer <- "ACE2_elevation"
execGRASS("g.region", 
          flags=c("verbose","p"), 
          parameters=list(res="00:00:30"), 
          echoCmd=TRUE)
execGRASS("v.rast.stats",
          flags=c("verbose","c","d"),
          parameters=list(map = polygonsLayer,
                          raster = rasterLayer,
                          method = c("number", "null_cells", "minimum", "maximum", "range", "average", "stddev", "variance", "coeff_var", "first_quartile", "median", "third_quartile"),
                          column_prefix = "v_elev_m_"),
          echoCmd=TRUE)
execGRASS("v.info",
          flags=c("c"),
          parameters=list(map = polygonsLayer),
          echoCmd=TRUE)

##### Specific Hummidity stats ################################################
rasterLayer <- "cdas_qa_30_yr_avg"
execGRASS("g.region", 
          flags=c("verbose","p"), 
          parameters=list(res="00:00:30"), 
          echoCmd=TRUE)
execGRASS("v.rast.stats",
          flags=c("verbose","c","d"),
          parameters=list(map = polygonsLayer,
                          raster = rasterLayer,
                          method = c("number", "null_cells", "minimum", "maximum", "range", "average", "stddev", "variance", "coeff_var", "first_quartile", "median", "third_quartile"),
                          column_prefix = "v_qa_unitless_"),
          echoCmd=TRUE)
execGRASS("v.info",
          flags=c("c"),
          parameters=list(map = polygonsLayer),
          echoCmd=TRUE)


##### Biomass stats ###########################################################
rasterLayer <- "Aboveground_Live_Woody_Biomass_Density"
execGRASS("g.region", 
          flags=c("verbose","p"), 
          parameters=list(res="00:00:30"), 
          echoCmd=TRUE)
execGRASS("v.rast.stats",
          flags=c("verbose","c","d"),
          parameters=list(map = polygonsLayer,
                          raster = rasterLayer,
                          method = c("number", "null_cells", "minimum", "maximum", "range", "average", "stddev", "variance", "coeff_var", "first_quartile", "median", "third_quartile"),
                          column_prefix = "v_biomass_MgHa_"),
          echoCmd=TRUE)
execGRASS("v.info",
          flags=c("c"),
          parameters=list(map = polygonsLayer),
          echoCmd=TRUE)


##### Landcover stats ###########################################################
rasterLayer <- "glc2000_v1_1_reclass"
execGRASS("g.region", 
          flags=c("verbose","p"), 
          parameters=list(res="00:00:30"), 
          echoCmd=TRUE)
# all cells within a language polygon
execGRASS("v.rast.stats",
          flags=c("verbose","c","d"),
          parameters=list(map = polygonsLayer,
                          raster = rasterLayer,
                          column_prefix = "v_lc_all_ct_",
                          method = c("number","null_cells")),
          echoCmd=TRUE)
# generate and tally logical raster content for each land cover type
lcClasses <- list(c("lc_tall","1"),
                  c("lc_med","2"),
                  c("lc_short","3"),
                  c("lc_water","10"),
                  c("lc_snow","11"))
for (lcClass in lcClasses) {
  execGRASS("r.mapcalc",
            flags=c("overwrite","verbose"),
            parameters=list(expression = paste(lcClass[1]," = ", rasterLayer, " == ", lcClass[2], sep="")),
            echoCmd=TRUE
  )
  execGRASS("v.rast.stats",
            flags=c("verbose","c","d"),
            parameters=list(map = polygonsLayer,
                            raster = lcClass[1],
                            column_prefix = paste("v_",lcClass[1],"_ct_",sep=""),
                            method = c("number","null_cells","sum")),
            echoCmd=TRUE
  )
  
}
execGRASS("v.info",
          flags=c("c"),
          parameters=list(map = polygonsLayer),
          echoCmd=TRUE)


##### Global climate data stats ###############################################
# calculation of average annual statistic for all station-years within each 
# polygon
statColumns <- list(c("TAVG","v_tavg_dC_"),
                    c("TMAX","v_tmax_dC_"),
                    c("TMIN","v_tmin_dC_"),
                    c("PRCP","v_prcp_mm_"))
pointsLayer <- "gsoy"
# make a copy of the layer to cast column values to numeric 

for (pointColumn in statColumns){
  execGRASS("v.vect.stats",
            flags=c("verbose"),
            parameters=list(points = pointsLayer,
                             areas = polygonsLayer,
                             points_where = paste(pointColumn[1],"IS NOT NULL", sep=" "),
                             method = "average",
                             points_column = pointColumn[1],
                             count_column = paste(pointColumn[2],"_ct", sep = ""),
                             stats_column = paste(pointColumn[2],"_avg", sep = "")),
            echoCmd=TRUE
  )
  
}
execGRASS("v.info",
          flags=c("c"),
          parameters=list(map = pointsLayer),
          echoCmd=TRUE)
execGRASS("v.info",
          flags=c("c"),
          parameters=list(map = polygonsLayer),
          echoCmd=TRUE)



##### Export extracted data to CSV for further analysis #######################
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
outData <- distinct(as.data.frame(read_VECT(polygonsLayer)))
outSourceLanguages <- distinct(as.data.frame(read_VECT("languages")))
write.csv(outData, file=outputDataFile)
write.csv(outSourceLanguages, file=outputSourceLanguages)

library(sets)
outputDataFile <- read_csv(paste(projectRoot,"/output/data/v-languages.csv", sep=""))
outputSourceLanguages <- read_csv(paste(projectRoot,"/output/data/languages.csv", sep=""))
cat("The languages that did not make it through the generation and extraction process are:", unlist(set_complement(as.set(outputDataFile[['code']]),as.set(outputSourceLanguages[['code']]))))

