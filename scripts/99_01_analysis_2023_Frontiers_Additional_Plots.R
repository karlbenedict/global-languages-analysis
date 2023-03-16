# 99_01_analysis_2023_Frontiers_Additional_Plots.R
# additinal plots generated in direct support of the Frontiers in Psychology March 2023 paper submission

# execute the shared setup file
source("scripts/00_include.R")
library(ggpubr)

# suppress scientific notation in plots
options(scipen = 999)

languages <- read_csv("output/data/v-languages.csv")

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
             "v_tmax_dC__avg", 
             "CHeavyLog",
             expression(Average~annual~maximum~temperature~( degree*C)),
             "Log-based consonant heaviness",
             "scatter_01_")

plotFunction(languages, 
             "v_qa_unitless__average", 
             "VowIndex2",
             "Specific Humidity (unitless)",
             "Vowel Index",
             "scatter_02_")

plotFunction(filter(languages, N_Ejectives > 0), 
             "v_elev_m__average", 
             "N_Ejectives",
             "Average Elevation (m)",
             "Number of Ejectives (>0)",
             "scatter_03_")

plotFunction(filter(languages, N_Ejectives > 0), 
             "v_elev_m__maximum", 
             "N_Ejectives",
             "Maximum Elevation (m)",
             "Number of Ejectives (>0)",
             "scatter_04_")

plotFunction(filter(languages, N_Ejectives > 0), 
             "v_qa_unitless__average", 
             "N_Ejectives",
             "Specific Humidity (unitless)",
             "Number of Ejectives (>0)",
             "scatter_05_")


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
ggsave("boxplot_ToneOrdinal_qa.png",
       plot=my_plot,
       path="output/images/",
       width=85,
       height=85,
       units="mm",
       dpi=300)

aov_result <- aov(v_tavg_dC__avg~as.factor(ToneOrdinal), data=languages)
summary(aov_result)
my_plot <- ggplot(languages, mapping=aes(x=as.factor(ToneOrdinal), y=v_tavg_dC__avg, color=as.factor(ToneOrdinal))) +
  geom_boxplot() +
  stat_compare_means(method="anova", label.x=1, label.y=-14, ) +
  theme_classic() +
  xlab("Ordinal Tone Value") +
  ylab(expression(Average~annual~mean~temperature~( degree*C))) +
  theme_classic() +
  theme(legend.position = "none")
my_plot
ggsave("boxplot_ToneOrdinal_tavg.png",
       plot=my_plot,
       path="output/images/",
       width=85,
       height=85,
       units="mm",
       dpi=300)
