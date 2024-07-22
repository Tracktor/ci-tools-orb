#!/usr/bin/env bash

set -e

readonly DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}

_branch="$BRANCH"
if [ -z "$_branch" ]; then
    _branch=$(git branch --show-current)
fi

_tag=
if [ "$_branch" = "develop" ]; then
    _tag="latest-beta"
elif [[ "$_branch" == release/* ]]; then
    _tag="latest-rc"
elif [ "$_branch" = "$DEFAULT_BRANCH" ]; then
    _tag="latest"
else
    echo "Could not determine the latest tag for branch $_branch"
    exit 1
fi

echo "export LATEST_DOCKER_TAG=$_tag" >> "$BASH_ENV"