#! /bin/bash

SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd -P)
source "$SCRIPT_FOLDER/../.env"

groupadd -g $NAS_GID nas
useradd -r -u $NAS_UID -g nas -m nas