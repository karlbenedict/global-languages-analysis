# 99_01_analysis_2023_Frontiers_Additional_Plots.R
# additinal plots generated in direct support of the Frontiers in Psychology March 2023 paper submission

# execute the shared setup file
source("scripts/00_include.R")

# suppress scientific notation in plots
options(scipen = 999)

languages <- read_csv("output/data/v-languages.csv")

# CHeavyLog vs. v_tmax_dC__avg
plot <- ggplot(languages, mapping=aes(x=v_tmax_dC__avg, y=CHeavyLog, add="reg.line")) +
  geom_point() +
  ylab("Log-based consonant heaviness") +
  xlab(expression(Average~annual~maximum~temperature~( degree*C))) +
  theme_classic() +
  stat_cor(label.x=-10, label.y=2.0)
plot