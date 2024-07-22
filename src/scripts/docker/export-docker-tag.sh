#!/usr/bin/env bash

set -e

readonly MAIN_BRANCH=${MAIN_BRANCH:-master}

# Take current branch if BRANCH is not set
if [ -z "$BRANCH" ]; then
    BRANCH=$(git branch --show-current)
fi
_tag=
if [ "$BRANCH" = "develop" ]; then
    _tag="latest-beta"
elif [[ "$BRANCH" == release/* ]]; then
    _tag="latest-rc"
elif [ "$BRANCH" = "$MAIN_BRANCH" ]; then
    _tag="latest"
else
    echo "Could not determine the latest tag"
    exit 1
fi

echo "export LATEST_DOCKER_TAG=$_tag" >> "$BASH_ENV"