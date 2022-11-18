FROM rocker-geospatial:4.2.2 AS rocker-geospatial
RUN echo "rocker-geospatial complete"

# progressive build of rocker-geospatial layer components based on collection
# of version 4.2.2 Dockerfiles located in the rocker_submodule/dockerfiles
# directory. 

# shared header content from all Dockerfiles
LABEL org.opencontainers.image.licenses="GPL-2.0-or-later" \
org.opencontainers.image.source="https://github.com/rocker-org/rocker-versioned2" \
org.opencontainers.image.vendor="Rocker Project" \
org.opencontainers.image.authors="Carl Boettiger <cboettig@ropensci.org>"

##### r-ver_4.2.2 #############################################################
ENV R_VERSION=4.2.2
ENV R_HOME=/usr/local/lib/R
ENV TZ=Etc/UTC

COPY rocker_submodule/scripts/install_R_source.sh /rocker_scripts/install_R_source.sh

RUN /rocker_scripts/install_R_source.sh

ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/jammy/latest
ENV LANG=en_US.UTF-8

COPY rocker_submodule/scripts /rocker_scripts

RUN /rocker_scripts/setup_R.sh

# CMD ["R"]
###############################################################################

##### rstudio_4.2.2 ###########################################################
ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2022.07.2+576
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=default
ENV QUARTO_VERSION=default

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_quarto.sh

EXPOSE 8787
###############################################################################

##### tidyverse_4.2.2 #########################################################
RUN /rocker_scripts/install_tidyverse.sh
###############################################################################

##### verse_4.2.2 #############################################################
ENV CTAN_REPO=https://mirror.ctan.org/systems/texlive/tlnet
ENV PATH=$PATH:/usr/local/texlive/bin/linux

RUN /rocker_scripts/install_verse.sh
###############################################################################

##### geospatial_4.2.2 ########################################################
RUN /rocker_scripts/install_geospatial.sh
###############################################################################

# install additional needed R modules
RUN install2.r --error --skipmissing --skipinstalled \
	ecodist \
	readxl \
	tools \
	rgrass \
	gdalUtilities


ENV PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/texlive/bin/linux

RUN mkdir -p /home/rstudio/data/scripts
RUN mkdir -p /home/rstudio/data/output/data
RUN mkdir /home/rstudio/data/output/images
RUN mkdir /home/rstudio/data/grassdata
RUN mkdir /home/rstudio/data/data_processed
COPY scripts /home/rstudio/data/scripts
RUN chown -R rstudio /home/rstudio/data


VOLUME /home/rstudio/data

CMD ["/init"]












	
