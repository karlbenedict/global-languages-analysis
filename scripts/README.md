# Scripts folder README.md file

This folder contains data management, processing, analysis, and visualization scripts in addition to supporting files used by those scripts. The names of the scripts that their high-level purpose are as follows:

* `00_include.R`: provides shared environment settings and functions that are reused across multiple scripts in the collection. This script is imported into others to provide a common operating environment across processing, analytic, and visualization scripts.
* `01-setup_grass_locations.R`: creates the core GRASS GIS locations used for storing and accessing imported GIS data. 
* `02_01_import_BMNG.R`: imports the Blue Marble Next Generation global satellite imagery into the analytic environment. (NASA Earth Observatory (2005). Blue Marble Next Generation. Available at: https://earthobservatory.nasa.gov/features/BlueMarble [Accessed March 5, 2023])
* `02_02_import_ipums.R`: imports the IPUMS global international boundary dataset. (Minnesota Population Center (2013). Integrated Public Use Microdata Series, International: Version 6.2 [Machine-readable database]. Available at: https://international.ipums.org/international/gis.shtml)
* `02_06_import_gsoy.R`: imports the Global Summary of the Year global meteorological station data. (Lawrimore, J., Ray, R., Applequist, S., Korzeniewski, B., and Menne, M. J. (2016). Global Summary of the Year (GSOY), Version 1. doi: 10.7289/JWPF-Y430)
* `02_07_import_gfw_biomass.R`: imports the Global Forest Watch global biomass data. (Global Forest Watch (2022). Aboveground LIve Woody Bomass Density. Aboveground LIve Woody Bomass Density. Available at: https://data.globalforestwatch.org/maps/e4bdbe8d6d8d4e32ace7d36a4aec7b93 [Accessed November 20, 2022])
* `02_08_import_ace2.R`: imports the global Altimeter Corrected Elevation model. (Berry, P. A. M., Smith, R., and Benveniste, J. (2010). ACE2: The New Global Digital Elevation Model. Berlin, Heidelberg: Springer Available at: https://doi.org/10.1007/978-3-642-10634-7_30; Berry, P. A. M., Smith, R., and Benveniste, J. (2019). Altimeter Corrected Elevations, Version 2 (ACE2). Available at: https://doi.org/10.7927/H40G3H78 [Accessed December 9, 2022].)
* `03_01_vis_rasters.R`: generates general-purpose visualizations of the imported datasets for basic QA/QC and interpretive assessment. 
* `04_01_extract_env-vlanguages.R`: summarizes the above imported environmental datasets and exports a combined CSV file that includes the summary environmental data and the language characteristics associated with each language in the dataset. 
* `05_01_analysis_distributions_corr.R`: generates histogram, column charts, and correlograms for the language and environmental parameters in the analysis environment. 
* `05_02_analysis_globalmaps.R`: generates high-resolution postscript maps of environmental variables combined with language locations. 
* `05_03_analysis_gsoy_distributions.R`: generates summary distributions of meteorological measurements through time for the Global Summary of the Year dataset. 
* `05_04_analysis_global_climate_change.R`: retrieves externally hosted global terrestrial temperature anomaly data from 1850-present and generates plots showing the trends in those data through time.
* `05_05_analysis_global_parameter_distribution.R`: performs an analysis of the similarity between the distributions of global terrestrial environmental characteristics for a random set of global points compared to the distributions of those characteristics for the language sample locations. 
* `99_01_analysis_2023_Frontiers_Additional_Plots.R`: generates additional specialized data analyses and visualizations in support of the Frontiers in Psychology 2023 paper submission. 

The additional `.prj` and `.txt` files in this folder are support files referenced by the above scripts as part of their processing workflows. 
