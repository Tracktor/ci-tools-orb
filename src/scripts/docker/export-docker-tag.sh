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
  if [ "$FAIL_NO_TAG" -eq "1" ]; then
    exit 1
  fi
fi

echo "export LATEST_DOCKER_TAG=$_tag" >> "$BASH_ENV"