# 05_01_analysis_distributions_corr.R
# Analysis of distributions of language and environmental variables

# execute the shared setup file
source("scripts/00_include.R")

library(ggplot2)
library(corrplot)

languageDataFile <- paste(projectRoot,"/output/data/v-languages.csv",sep="")
gsoyDataFile <- paste(projectRoot,"/output/data/gsoy.csv",sep="")
outputDir <- paste(projectRoot,"/output/images",sep="")

languageData <- read_csv(languageDataFile)
gsoyData <- read_csv(gsoyDataFile)

# read data from language vector file
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

##### Language Characteristic Distributions ###################################
languageVariablesNum <- c('Vowindex',
                       'Onset',
                       'Coda',
                       'VQ',
                       'VTotal',
                       'CTotal',
                       'Obstr',
                       'ObsPct',
                       'SegTot',
                       'CplusVQ',
                       'ObsPct',
                       'ToneOrdinal',
                       'OnsCoda',
                       'ConsHeavy',
                       'CHeavyObstr',
                       'CHeavyLog',
                       'LogSpkrs',
                       'xImplosives'
                       )
languageVariablesChar <- c('ToneCat',
                          'FrRndV',
                          'Ejectives',
                          'Implosives',
                          'GlotRes',
                          'VelarNas',
                          'NVPattern',
                          'PNC_s',
                          'VLength'
)

# histograms for numeric variables
for (langVar in languageVariablesNum) {
  # for each language variable generate a distribution plot
  langVar <- sym(langVar)
  print(langVar)
  minVal <- min(languageData[langVar])
  maxVal <- max(languageData[langVar])
  range <- maxVal-minVal
  binWidth <- range/15
  cat(minVal,"-",maxVal,sep="",fill=TRUE)
  currPlot <- ggplot(languageData, aes(x=!!langVar)) + 
    geom_histogram(binwidth = binWidth) +
    theme_bw()
  outFile <- paste(langVar,"_hist.png", sep="")
  cat(outFile,fill=TRUE)
  ggsave(outFile,
         plot=currPlot,
         path=outputDir,
         width=9,
         height=6,
         units="in")
}

# column charts for character variables
for (langVar in languageVariablesChar) {
  # for each language variable generate a distribution plot
  langVar <- sym(langVar)
  print(langVar)
  currPlot <- ggplot(languageData, aes(x=!!langVar)) + 
    geom_bar() +
    theme_bw()
  outFile <- paste(langVar,"_col.png", sep="")
  cat(outFile,fill=TRUE)
  ggsave(outFile,
         plot=currPlot,
         path=outputDir,
         width=9,
         height=6,
         units="in")
}

##### Environmental variables #################################################
envVariables <- c(
  'v_elev_m__minimum',
  'v_elev_m__maximum',
  'v_elev_m__average',
  'v_elev_m__median',
  'v_qa_unitless__minimum',
  'v_qa_unitless__maximum',
  'v_qa_unitless__average',
  'v_qa_unitless__median',
  'v_biomass_MgHa__minimum',
  'v_biomass_MgHa__maximum',
  'v_biomass_MgHa__average',
  'v_biomass_MgHa__median',
  'v_lc_all_ct__number',
  'v_lc_tall_ct__sum',
  'v_lc_med_ct__sum',
  'v_lc_short_ct__sum',
  'v_lc_water_ct__sum',
  'v_lc_snow_ct__sum',
  'v_tavg_dC__ct',
  'v_tavg_dC__avg',
  'v_tmax_dC__ct',
  'v_tmax_dC__avg',
  'v_tmin_dC__ct',
  'v_tmin_dC__avg',
  'v_prcp_mm__ct',
  'v_prcp_mm__avg',
  'v_CRUtmean_dC__average',
  'v_CRUtmax_dC__average',
  'v_CRUtmin_dC__average',
  'v_CRUprecip_mm__average'
)
for (envVar in envVariables) {
  # for each language variable generate a distribution plot
  cat("",fill=TRUE)
  envVar <- sym(envVar)
  print(envVar)
  plotData <- languageData %>% 
    filter(!is.na(!!envVar))
  cat(nrow(plotData),fill=TRUE)
  minVal <- min(plotData[envVar])
  maxVal <- max(plotData[envVar])
  range <- maxVal-minVal
  binWidth <- range/15
  cat(minVal,"-",maxVal,sep="",fill=TRUE)
  currPlot <- ggplot(plotData, aes(x=!!envVar)) + 
    geom_histogram(binwidth = binWidth) +
    labs(x = paste(envVar," (n=",nrow(plotData),") ", sep="")) +
    theme_bw()
  outFile <- paste(envVar,"_hist.png", sep="")
  cat(outFile,fill=TRUE)
  ggsave(outFile,
         plot=currPlot,
         path=outputDir,
         width=9,
         height=6,
         units="in")
}

##### Environmental variables correlogram #####################################
envVariablesCorr <- c(
  'v_elev_m__median',
  'v_qa_unitless__median',
  'v_biomass_MgHa__median',
  'v_lc_tall_ct__sum',
  'v_lc_med_ct__sum',
  'v_lc_short_ct__sum',
  'v_lc_water_ct__sum',
  'v_lc_snow_ct__sum',
  'v_tavg_dC__avg',
  'v_tmax_dC__avg',
  'v_tmin_dC__avg',
  'v_prcp_mm__avg',
  'v_CRUtmean_dC__average',
  'v_CRUtmax_dC__average',
  'v_CRUtmin_dC__average',
  'v_CRUprecip_mm__average'
)
corrPlotData <- languageData %>% 
  select(all_of(envVariablesCorr)) %>% 
  filter_at(vars(paste(envVariablesCorr,sep=",")),all_vars(!is.na(.)))
corrM <- cor(corrPlotData)
png(height=2700, width=2700, file=paste(outputDir,"/env_corr.png",sep=""),type="cairo")
corrplot(corrM,
         method="circle",
         tl.cex=3,
         tl.col="black",
         cl.cex=2,
         type="upper")
dev.off()

##### Language and environmental variables ####################################
corrPlotData <- languageData %>% 
  select(all_of(c(envVariablesCorr,languageVariablesNum))) %>% 
  filter_at(vars(paste(c(envVariablesCorr,languageVariablesNum),sep=",")),all_vars(!is.na(.)))
corrM <- cor(corrPlotData)
png(height=5400, width=5400, file=paste(outputDir,"/env_lang_corr.png",sep=""),type="cairo")
corrplot(corrM,
         method="circle",
         tl.cex=5,
         tl.col="black",
         cl.cex=4,
         type="upper")
dev.off()

###### Language and associated weather station data ###########################
#stationFreq <- languageData %>% 
#  mutate(tavg_gt_20 = (v_tavg_dC__ct >= 20),
#         prcp_gt_20 = (v_prcp_mm__ct >= 20)) %>% 
#  select(code, tavg_gt_20, prcp_gt_20)
#
#tavt_gt_20_prop <- sum(stationFreq$tavg_gt_20)/nrow(stationFreq)
#prcp_gt_20_prop <- sum(stationFreq$prcp_gt_20)/nrow(stationFreq)
#
