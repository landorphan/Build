#!/usr/bin/env bash

echo "Running Build"

INPT=$(cat "$AGENT_BUILDDIRECTORY/info/projects.map")
#INPT=$(cat "/tmp/projects.map")
HEADER=$(echo "$INPT" | grep "^:")
BASE_MAP=$(echo "$INPT" | grep "|0>")

BUILD_GROUPS=$(echo "$BASE_MAP" | sed -n -E 's/\|0>([^<]*)<.*/\1/p')

IFS=$'\n'
MAX_GROUP=$(echo "${BUILD_GROUPS[*]}" | sort -nr | head -n1)

echo "Found $MAX_GROUP build groups"


function RestoreProject() {
    dotnet restore --no-dependencies "$0"
}

export -f RestoreProject

# Restore all packages
for (( i=0; i<=$MAX_GROUP; i++))
do
    echo "$BASE_MAP" | grep "|0>$i<0|" | sed -n -E 's/.*\|6>([^<]*)<6.*/\1/p' | xargs -I % bash -c RestoreProject '%'
done

function BuildGroup() {
    #   --runtime ubuntu.18.04-x64
    BUILD_ITEMS=($(echo "$BASE_MAP" | grep "|0>$1<0|"))
    echo "Building Group $1"

    i=0
    pids=()
    BUILD_VERSION=0.9.0
    for line in "${BUILD_ITEMS[@]}"; do
        PROJ_FILE=$(echo $line | sed -n -E 's/.*\|6>([^<]*)<6.*/\1/p')
        dotnet build --no-dependencies --no-restore -p:Version="$BUILD_VERSION" --configuration:Release "$PROJ_FILE" #&
        # PIDS[${i}]=$!
        # echo "Building $i $PROJ_FILE"
        # let 'i++'
    done

    # for pid in ${pids[*]}; do
    #     wait $pid
    # done
    # PROJ_FILE=$(echo $0 | sed -n -E 's/.*\|6>([^<]*)<6.*/\1/p')
    # BUILD_VERSION=$(cat /tmp/build.ver)
    # echo "Building ($PROJ_FILE) version: $BUILD_VERSION"
    # dotnet build --no-dependencies --no-restore -p:Version="$BUILD_VERSION" --configuration:Release --source "$PROJ_FILE"
}

# export -f BuildGroup

for (( i=0; i<=$MAX_GROUP; i++))
do
    BuildGroup $i
done