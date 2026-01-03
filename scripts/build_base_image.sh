#! /bin/bash

SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd -P)
source "$SCRIPT_FOLDER/../.env"

cd "$SCRIPT_FOLDER/../images/debian/"
docker build -t "$DOCKER_REPO:base" .
cd -