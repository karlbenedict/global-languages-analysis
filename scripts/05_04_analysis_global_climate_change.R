# 05_04_analysis_global_climate_change.R
# global climate change trends

# execute the shared setup file
source("scripts/00_include.R")
library(tidyquant)

# suppress scientific notation in plots
options(scipen = 999)

# load CSV file from NOAA NCEI
# National Centers for Environmental Information (NCEI). 2023. Global Time Series, Climate at a Glance. Feb. 2023, https://www.ncei.noaa.gov/access/monitoring/climate-at-a-glance/global/time-series/globe/land/1/1/1850-2023.
temp_jan <- read_csv("https://www.ncei.noaa.gov/access/monitoring/climate-at-a-glance/global/time-series/globe/land/1/1/1850-2023.csv", skip=4)
temp_jul <- read_csv("https://www.ncei.noaa.gov/access/monitoring/climate-at-a-glance/global/time-series/globe/land/1/7/1850-2023.csv", skip=4)

plot_data_jan <- temp_jan %>% 
  mutate(Color = case_when(Value < 0 ~ "Negative", Value >= 0 ~ "Positive"))
plot_data_jul <- temp_jul %>% 
  mutate(Color = case_when(Value < 0 ~ "Negative", Value >= 0 ~ "Positive"))

pal <- c(
  "Negative" = "blue",
  "Positive" = "red"
)

temp_plot_jan <- ggplot(data=plot_data_jan) +
  geom_rect(aes(xmin=1950, xmax=1980, ymin=-2, ymax=2), fill="#E4E4E4") +
  geom_col(aes(x=Year, y=Value, color=Color, fill=Color)) + 
  scale_fill_manual(
    values = pal,
    limits = names(pal)
  ) + 
  scale_color_manual(
    values = pal,
    limits = names(pal)
  ) +
  geom_ma(aes(x=Year, y=Value), ma_fun = SMA, n = 10, color = "black", size = 1, linetype = "solid") +
  geom_text(x=1850, y=2, label = "January", hjust = 0) +
  ylab(expression(Temp~Anomaly~( degree*C))) +
  geom_hline(yintercept=0) +
  theme_classic() +
  theme(legend.position = "none") 
outFile <- paste("temp_global_anomaly_jan.png", sep="")
ggsave(outFile,
       plot=temp_plot_jan,
       path="output/images/",
       width=85,
       height=56.7,
       units="mm",
       dpi=300)


temp_plot_jul <- ggplot(data=plot_data_jul) +
  geom_rect(aes(xmin=1951, xmax=1980, ymin=-2, ymax=2), fill="#E4E4E4") +
  geom_col(aes(x=Year, y=Value, color=Color, fill=Color)) + 
  scale_fill_manual(
    values = pal,
    limits = names(pal)
  ) + 
  scale_color_manual(
    values = pal,
    limits = names(pal)
  ) +
  geom_ma(aes(x=Year, y=Value), ma_fun = SMA, n = 10, color = "black", size = 1, linetype = "solid") +
  geom_text(x=1851, y=2, label = "July", hjust = 0) +
  ylab(expression(Temp~Anomaly~( degree*C))) +
  geom_hline(yintercept=0) +
  theme_classic() +
  theme(legend.position = "none") 
outFile <- paste("temp_global_anomaly_jul.png", sep="")
ggsave(outFile,
       plot=temp_plot_jul,
       path="output/images/",
       width=85,
       height=56.7,
       units="mm",
       dpi=300)
