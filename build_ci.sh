#!/usr/bin/env bash

check_help() {
    if [[ $# -eq 1 && ($1 == "-h" || $1 == "--help") ]] ; then
        return
    fi
    return 1
}

if [[ $# -ne 2 ]] || check_help "$@" ; then
    echo "Usage: $(basename "$0") BASE_IMAGE[:TAG] OUTPUT_IMAGE[:TAG]"
    echo "Build a dev container."
    exit 0
fi

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