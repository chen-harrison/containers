#!/usr/bin/env bash

check_help() {
    if [[ $# -eq 1 && ($1 == "-h" || $1 == "--help") ]] ; then
        return
    fi
    return 1
}

# Show usage if called incorrectly
if [[ $# -eq 0  || $# -gt 3 ]] || check_help "$@" ; then
    echo "Usage: $(basename "$0") [--ci] BASE_IMAGE[:TAG] [OUTPUT_IMAGE[:TAG]]"
    echo "Build a dev container."
    exit 0
fi

# Use different user information, depending on if it's a CI or local run
if [[ $1 == '--ci' ]] ; then
    shift 1
    BASE_IMAGE=$1
    OUTPUT_IMAGE=${2:-local:latest}
    USER_UID=1000
    USER_GID=1000
    USERNAME=$(docker run --rm --entrypoint bash -u "$USER_UID" "$BASE_IMAGE" -c "whoami 2> /dev/null") || USERNAME="user"
else
    # Use the UID, GID, and username of the current user
    BASE_IMAGE=$1
    OUTPUT_IMAGE=${2:-local:latest}
    USER_UID=$(id -u)
    USER_GID=$(id -g)
    USERNAME=$(docker run --rm --entrypoint bash -u "$USER_UID" "$BASE_IMAGE" -c "whoami 2> /dev/null") || USERNAME=$(whoami)
fi

echo $BASE_IMAGE
echo $OUTPUT_IMAGE
echo $USER_UID
echo $USER_GID

docker build \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg USERNAME=$USERNAME \
    --build-arg USER_UID=$USER_UID \
    --build-arg USER_GID=$USER_GID \
    -f "$(dirname $0)/Dockerfile" \
    -t "${OUTPUT_IMAGE}" \
    "$(dirname $0)"
