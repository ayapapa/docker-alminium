#!/bin/bash

RM_VERSION=$(cat ./RM_VERSION)
ALM_VERSION=$(cat ./ALM_VERSION)
DOCKER_ALM_REV=$(cat ./DOCKER_ALM_REV)
if [ ! "${DOCKER_ALM_REV}" = "" ]; then
  DOCKER_ALM_REV=.${DOCKER_ALM_REV}
fi
DOCKER_ALM_VER=$(cat ./ALM_VERSION | sed "s/^[vV]//")${DOCKER_ALM_REV}

echo start to build docker-alminium
echo "  Redmine Ver.  = ${RM_VERSION}"
echo "  ALMinium Ver. = ${ALM_VERSION}"
echo "  docker-alminium Ver. = ${DOCKER_ALM_VER}"

sed -e "s/{{RM_VER}}/${RM_VERSION}/" \
    -e "s/{{ALM_VER}}/${ALM_VERSION}/" \
    Dockerfile.templ > Dockerfile

sudo docker build -t ayapapa/docker-alminium:${DOCKER_ALM_VER} .

sed -i.org \
    "s|ayapapa/docker-alminium:.*|ayapapa/docker-alminium:${DOCKER_ALM_VER}|" \
    docker-compose.yml
