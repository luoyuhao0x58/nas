#! /bin/bash

export DEBIAN_FRONTEND=noninteractive
SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd -P)

cd "$SCRIPT_FOLDER/../"

docker compose config | sed -n '/^volumes:/,$p' | grep device | cut -d":" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//' | while read -r path; do
    mkdir -p "$path"
done