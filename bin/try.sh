#!/bin/bash

#script for testing - copies docker-server root and executes setup.sh of the copy
#place .env file below docker-server root

THIS="$( readlink -f "${BASH_SOURCE[0]}" )"
THISDIR="$(dirname "$THIS")"

SRC=$THISDIR/..

cd $SRC/..

if [ ! -f .env ] ; then
  echo "ERROR $(pwd)/.env not found"
  exit 1
fi

#copy files  
rm -rf try
cp -rp $SRC try
cp .env try

# Delete all Docker containers and images - Note: error when none exist
docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)

#start setup
cd try
./setup.sh

