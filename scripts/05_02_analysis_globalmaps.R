# 05_02_analysis_globalmaps.R
# Global distribution maps

# execute the shared setup file
source("scripts/00_include.R")

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
          parameters=list(raster="bmng.rgb"),
          echoCmd=TRUE
)

##### Global Land Cover #######################################################
reclassFile <- paste(projectRoot,"/temp/glc_global_reclass.txt",sep="")
cat("1 thru 8 10 17 = 1 Tall Vegetation", fill=TRUE, file=reclassFile, append=FALSE)
cat("9 11 12 = 2 Intermediate Height Vegetation", fill=TRUE, file=reclassFile, append=TRUE)
cat("13 thru 15 18 19 = 3 Low Vegetation", fill=TRUE, file=reclassFile, append=TRUE)
cat("20 = 10 Water", fill=TRUE, file=reclassFile, append=TRUE)
cat("21 = 11 Snow", fill=TRUE, file=reclassFile, append=TRUE)
cat("* = 99 Other Categories", fill=TRUE, file=reclassFile, append=TRUE)

glcRulesFile <- paste(projectRoot,"/temp/glc_rules.txt",sep="")
cat("1 21:99:20",fill=TRUE,file=glcRulesFile,append=FALSE)
cat("2 98:214:96",fill=TRUE,file=glcRulesFile,append=TRUE)
cat("3 197:214:96",fill=TRUE,file=glcRulesFile,append=TRUE)
cat("10 32:46:153",fill=TRUE,file=glcRulesFile,append=TRUE)
cat("11 242:243:250",fill=TRUE,file=glcRulesFile,append=TRUE)
cat("99 0:0:0",fill=TRUE,file=glcRulesFile,append=TRUE)

execGRASS("r.reclass",
          flags=c("overwrite","verbose"),
          parameters=list(input = "glc2000_v1_1",
                          output = "glc2000_v1_1_reclass_vis",
                          rules = reclassFile),
          echoCmd=TRUE
)

execGRASS("r.colors",
          flags=c("verbose"),
          parameters=list(map="glc2000_v1_1_reclass_vis",
                          rules=glcRulesFile),
          echoCmd=TRUE
)

ps_preview(title="Reclassified global land cover data",
           raster="glc2000_v1_1_reclass_vis",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           rasterLegend=TRUE,
           cols=2,
           output=TRUE)

##### ACE2 elevation ##########################################################
ps_preview(title="Global elevation data",
           raster="ACE2_elevation",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           rasterLegend=TRUE,
           cols=2,
           output=TRUE,
           where=".25 5.5")

##### Specific Humidity #######################################################
ps_preview(title="Global specific humidity",
           raster="cdas_qa_30_yr_avg",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           rasterLegend=TRUE,
           cols=2,
           output=TRUE,
           where=".25 5.5")

##### Specific Humidity #######################################################
ps_preview(title="Global specific humidity",
           raster="cdas_qa_30_yr_avg",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           rasterLegend=TRUE,
           cols=2,
           output=TRUE,
           where=".25 5.5")

##### Above Ground woody biomass #######################################################
execGRASS("r.colors",
          flags=c("verbose","n"),
          parameters=list(map="Aboveground_Live_Woody_Biomass_Density",
                          color="grass"),
          echoCmd=TRUE
)

ps_preview(title="Average global aobve ground woody biomass (Mg/Ha)",
           raster="Aboveground_Live_Woody_Biomass_Density",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           rasterLegend=TRUE,
           cols=2,
           output=TRUE,
           where=".25 5.5")

##### gsoy weather data #######################################################
ps_preview(title="Distribution of global Average Temperature stations (1950-1980)",
           raster="bmng.rgb",
           vPoints=c("gsoy_tavg"),
           vPoints_colors = c("yellow"),
           output=TRUE)
ps_preview(title="Distribution of global Precipitation stations (1950-1980)",
           raster="bmng.rgb",
           vPoints=c("gsoy_prcp"),
           vPoints_colors = c("yellow"),
           output=TRUE)

##### languages data #######################################################
execGRASS("g.region",
          flags=c("verbose"),
          parameters=list(n="90",
                          s="-90",
                          e="180",
                          w="-180",
                          res="00:05:00"),
          echoCmd=TRUE
)

ps_preview(title="Distribution of project languages",
           raster="bmng.rgb",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           output=TRUE)

ps_preview(title="Global distribution of project languages environmental samples",
           raster="bmng.rgb",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           vAreas=c("languages_voronoi_clipped"),
           vAreas_colors = c("black"),
           vAreas_fcolors = c("yellow"),
           output=TRUE)

execGRASS("g.region",
          flags=c("verbose"),
          parameters=list(w="-115",
                          e="-80",
                          s="10",
                          n="30",
                          res="00:00:30"),
          echoCmd=TRUE
)

ps_preview(title="Distribution of project languages environmental samples (Central America)",
           raster="bmng.rgb",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           vAreas=c("languages_voronoi_clipped"),
           vAreas_colors = c("black"),
           vAreas_fcolors = c("yellow"),
           output=TRUE,
           bbox="CentAm")

execGRASS("g.region",
          flags=c("verbose"),
          parameters=list(w="10",
                          e="45",
                          s="-30",
                          n="-10",
                          res="00:00:30"),
          echoCmd=TRUE
)

ps_preview(title="Distribution of project languages environmental samples (SW Africa)",
           raster="bmng.rgb",
           vPoints=c("languages"),
           vPoints_colors = c("red"),
           vAreas=c("languages_voronoi_clipped"),
           vAreas_colors = c("black"),
           vAreas_fcolors = c("yellow"),
           output=TRUE,
           bbox="SWAfri")


##### Ejectives ###############################################################
# currently throwing error - no such column: xEjectives
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
          parameters=list(raster="bmng.rgb"),
          echoCmd=TRUE
)
ps_preview(title="Number of Ejectives",
           raster="bmng.rgb",
           vPoints=c("languages","languages"),
           vPoints_colors = c("white","red"),
           vPoints_sizeColumn = c("","xEjectives"),
           vPoints_where = c("xEjectives = 0", "xEjectives > 0"),
           output=TRUE,
           bbox="global",
           prefix="nejectives")

