This repository contains the file structure, analytic code, and scripts for
building the needed Docker container, retrieving required source data, and
executing the analyses associated with the Global Linguistics project. 

The [GRASS GIS source code](https://github.com/karlbenedict/grass.git) is 
included as a submodule within this repository (`grass_submodule`) to enable building the base GRASS 
GIS container from a specific target release of the GIS environment. 

The [rocker-org/rocker-versioned2 repository](https://github.com/karlbenedict/rocker-versioned2.git) 
is also included as a submodule (`rocker-submodule`) for for building the Rstudio-geospatial 
container components that are used in the analysis. 


**After cloning this repository into a new environment
the submodules must be initialized and updated by executing the following 
commands**:

	git submodule init
	git submodule update



