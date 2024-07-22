#!/usr/bin/env bash

set -e

readonly DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}

_branch="$BRANCH"
if [ -z "$_branch" ]; then
  # Source: https://discuss.circleci.com/t/circle-branch-and-pipeline-git-branch-are-empty/44317/3
  # determine branch from tag using commit ID.
  # Note: "git branch -a --contains <tag>" could return multiple entries
  #       however, since the pipeline runs right after the tag is commited
  #       this should not become an issue
  _commit=$(git show-ref | grep "${CIRCLE_TAG}" | awk '{print $1}')
  _tmp=$(git branch -a --contains "$_commit")
  _branch="${_tmp##*/}"
fi

echo "Branch: $_branch"

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