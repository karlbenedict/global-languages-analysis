# 01_setup_grass_locations.R

# execute the shared setup file
source("scripts/00_include.R")

##### Location: 4326 ##########################################################
try(system("rm -rf grassdata/temp"))
location <- "temp"
mapset <- "PERMANENT"

initGRASS(
  gisBase = gisBase,
  home = projectRoot, #tempdir(),  #tempDatedFolder(projectRoot),
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

# create the location if it doesn't already exist
try(execGRASS("g.proj", 
              flags=c("c"), 
              parameters=list(location="4326",
                              wkt="scripts/epsg4326.prj"),
              echoCmd=TRUE))

location <- "4326"
mapset <- "PERMANENT"

initGRASS(
  gisBase = gisBase,
  home = projectRoot, #tempdir(),  #tempDatedFolder(projectRoot),
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

# define global_30-arc-second region in 4326 ##################################
command <-  "g.region"
params  <-  list(n = "90",
                 s = "-90",
                 e = "180",
                 w = "-180",
                 res = "0.008333333333",
                 save = "global_30-arc-second")
flags  <-  c("overwrite","verbose","s")
print("creating region")
execGRASS(command, flags=flags, parameters=params, echoCmd=TRUE)
print("changing into region")
stringexecGRASS("g.region region=global_30-arc-second")
print("region settings")
stringexecGRASS("g.region -p")

# create reference vector for full extent of global_30-arc-second region
# for use in creating default regions in other locations
execGRASS("v.in.region",
          flags=c("d", "overwrite"),
          parameters=list(output="bounds4326", 
                          type="area"))


# define global_5-arc-minute region in 4326 ##################################
command <-  "g.region"
params  <-  list(n = "90",
                 s = "-90",
                 e = "180",
                 w = "-180",
                 res = "0.08333333333",
                 save = "global_5-arc-minute")
flags  <-  c("overwrite","verbose")
print("creating region")
execGRASS(command, flags=flags, parameters=params, echoCmd=TRUE)
print("changing into region")
stringexecGRASS("g.region region=global_5-arc-minute")
print("region settings")
stringexecGRASS("g.region -p")

###############################################################################

##### World Sinusoidal ########################################################
location <- "4326" # use the existing 4325 location to prevent premature creation of incomplete mollweide location
mapset <- "PERMANENT"

initGRASS(
  gisBase = gisBase,
  home = projectRoot, #tempdir(),  #tempDatedFolder(projectRoot),
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

try(execGRASS("g.proj", 
              flags=c("c"), 
              parameters=list(location="world_sinusoidal",
                              wkt="scripts/world_sinusoidal.prj"),
              echoCmd=TRUE))

location <- "world_sinusoidal"
mapset <- "PERMANENT"

initGRASS(
  gisBase = gisBase,
  home = projectRoot, #tempdir(),  #tempDatedFolder(projectRoot),
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

execGRASS("v.proj",
          flags=c("overwrite"),
          parameters=list(input="bounds4326", 
                          location="4326"))
execGRASS("g.region",
          flags=c("a","s","overwrite"),
          parameters=list(vector="bounds4326",
                          res="10000",
                          save = "ws_global_10km"))
execGRASS("g.region",
          flags=c("p"))

print("changing into region")
stringexecGRASS("g.region region=ws_global_10km")
print("region settings")
stringexecGRASS("g.region -p")

###############################################################################

##### Mollweide ###############################################################
location <- "4326" # use the existing 4325 location to prevent premature creation of incomplete mollweide location
mapset <- "PERMANENT"

initGRASS(
  gisBase = gisBase,
  home = projectRoot, #tempdir(),  #tempDatedFolder(projectRoot),
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

try(execGRASS("g.proj", 
          flags=c("c"), 
          parameters=list(location="mollweide",
                          wkt="scripts/mollweide.prj"),
          echoCmd=TRUE))

location <- "mollweide"
mapset <- "PERMANENT"

initGRASS(
  gisBase = gisBase,
  home = projectRoot, #tempdir(),  #tempDatedFolder(projectRoot),
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

execGRASS("v.proj",
          flags=c("overwrite"),
          parameters=list(input="bounds4326", 
                          location="4326"))
execGRASS("g.region",
          flags=c("a","s","overwrite"),
          parameters=list(vector="bounds4326",
                          res="10000",
                          save = "moll_global_10km"))
execGRASS("g.region",
          flags=c("p"))

print("changing into region")
stringexecGRASS("g.region region=moll_global_10km")
print("region settings")
stringexecGRASS("g.region -p")
###############################################################################

##### ACE2 ####################################################################
location <- "4326"
mapset <- "PERMANENT"

initGRASS(
  gisBase = gisBase,
  home = projectRoot, #tempdir(),  #tempDatedFolder(projectRoot),
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

# create the location if it doesn't already exist
try(execGRASS("g.proj", 
          flags=c("c"), 
          parameters=list(location="ace2",
                          wkt="scripts/world_equidistant_cylindrical.prj"),
          echoCmd=TRUE))


location <- "ace2"
mapset <- "PERMANENT"

initGRASS(
  gisBase = gisBase,
  home = projectRoot, #tempdir(),  #tempDatedFolder(projectRoot),
  gisDbase = gisDBase,
  location = location,
  mapset = mapset,
  override = TRUE
)

execGRASS("v.proj",
          flags=c("overwrite"),
          parameters=list(input="bounds4326", 
                          location="4326"))
execGRASS("g.region",
          flags=c("s","overwrite"),
          parameters=list(vector="bounds4326",
                          res="1",
                          save = "ace2_30-arc-second"))
print("changing into region")
stringexecGRASS("g.region region=ace2_30-arc-second")
print("region settings")
stringexecGRASS("g.region -p")
###############################################################################




unlink_.gislock
