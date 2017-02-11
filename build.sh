#!/bin/bash

RM_VERSION=`cat ./RM_VERSION`
ALM_VERSION=`cat ./ALM_VERSION`

sed -e "s/{{RM_VER}}/${RM_VERSION}/" \
    -e "s/{{ALM_VER}}/${ALM_VERSION}/" \
    Dockerfile.templ > Dockerfile

sudo docker build -t ayapapa/docker-alminium:${ALM_VERSION} .
