#!/usr/bin/env bash

# usage: start.sh

# If this script is run when the rocker-grass has been stopped, but not
# removed it will restart it in the current state as when it was stopped. 
# If the script is run after the rocker-grass container has been stopped AND
# removed, an new container named rocker-grass will be created and will not
# contain any of the modifications that might have been made to the previously
# removed rocker-grass container. 

echo "starting rocker-grass container"
docker start rocker-grass 2>/dev/null|| \
docker run -d \
	-p 8787:8787 \
	-e PASSWORD=fi1Aim2uing7guth \
	-v $(pwd)/source_data:/home/rstudio/data/source_data \
		--name=rocker-grass \
	kbene/rocker-grass:v0.1

