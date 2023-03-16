# 05_05_analysis_global_parameter_distributions.R
# comparison of global land parameters to the distributions of those parameters calculated for each language

# execute the shared setup file
source("scripts/00_include.R")

# suppress scientific notation in plots
options(scipen = 999)

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
          parameters=list(raster="bmng.rgb", s="-60"),
          echoCmd=TRUE
)

globalRasters <- c(
  "Aboveground_Live_Woody_Biomass_Density",
  "ACE2_elevation",
  "cdas_qa_30_yr_avg"
)

execGRASS("v.random",
          flags=c("verbose","overwrite"),
          parameters=list(
            output="random_points",
            npoints=1000,
            restrict="world_countries_2017_dissolved"
          )
          )

execGRASS("g.region",
          flags=c("verbose"),
          parameters=list(raster="bmng.rgb"),
          echoCmd=TRUE
)


ps_preview(title="Distribution of random environmental parameter sampling locations",
           raster="bmng.rgb",
           vPoints=c("random_points"),
           vPoints_colors = c("red"),
           rasterLegend=FALSE,
           output=TRUE)

execGRASS("v.db.addtable",
          flags=c("verbose"),
          parameters=list(
            map="random_points"
          ),
          echoCmd=TRUE)


for (workingRaster in globalRasters) {
execGRASS("v.what.rast",
          flags=c("verbose"),
          parameters=list(
            map="random_points",
            raster=workingRaster,
            column=workingRaster
          ),
          echoCmd=TRUE)
}

outputDataFile <- paste(projectRoot,"/output/data/random_points.csv", sep="")
outData <- distinct(as.data.frame(read_VECT("random_points"))) %>% 
  select(Aboveground_Live_Woody_Biomass_Density, ACE2_elevation, cdas_qa_30_yr_avg) %>% 
  rename(biomass=Aboveground_Live_Woody_Biomass_Density,
         elevation=ACE2_elevation,
         humidity=cdas_qa_30_yr_avg) %>% 
  mutate(source="Random Points")
write.csv(outData, file=outputDataFile)


languages <- read_csv("output/data/v-languages.csv")
languages_comparison <- languages %>% 
  select(v_biomass_MgHa__median, v_elev_m__median, v_qa_unitless__median) %>% 
  rename(biomass=v_biomass_MgHa__median,
         elevation=v_elev_m__median,
         humidity=v_qa_unitless__median) %>% 
  mutate(source="Languages")

comparisonPlots <- function(ds1,ds2, variable, file_prefix, title) {
  analysis <- bind_rows(ds1,ds2)
  result <- ks.test(ds1[[variable]],ds2[[variable]])
  plot <- ggplot(analysis, mapping=aes(x=source, y=.data[[variable]])) + 
    geom_boxplot() +
    theme_classic() +
    labs(title=title,
         subtitle = paste("KS Test: D=", signif(unname(result$statistic),digits=4), ", p-value=", signif(result[['p.value']], digits=5), " (",result['alternative'],")", sep="")) +
    theme(plot.subtitle=element_text(size=8)) +
    theme(plot.title=element_text(size=10))
  ggsave(paste(file_prefix,".png", sep=""),
         path="output/images/",
         width=4,
         height=4,
         units="in",
         dpi=300)
}
comparisonPlots(outData, languages_comparison, "biomass", "global_biomass", "Language Biomass (Mg/ha) vs. Global Biomass")
comparisonPlots(outData, languages_comparison, "elevation", "global_elevation", "Language Elevation (m) vs. Global Elevation")
comparisonPlots(outData, languages_comparison, "humidity", "global_humidity", "Language Specific Humidity vs. Global Specific Humidity")



