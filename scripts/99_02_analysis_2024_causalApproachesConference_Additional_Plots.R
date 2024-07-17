# 99_01_analysis_2023_Frontiers_Additional_Plots.R
# additinal plots generated in direct support of the Frontiers in Psychology March 2023 paper submission

# execute the shared setup file
source("scripts/00_include.R")
library(ggpubr)

# suppress scientific notation in plots
options(scipen = 999)

languages <- read_csv("output/data/v-languages.csv")
distances <- read_csv("output/data/distances.csv")

plotFunction <- function(plot_data,  x, y, x_label, y_label, outfile_name_prefix) {
  plot_data <- plot_data %>% 
    select(!!x,!!y) %>% 
    mutate(test = is.na(!!sym(x)) + is.na(!!sym(y))) %>% 
    filter(test == 0)
  outfile <- paste(outfile_name_prefix, "_", x, "_", y, ".png", sep="")
  n <- nrow(plot_data)
  min_x <- min(plot_data[[x]], na.rm = TRUE)
  max_x <- max(plot_data[[x]], na.rm = TRUE)
  min_y <-min(plot_data[[y]], na.rm = TRUE)   
  max_y <- max(plot_data[[y]], na.rm = TRUE)
  label_x_1 <- min_x + ( (max_x - min_x) * .01)
  label_y_1 <- min_y - ( (max_y - min_y) * .05)
  label_x_2 <- min_x + ( (max_x - min_x) * .01)
  label_y_2 <- min_y - ( (max_y - min_y) * .085)
  label_y_3 <- min_y - ( (max_y - min_y) * .12)
  print(paste(min_x, max_x, min_y, max_y))
  my_plot <- ggplot(plot_data, mapping=aes(x=.data[[x]], y=.data[[y]], add="reg.line")) +
    geom_point(size=.25) +
    geom_smooth(method='lm', formula=y~x) +
    ylab(y_label) +
    xlab(x_label) +
    theme_classic() +
    stat_cor(label.x=label_x_1, label.y=label_y_1, size=2) +
    stat_regline_equation(label.x=label_x_2, label.y=label_y_2, size=2) +
    annotate("text", x=label_x_1, y=label_y_3, label=paste("n=",n,sep=""), hjust=0, size=2) +
    theme(text = element_text(size = 8))
  ggsave(outfile,
         plot=my_plot,
         path="output/images/",
         width=85,
         height=85,
         units="mm",
         dpi=300)
  return(my_plot)
}

plotFunction(languages, 
             "v_CRUtmax_dC__average", 
             "CHeavyLog",
             expression(Average~annual~maximum~temperature~( degree*C)),
             "Log-based consonant heaviness",
             "2024-05_causal_scatter_01_")

plotFunction(languages, 
             "v_qa_unitless__average", 
             "VowIndex2",
             "Specific Humidity (unitless)",
             "Vowel Index",
             "2024-05_causal_scatter_02_")

plotFunction(filter(languages, N_Ejectives > 0), 
             "v_elev_m__average", 
             "N_Ejectives",
             "Average Elevation (m)",
             "Number of Ejectives (>0)",
             "2024-05_causal_scatter_03_")

plotFunction(filter(languages, N_Ejectives > 0), 
             "v_elev_m__maximum", 
             "N_Ejectives",
             "Maximum Elevation (m)",
             "Number of Ejectives (>0)",
             "2024-05_causal_scatter_04_")

plotFunction(filter(languages, N_Ejectives > 0), 
             "v_qa_unitless__average", 
             "N_Ejectives",
             "Specific Humidity (unitless)",
             "Number of Ejectives (>0)",
             "2024-05_causal_scatter_05_")

# return label text for the number of observations in a group
# modified from https://stackoverflow.com/questions/28846348/add-number-of-observations-per-group-in-boxplot
give.n <- function(x){
  return(
    data.frame(
      y = -.75,
      label = toString(length(x))
    )
  ) 
}


# boxplots for tone ordinality vs. humidity and average temperature
aov_result <- aov(v_qa_unitless__average~as.factor(ToneOrdinal), data=languages)
summary(aov_result)
my_plot <- ggplot(languages, mapping=aes(x=as.factor(ToneOrdinal), y=v_qa_unitless__average, color=as.factor(ToneOrdinal))) +
  geom_boxplot() +
  stat_compare_means(method="anova", label.x=1, label.y=0.0001, ) +
  theme_classic() +
  xlab("Ordinal Tone Value") +
  ylab("Average Specific Humidity (unitless)") +
  theme_classic() +
  theme(legend.position = "none")
my_plot
ggsave("2024-05_causal_boxplot_ToneOrdinal_qa.png",
       plot=my_plot,
       path="output/images/",
       width=85,
       height=85,
       units="mm",
       dpi=300)

aov_result <- aov(v_CRUtmean_dC__average~as.factor(ToneOrdinal), data=languages)
summary(aov_result)
my_plot <- ggplot(languages, mapping=aes(x=as.factor(ToneOrdinal), y=v_CRUtmean_dC__average, color=as.factor(ToneOrdinal))) +
  geom_boxplot() +
  stat_compare_means(method="anova", label.x=2, label.y=-14, ) +
  theme_classic() +
  xlab("Ordinal Tone Value") +
  ylab(expression(Average~monthly~mean~temperature~( degree*C))) +
  theme_classic() +
  theme(legend.position = "none")
my_plot
ggsave("2024-05_causal_boxplot_ToneOrdinal_tavg.png",
       plot=my_plot,
       path="output/images/",
       width=85,
       height=85,
       units="mm",
       dpi=300)

aov_result <- aov(v_elev_m__maximum~Ejectives, data=languages)
summary(aov_result)
my_plot <- ggplot(languages, mapping=aes(x=Ejectives, y=v_elev_m__maximum, color=Ejectives)) +
  geom_boxplot() +
  stat_compare_means(method="anova", label.x=1, label.y=0, ) +
  theme_classic() +
  xlab("Ejectives") +
  ylab("Average Maximum Elevation (m)") +
  theme_classic() +
  theme(legend.position = "none")
my_plot
ggsave("2024-05_causal_boxplot_Ejectives_Elev.png",
       plot=my_plot,
       path="output/images/",
       width=85,
       height=85,
       units="mm",
       dpi=300)

aov_result <- aov(v_CRUprecip_mm__average~VelarNas, data=languages)
summary(aov_result)
my_plot <- ggplot(languages, mapping=aes(x=VelarNas, y=v_CRUprecip_mm__average, color=VelarNas)) +
  geom_boxplot() +
  stat_compare_means(method="anova", label.x=1, label.y=0, ) +
  theme_classic() +
  xlab("Velar Nasal") +
  ylab("Average Monthly Precipitation (mm)") +
  theme_classic() +
  theme(legend.position = "none")
my_plot
ggsave("2024-05_causal_boxplot_VelarNas_Prcp.png",
       plot=my_plot,
       path="output/images/",
       width=85,
       height=85,
       units="mm",
       dpi=300)

aov_result <- aov(v_biomass_MgHa__average~VelarNas, data=languages)
summary(aov_result)
my_plot <- ggplot(languages, mapping=aes(x=VelarNas, y=v_biomass_MgHa__average, color=VelarNas)) +
  geom_boxplot() +
  stat_compare_means(method="anova", label.x=1, label.y=0, ) +
  theme_classic() +
  xlab("Velar Nasal") +
  ylab("Average Biomass (Mg/Ha)") +
  theme_classic() +
  theme(legend.position = "none")
my_plot
ggsave("2024-05_causal_boxplot_VelarNas_Biomass.png",
       plot=my_plot,
       path="output/images/",
       width=85,
       height=85,
       units="mm",
       dpi=300)


# calculate sample region areas for languages
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
          parameters=list(w="-180",
                          e="180",
                          s="-90",
                          n="90",
                          res="00:00:30"),
          echoCmd=TRUE
)

sink("output/data/areas.txt")
areas <- execGRASS("v.to.db",
          flags=c("verbose","p"),
          parameters=list(map="languages_voronoi_clipped",
                          type="boundary",
                          option="area",
                          units="hectares"),
          echoCmd=TRUE
)
sink()

areas_data <- read_delim("output/data/areas.txt",
                         delim="|",
                         skip=1)
buffer_area_ha <- (pi * 100000^2)/10000
areas_buff_proportion <- areas_data %>% 
  filter(!is.na(area)) %>% 
  mutate(cat=as.numeric(cat),
         proportion=area/buffer_area_ha) %>% 
  left_join(languages, by="cat") %>% 
  select(cat,code,area,proportion,Lat,Long)
summary(areas_buff_proportion)
areas_gt1 <- areas_buff_proportion %>% 
  filter(proportion>1)
