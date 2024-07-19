#!/usr/bin/env bash

set -e

readonly MAIN_BRANCH=${MAIN_BRANCH:-master}

_branch=$(git branch --show-current)
_tag=
if [ "$_branch" = "develop" ]; then
    _tag="latest-beta"
elif [[ "$_branch" == release/* ]]; then
    _tag="latest-rc"
elif [ "$_branch" = "$MAIN_BRANCH" ]; then
    _tag="latest"
else
    echo "Could not determine the latest tag"
    exit 1
fi
export LATEST_DOCKER_TAG=$_tag  >> "$BASH_ENV"