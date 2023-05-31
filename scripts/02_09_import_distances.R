# 02_09_import_distances.R

# execute the shared setup file
source("scripts/00_include.R")

# load additional libraries 
library(ecodist)

# set testing to TRUE to process only a subset of data to speed testing
testing <- FALSE

# Distance calculation function for a specified language or environmental attribute
dist_calc <- function(source_df, col_name) {
  print(paste("starting distance calculation for: ", col_name))
  vars <- c("code", col_name)
  analysis_subset <- source_df %>%
    filter((!is.na(.data[[col_name]]))) %>%
    select(all_of(vars))
  #print(analysis_subset)
  # calculate attribute distance matrix
  analysis_distance <- distance(analysis_subset[,-1])
  analysis_distance_df <- data.frame(code_pair=character(), lc_01=character(), lc_02=character())
  for (i in seq(length(analysis_subset$code) - 1)){
    for (j in seq(i+1,length(analysis_subset$code))) {
      analysis_distance_df <- add_row(
        analysis_distance_df,
        code_pair=paste(pmin(analysis_subset$code[i], analysis_subset$code[j]), pmax(analysis_subset$code[i], analysis_subset$code[j]), sep = "-"),
        lc_01=analysis_subset$code[i],
        lc_02=analysis_subset$code[j]
      )
    }
  }
  distance_out <- analysis_distance_df %>%
    mutate("{col_name}_dist" := lower(analysis_distance))
  return(distance_out)  
}

# import language data file from the previously generated CSV export file
languages <- read_csv(paste(projectRoot,"output/data/v-languages.csv", sep = "/"))

# import language distances from manually created distance spreadsheets
distance_files_folder <- paste(projectRoot, "temp/global-languages-data-master/distances", sep="/")
distance_files <- list.files(distance_files_folder, pattern="xlsx$")

manual_distances_tall <- tibble(
  lc_01 = character(),
  lc_02 = character(),
  code_pair = character(),
  man_dist = numeric()
)
for (dist_file in distance_files) {
  print(paste("processing: ",dist_file))
  working_df <- read_excel(paste(distance_files_folder, dist_file, sep="/"))
  working_distances_tall <- working_df %>%
    pivot_longer(cols = -c(code), names_to = "c2") %>%
    mutate(c1 = code,
           lc_01 = pmin(c1,c2),
           lc_02 = pmax(c1,c2),
           man_dist = as.numeric(value)) %>%
    unite("code_pair", lc_01, lc_02, sep="-", remove=FALSE) %>%
    arrange(code_pair) %>%
    select(lc_01, lc_02, code_pair, man_dist) %>%
    filter(!is.na(man_dist) & man_dist<10 & (lc_01 != lc_02)) # exclude unrelated languages (man_dist = 10) and same language pairs
  str(working_distances_tall)
  manual_distances_tall <- rbind(manual_distances_tall, working_distances_tall)
}

# create the master tibble to which the results of the individual distance calculations will be added as columns through a left-join
# the master tibble contains all language pairs represented by the working language file

## work with only a subset of languages if "testing" is TRUE
if (testing) {
  languages <- languages %>%
    filter(Family == "Austro-Asiatic")
}

out_df <- data.frame(code_pair=character(),
                     lc_01=character(),
                     lc_02=character()
)
k <- 1
for (i in seq(length(languages$code) - 1)){
  for (j in seq(i+1,length(languages$code))) {
    out_df <- add_row(out_df,
                      lc_01=languages$code[i],
                      lc_02=languages$code[j],
                      code_pair=paste(pmin(languages$code[i], languages$code[j]), pmax(languages$code[i], languages$code[j]), sep = "-"),
    )
  }
  k <- k + 1
  if (k %% 10 == 0) {cat(paste(k, ":", length(out_df$code_pair), " ", sep = ""))}
}

# add manually created distances to composite output file
# TODO - add filter for NA values for language pair distances (i.e. language pairs for which distances 
# have not been defined or are set to 10 within a family group)
out_df <- out_df %>%
  left_join(manual_distances_tall)

# add specified attribute distances to the composite output file
language_attributes <- c("Vowindex",
                         "OnsCoda",
                         "ObsPct",
                         "ConsHeavy",
                         "v_elev_m__median",
                         "v_qa_unitless__median",
                         "v_biomass_MgHa__median",
                         "v_tmax_dC__avg",
                         "v_tmin_dC__avg",
                         "v_tavg_dC__avg",
                         "v_prcp_mm__avg")

for (language_attribute in language_attributes) {
  out_df <- left_join(out_df, dist_calc(languages, language_attribute), multiple = 'all')
}



### Write out combined distance matrix results into a single combined CSV file
write_csv(out_df, paste(projectRoot,"output/data/distances.csv", sep = "/"))



