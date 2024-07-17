# 05_03_analysis_gsoy_distributions.R
# distributions of GSOY weather observations through time

# execute the shared setup file
source("scripts/00_include.R")

# suppress scientific notation in plots
options(scipen = 999)


gsoy <- read_csv("output/data/gsoy_all.csv")
languages <- read_csv("output/data/v-languages.csv") %>% 
  mutate("Global Languages"="Location")

str(gsoy)

analysis <- gsoy %>% 
  select(NAME,LATITUDE,LONGITUDE,ELEVATION,DATE,PRCP,TAVG,TMIN,TMAX)
rm(gsoy)
summary(analysis)

startDate <- 1890

prcp <- analysis %>% 
  filter(!is.na(PRCP) & DATE >= startDate) %>% 
  mutate(decade = (DATE %/% 10) * 10,
         lat_deg = round(LATITUDE/5)*5,
         lon_deg = round(LONGITUDE/5)*5,
         Measurement = "Precipitation")
tavg <- analysis %>% 
  filter(!is.na(TAVG) & DATE >= startDate) %>% 
  mutate(decade = (DATE %/% 10) * 10,
         lat_deg = round(LATITUDE/5)*5,
         lon_deg = round(LONGITUDE/5)*5,
         Measurement = "Average Temperature")
tmin <- analysis %>% 
  filter(!is.na(TMIN) & DATE >= startDate) %>% 
  mutate(decade = (DATE %/% 10) * 10,
         lat_deg = round(LATITUDE/5)*5,
         lon_deg = round(LONGITUDE/5)*5,
         Measurement = "Minimum Temperature")
tmax <- analysis %>% 
  filter(!is.na(TMAX) & DATE >= startDate) %>% 
  mutate(decade = (DATE %/% 10) * 10,
       lat_deg = round(LATITUDE/5)*5,
       lon_deg = round(LONGITUDE/5)*5,
       Measurement = "Maximum Temperature")
none_missing <- analysis %>% 
  filter(!is.na(PRCP)
         & !is.na(TAVG)
         & !is.na(TMIN)
         & !is.na(TMAX) & DATE >= startDate) %>% 
  mutate(decade = (DATE %/% 10) * 10,
         lat_deg = round(LATITUDE/5)*5,
         lon_deg = round(LONGITUDE/5)*5)

combined_measurements <- bind_rows(prcp,tavg,tmin,tmax) %>% 
  select(decade,lat_deg,lon_deg,Measurement) %>% 
  group_by(decade, Measurement) %>% 
  summarise(ct = n())

measurements_bar <- ggplot(combined_measurements, mapping=aes(x=ct, y=as_factor(decade), fill=Measurement)) + 
  geom_col(position=position_dodge(0.7),
           width=0.9) + 
  theme_classic() + 
  labs(title = "Number of Global Annual Observations by Decade") +
  ylab("Decade") +
  xlab("Number of Observations")
ggsave('gsoy_measurement_bars.png',
       plot=measurements_bar,
       path="output/images/",
       width=6,
       height=4,
       units="in",
       dpi=300)


summarize_gsoy <- function(source_data, file_prefix, label, cutoff=2010){
  cts <- source_data %>% 
    filter(decade < cutoff) %>% 
    group_by(decade,lat_deg,lon_deg) %>% 
    summarise(ct = n(), .groups="keep")
  heatmap <- ggplot() +
    geom_tile(cts, mapping=aes(x=lon_deg,y=lat_deg,fill=ct)) +
    xlab(label="Longitude") +
    ylab(label="Latitude") +
    facet_wrap(decade ~ ., ncol = 3 ) +
    coord_fixed() + 
    theme_classic() +
    labs(title = label) +
    scale_fill_gradient(name = "Count of Annual Values",
                        low = "#ff0000",
                        high = "#0000ff") +
    xlim(-180,180) +
    ylim(-90,90) +
    geom_point(data=languages, mapping=aes(x=Long, y=Lat, shape="Language Locations"), size=.25, alpha=.2) +
    labs(shape='Global Languages')
    
  outFile <- paste(file_prefix,"_heatmap.png", sep="")
  ggsave(outFile,
         plot=heatmap,
         path="output/images/",
         width=180,
         height=180,
         units="mm",
         dpi=300)
return(heatmap) 
}

summarize_gsoy(prcp, "prcp", "Global Precipitation Measurements by Decade by 5x5 Degree Grid")
summarize_gsoy(tavg, "tavg", "Global Average Temperature Measurements by Decade by 5x5 Degree Grid")
summarize_gsoy(tmin, "tmin", "Global Minimum Temperature Measurements by Decade by 5x5 Degree Grid")
summarize_gsoy(tmax, "tmax", "Global Maximum Temperature Measureents by Decade by 5x5 Degree Grid")

summary(prcp)
summary(tmax)
summary(tmin)
summary(tavg)
