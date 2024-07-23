#!/usr/bin/env bash

set -e

_tag=
if [[ $CIRCLE_TAG == *-rc* ]]; then
  _tag="latest-rc"
elif [[ $CIRCLE_TAG == *-beta* ]]; then
  _tag="latest-beta"
elif [[ $CIRCLE_TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  _tag="latest"
else
  echo "Could not determine the latest tag for CIRCLE_TAG $CIRCLE_TAG"
  exit 1
fi

echo "export LATEST_DOCKER_TAG=$_tag" >> "$BASH_ENV"