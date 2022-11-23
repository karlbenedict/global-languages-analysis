FROM rocker/geospatial:4.2.2-ubuntugis

RUN apt-get update && apt-get upgrade -y && \
apt-get install -y --no-install-recommends --no-install-suggests \
	grass
	
## install additional needed R modules
RUN install2.r --error --skipmissing --skipinstalled \
	ecodist \
	readxl \
	tools \
	rgrass \
	gdalUtilities

RUN git clone https://github.com/karlbenedict/global-languages-analysis.git /home/rstudio/global-languages-analysis
#RUN mkdir -p /home/rstudio/data/scripts
RUN mkdir -p /home/rstudio/data/output/data
RUN mkdir /home/rstudio/data/output/images
RUN mkdir /home/rstudio/data/grassdata
RUN mkdir /home/rstudio/data/temp
#RUN mkdir /home/rstudio/data/data_processed
#COPY scripts /home/rstudio/data/scripts
RUN chown -R rstudio /home/rstudio/global-languages-analysis

VOLUME /home/rstudio/global-languages-analysis













	
