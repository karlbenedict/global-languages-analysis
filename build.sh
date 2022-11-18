#!/usr/bin/env bash

# Pull the most recent version of the GRASS repository (as a git submodule)
# and build/rebuild the target version of GRASS as a new docker container. The
# GRASS submodule is named "grass_submodule" in the root of this repository. 
# OSGEO release commits and corresponding kbene/grass repository branches:
#		8.2.0: cafd69c057b59fe3e47cf7711701f653385c919c 8.2.0_production
git submodule update --remote
echo
echo "Building the GRASS container"
cd grass_submodule
git checkout 8.2.0_production
git status
cd ..
docker build \
	--file grass_submodule/docker/ubuntu/Dockerfile \
	--tag grass-py3-pdal:stable-ubuntu .
	
# build production Docker container from base GRASS image created above,
# rocker/geospatial, and add additional R packages
docker build \
	--file Dockerfile \
	--tag  kbene/rocker-grass:v0.1 .
	

