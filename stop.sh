#!/usr/bin/env bash

# usage: stop.sh

# This script will stop a running rocker-grass container, but it may be
# restarted by running the start.sh script and it's state when stopped will
# be restored. 

docker stop rocker-grass