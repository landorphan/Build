#!/usr/bin/env bash

echo "Running Build"

INPT=$(cat "$AGENT_BUILDDIRECTORY/info/projects.map")
HEADER=$(echo "$INPT" | grep "^:")
BASE_MAP=$(echo "$INPT" | grep "|0>")

BUILD_GROUPS=$(echo "$BASE_MAP" | sed -n -E 's/\|0>([^<]*)<.*/\1/p')

IFS=$'\n'
MAX_GROUP=$(echo "${BUILD_GROUPS[*]}" | sort -nr | head -n1)

echo "Found $MAX_GROUP build groups"