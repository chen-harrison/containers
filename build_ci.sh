#!/usr/bin/env bash

# Default to UID = 1000, username = user
BASE_IMAGE=$1
OUTPUT_IMAGE=$2
USER_UID=1000
USER_GID=1000
USERNAME=$(docker run --rm -u "$USER_UID" "$BASE_IMAGE" whoami 2> /dev/null) || USERNAME="user"

docker build \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg USERNAME=$USERNAME \
    --build-arg USER_UID=$USER_UID \
    --build-arg USER_GID=$USER_GID \
    --no-cache \
    --pull \
    -f "$(dirname $0)/Dockerfile" \
    -t "${OUTPUT_IMAGE}" \
    "$(dirname $0)"