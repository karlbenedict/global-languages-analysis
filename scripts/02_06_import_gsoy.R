# 02_06_import_gsoy.R

# execute the shared setup file
source("scripts/00_include.R")

fileURL <- "https://linguistics.sfo3.digitaloceanspaces.com/compressed_source_data/gsoy-latest.zip"
# is this a test run?
gsoy_test_run <- FALSE
sampleSize <- 100 # only applicable when doing a test run
# define temporal subset to extract and process
startYear <- 1951
endYear <- 1980


# retrieve and unzip the source file into the temp directory
unzippedDirectory <- getSourceZip(fileURL)

gsoy_file_path <- unzippedDirectory
outfile_path <- paste(projectRoot,"/output/data/gsoy.csv", sep = "")
# the csvt file provides the reference information used to define column type
# when the csv file is imported into GRASS
csvt_path <- paste(projectRoot,"/output/data/gsoy.csvt", sep = "")
columns <- '"String","String","String","Point(Y)","Point(X)","Real","Integer","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","Real","String","String"'
cat(columns,file=csvt_path, append=FALSE)

# build combined content template dataframe (tibble)
gsoy_data_df <- tibble(
  "DATASET_NAME" = character(),
  "STATION" = character(),
  "NAME" = character(),
  "LATITUDE" = double(),
  "LONGITUDE" = double(),
  "ELEVATION" = double(),
  "DATE" = integer(),
  "AWND" = double(),
  "AWND_ATTRIBUTES" = character(),
  "CDSD" = double(),
  "CDSD_ATTRIBUTES" = character(),
  "CLDD" = double(),
  "CLDD_ATTRIBUTES" = character(),
  "DP01" = double(),
  "DP01_ATTRIBUTES" = character(),
  "DP10" = double(),
  "DP10_ATTRIBUTES" = character(),
  "DP0X" = double(),
  "DP0X_ATTRIBUTES" = character(),
  "DP1X" = double(),
  "DP1X_ATTRIBUTES" = character(),
  "DSND" = double(),
  "DSND_ATTRIBUTES" = character(),
  "DSNW" = double(),
  "DSNW_ATTRIBUTES" = character(),
  "DT00" = double(),
  "DT00_ATTRIBUTES" = character(),
  "DT32" = double(),
  "DT32_ATTRIBUTES" = character(),
  "DX32" = double(),
  "DX32_ATTRIBUTES" = character(),
  "DX70" = double(),
  "DX70_ATTRIBUTES" = character(),
  "DX90" = double(),
  "DX90_ATTRIBUTES" = character(),
  "EMNT" = double(),
  "EMNT_ATTRIBUTES" = character(),
  "EMSD" = double(),
  "EMSD_ATTRIBUTES" = character(),
  "EMSN" = double(),
  "EMSN_ATTRIBUTES" = character(),
  "EMXP" = double(),
  "EMXP_ATTRIBUTES" = character(),
  "EMXT" = double(),
  "EMXT_ATTRIBUTES" = character(),
  "EVAP" = double(),
  "EVAP_ATTRIBUTES" = character(),
  "FZF0" = double(),
  "FZF0_ATTRIBUTES" = character(),
  "FZF1" = double(),
  "FZF1_ATTRIBUTES" = character(),
  "FZF2" = double(),
  "FZF2_ATTRIBUTES" = character(),
  "FZF3" = double(),
  "FZF3_ATTRIBUTES" = character(),
  "FZF4" = double(),
  "FZF4_ATTRIBUTES" = character(),
  "FZF5" = double(),
  "FZF5_ATTRIBUTES" = character(),
  "FZF6" = double(),
  "FZF6_ATTRIBUTES" = character(),
  "FZF7" = double(),
  "FZF7_ATTRIBUTES" = character(),
  "FZF8" = double(),
  "FZF8_ATTRIBUTES" = character(),
  "FZF9" = double(),
  "FZF9_ATTRIBUTES" = character(),
  "HDSD" = double(),
  "HDSD_ATTRIBUTES" = character(),
  "HNyz" = double(),
  "HNyz_ATTRIBUTES" = character(),
  "HTDD" = double(),
  "HTDD_ATTRIBUTES" = character(),
  "HXyz" = double(),
  "HXyq_ATTRIBUTES" = character(),
  "LNyz" = double(),
  "LNyz_ATTRIBUTES" = character(),
  "LXyz" = double(),
  "LXyz_ATTRIBUTES" = character(),
  "MN01" = double(),
  "MN01_ATTRIBUTES" = character(),
  "MNPN" = double(),
  "MNPN_ATTRIBUTES" = character(),
  "MNyz" = double(),
  "MNyz_ATTRIBUTES" = character(),
  "MX01" = double(),
  "MX01_ATTRIBUTES" = character(),
  "MXPN" = double(),
  "MXPN_ATTRIBUTES" = character(),
  "MXyz" = double(),
  "MXyz_ATTRIBUTES" = character(),
  "PRCP" = double(),
  "PRCP_ATTRIBUTES" = character(),
  "PSUN" = double(),
  "PSUN_ATTRIBUTES" = character(),
  "SNOW" = double(),
  "SNOW_ATTRIBUTES" = character(),
  "TAVG" = double(),
  "TAVG_ATTRIBUTES" = character(),
  "TMAX" = double(),
  "TMAX_ATTRIBUTES" = character(),
  "TMIN" = double(),
  "TMIN_ATTRIBUTES" = character(),
  "TSUN" = double(),
  "TSUN_ATTRIBUTES" = character(),
  "WDF1" = double(),
  "WDF1_ATTRIBUTES" = character(),
  "WDF2" = double(),
  "WDF2_ATTRIBUTES" = character(),
  "WDF5" = double(),
  "WDF5_ATTRIBUTES" = character(),
  "WDFG" = double(),
  "WDFG_ATTRIBUTES" = character(),
  "WDFI" = double(),
  "WDFI_ATTRIBUTES" = character(),
  "WDFM" = double(),
  "WDFM_ATTRIBUTES" = character(),
  "WDMV" = double(),
  "WDMV_ATTRIBUTES" = character(),
  "WSF1" = double(),
  "WSF1_ATTRIBUTES" = character(),
  "WSF2" = double(),
  "WSF2_ATTRIBUTES" = character(),
  "WSF5" = double(),
  "WSF5_ATTRIBUTES" = character(),
  "WSFG" = double(),
  "WSFG_ATTRIBUTES" = character(),
  "WSFI" = double(),
  "WSFI_ATTRIBUTES" = character(),
  "WSFM" = double(),
  "WSFM_ATTRIBUTES" = character()
)

# group source fields by content type for mapping into dataframe
gsoy_int_fields <- c("DATE")
gsoy_float_fields <- c("LATITUDE",
                       "LONGITUDE",
                       "ELEVATION",
                       "AWND",
                       "CDSD",
                       "CLDD",
                       "DP01",
                       "DP10",
                       "DP0X",
                       "DP1X",
                       "DSND",
                       "DSNW",
                       "DT00",
                       "DT32",
                       "DX32",
                       "DX70",
                       "DX90",
                       "EMNT",
                       "EMSD",
                       "EMSN",
                       "EMXP",
                       "EMXT",
                       "EVAP",
                       "FZF0",
                       "FZF1",
                       "FZF2",
                       "FZF3",
                       "FZF4",
                       "FZF5",
                       "FZF6",
                       "FZF7",
                       "FZF8",
                       "FZF9",
                       "HDSD",
                       "HNyz",
                       "HTDD",
                       "HXyz",
                       "LNyz",
                       "LXyz",
                       "MN01",
                       "MNPN",
                       "MNyz",
                       "MX01",
                       "MXPN",
                       "MXyz",
                       "PRCP",
                       "PSUN",
                       "SNOW",
                       "TAVG",
                       "TMAX",
                       "TMIN",
                       "TSUN",
                       "WDF1",
                       "WDF2",
                       "WDF5",
                       "WDFG",
                       "WDFI",
                       "WDFM",
                       "WDMV",
                       "WSF1",
                       "WSF2",
                       "WSF5",
                       "WSFG",
                       "WSFI",
                       "WSFM"
)



# define data conversion functions for column import process from source csv files
col2char <- function(df, col_name) {
  mutate(df, !!col_name := as.character(!!col_name))
}
col2int <- function(df, col_name) {
  mutate(df, !!col_name := as.integer(!!col_name))
}
col2float <- function(df, col_name) {
  mutate(df, !!col_name := as.numeric(!!col_name))
}

# define data read function for source csv files
read_gsoy_data <- function(filename, outfilename, newfile) {
  # create an empty working df based on the gsoy template
  #print(paste("filename: ",filename))
  #print(paste("outfilename: ",outfilename))
  #print(paste("newfile: ",newfile))
  working_df <- gsoy_data_df
  new_df <- read_csv(filename, 
                     col_types = cols(.default = "c"),
                     lazy = FALSE)
  working <- bind_rows(
    mutate_all(working_df, as.character),
    new_df
  )
  starting_rows <- nrow(working)
  working_all <- working %>%
    mutate(DATASET_NAME = filename) %>%
    mutate(CAT = paste(STATION, DATE, LONGITUDE, LATITUDE, sep = "_")) %>%
    filter(!is.na(as.numeric(LATITUDE)) & !is.na(as.numeric(LONGITUDE)))
  working <- working %>%
    mutate(DATASET_NAME = filename) %>%
    mutate(CAT = paste(STATION, DATE, LONGITUDE, LATITUDE, sep = "_")) %>%
    filter(!is.na(as.numeric(LATITUDE)) & !is.na(as.numeric(LONGITUDE)) & as.numeric(DATE) >= startYear & as.numeric(DATE) <= endYear)
  #print(working)
  working_rows <- nrow(working)
  #print(working_rows)
  if(newfile){
    write_csv(working, outfilename, append = FALSE, na = "NA")
    write_csv(working_all, str_replace(outfilename, ".csv", "_all.csv"), append = FALSE, na = "NA")
  }
  else {
    write_csv(working, outfilename, append = TRUE, na = "NA")
    write_csv(working_all, str_replace(outfilename, ".csv", "_all.csv"), append = TRUE, na = "NA")
  }
  remove(working_df, working, working_all)
  returnList <- c(working_rows,starting_rows)
  return(returnList)
}

# import
# only run on a subset of source files if the run is in "test" mode
fileList <- list.files(gsoy_file_path, full.names = TRUE, pattern = "\\.csv")  # read the source directory's contents
if (gsoy_test_run) {
  files <- sample(fileList,size=sampleSize,replace=FALSE)
} else {
  files <- fileList
}

i <- 1
successful <- 0
failed <- 0
totalrecs <- 0
includedrecs <- 0
failed_files <- c()
total_files <-  as.numeric(length(files))
startTime <- now()
tempdir <- paste(projectRoot,"/", "temp/", sep = "")
logFile <- paste(tempdir, "/gsoyLog_", date(startTime), "T", hour(startTime), ":", minute(startTime), ":", second(startTime), ".txt", sep = "")

print("")
print("processing the source gsoy CSV files into a composite file")
progress <- ""
for (filename in files) {
  #print(i)
  skip_to_next <- FALSE
  tryCatch(
    {
      no_recs <- read_gsoy_data(filename=filename, outfilename=outfile_path, newfile=(i == 1))
      #print(paste(no_recs))
      includedrecs <- includedrecs + no_recs[1]
      totalrecs <- totalrecs + no_recs[2]
      #print(paste("[",i,"]",includedrecs, "/",totalrecs))
    },
    error = function(e) {
      skip_to_next <- TRUE
      print(e)
    }
  )
  if(skip_to_next) {
    cat(paste(as.character(i),": ",filename," (FAILED)", sep = ""), file=logFile, fill=TRUE, append=TRUE)
    #progress <- paste(progress,"-",sep="")
    #print(paste(i, "/", total_files,  " (", elapsedTime,"/~", estTotalTime , " min) : Failed  : ", filename, sep=""))
    failed_files <- c(failed_files, filename)
    failed <- failed + 1
    next
  } else {
    cat(paste(as.character(i), ": ",filename," (",as.character(no_recs[1]),"/",as.character(no_recs[2]),")", sep = ""), fill=TRUE, file=logFile, append=TRUE)
    #progress <- paste(progress,"+",sep="")
    #print(paste(i, "/", total_files, " (",  elapsedTime,"/~", estTotalTime , " min) : Success : ", filename, sep=""))
    successful <- successful + 1
  }
  #cat(progress)
  if(i %% 100 == 0) {
    elapsedTime <- round(difftime(now(),startTime,units="mins"), digits=1)
    estTotalTime <- round(elapsedTime / (i/total_files), digits=0)
    print(paste(i, "/", total_files, " (",  elapsedTime,"/~", estTotalTime , " min) ",includedrecs,"/",totalrecs," records, ", failed, " failed files", sep=""))
    progress <- c("")
  }
  i <- i + 1
}

# import gsoy data into GRASS layer
outVect <- "gsoy"

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
          parameters=list(region = "global_5-arc-minute"), 
          echoCmd=TRUE)

execGRASS("v.in.ogr",
          flags=c("overwrite","verbose","o"),
          parameters=list(input=outfile_path,
                          output=outVect,
                          gdal_doo = "X_POSSIBLE_NAMES=LONGITUDE,Y_POSSIBLE_NAMES=LATITUDE",
                          columns = "CAT,DATASET_NAME,STATION,NAME,LATITUDE,LONGITUDE,ELEVATION,DATE,AWND,AWND_ATTRIBUTES,CDSD,CDSD_ATTRIBUTES,CLDD,CLDD_ATTRIBUTES,DP01,DP01_ATTRIBUTES,DP10,DP10_ATTRIBUTES,DP0X,DP0X_ATTRIBUTES,DP1X,DP1X_ATTRIBUTES,DSND,DSND_ATTRIBUTES,DSNW,DSNW_ATTRIBUTES,DT00,DT00_ATTRIBUTES,DT32,DT32_ATTRIBUTES,DX32,DX32_ATTRIBUTES,DX70,DX70_ATTRIBUTES,DX90,DX90_ATTRIBUTES,EMNT,EMNT_ATTRIBUTES,EMSD,EMSD_ATTRIBUTES,EMSN,EMSN_ATTRIBUTES,EMXP,EMXP_ATTRIBUTES,EMXT,EMXT_ATTRIBUTES,EVAP,EVAP_ATTRIBUTES,FZF0,FZF0_ATTRIBUTES,FZF1,FZF1_ATTRIBUTES,FZF2,FZF2_ATTRIBUTES,FZF3,FZF3_ATTRIBUTES,FZF4,FZF4_ATTRIBUTES,FZF5,FZF5_ATTRIBUTES,FZF6,FZF6_ATTRIBUTES,FZF7,FZF7_ATTRIBUTES,FZF8,FZF8_ATTRIBUTES,FZF9,FZF9_ATTRIBUTES,HDSD,HDSD_ATTRIBUTES,HNyz,HNyz_ATTRIBUTES,HTDD,HTDD_ATTRIBUTES,HXyz,HXyq_ATTRIBUTES,LNyz,LNyz_ATTRIBUTES,LXyz,LXyz_ATTRIBUTES,MN01,MN01_ATTRIBUTES,MNPN,MNPN_ATTRIBUTES,MNyz,MNyz_ATTRIBUTES,MX01,MX01_ATTRIBUTES,MXPN,MXPN_ATTRIBUTES,MXyz,MXyz_ATTRIBUTES,PRCP,PRCP_ATTRIBUTES,PSUN,PSUN_ATTRIBUTES,SNOW,SNOW_ATTRIBUTES,TAVG,TAVG_ATTRIBUTES,TMAX,TMAX_ATTRIBUTES,TMIN,TMIN_ATTRIBUTES,TSUN,TSUN_ATTRIBUTES,WDF1,WDF1_ATTRIBUTES,WDF2,WDF2_ATTRIBUTES,WDF5,WDF5_ATTRIBUTES,WDFG,WDFG_ATTRIBUTES,WDFI,WDFI_ATTRIBUTES,WDFM,WDFM_ATTRIBUTES,WDMV,WDMV_ATTRIBUTES,WSF1,WSF1_ATTRIBUTES,WSF2,WSF2_ATTRIBUTES,WSF5,WSF5_ATTRIBUTES,WSFG,WSFG_ATTRIBUTES,WSFI,WSFI_ATTRIBUTES,WSFM,WSFM_ATTRIBUTES,CATEGORY",
                          type = "point"),
          echoCmd=TRUE
)
execGRASS("v.info",
          flags=c("verbose"),
          parameters=list(map=outVect),
          echoCmd=TRUE
)

ps_preview(title=paste("Imported weather station locations for years",startYear, "-", endYear),
           raster="bmng.rgb",
           vPoints=c("languages",outVect),
           vPoints_colors=c("red","cyan"))

execGRASS("v.extract",
          flags=c("verbose","overwrite"),
          parameters=list(input="gsoy",
                          type="point",
                          where="TAVG IS NOT NULL",
                          output="gsoy_tavg"),
          echoCmd=TRUE
)
execGRASS("v.extract",
          flags=c("verbose","overwrite"),
          parameters=list(input="gsoy",
                          type="point",
                          where="TMIN IS NOT NULL",
                          output="gsoy_tmin"),
          echoCmd=TRUE
)
execGRASS("v.extract",
          flags=c("verbose","overwrite"),
          parameters=list(input="gsoy",
                          type="point",
                          where="TMAX IS NOT NULL",
                          output="gsoy_tmax"),
          echoCmd=TRUE
)
execGRASS("v.extract",
          flags=c("verbose","overwrite"),
          parameters=list(input="gsoy",
                          type="point",
                          where="PRCP IS NOT NULL",
                          output="gsoy_prcp"),
          echoCmd=TRUE
)




unlink_.gislock

