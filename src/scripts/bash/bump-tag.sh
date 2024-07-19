#!/bin/bash

# DESCRIPTION:
#   Create a new tag based on the current branch.
#   If the current release tag is v0.1.0 and the current branch is:
#    - develop: it will create a beta tag (v0.2.0-beta.0).
#               It will increment the beta number if a beta tag already exists, otherwise it will start from 0.
#    - $MAIN_BRANCH: it will create a release tag (v0.2.0).
#
#  If AUTO_TAG is set to true, it will create the tag automatically.
# Usage: ./bin/get-tag.sh

set -e

readonly MAIN_BRANCH=${MAIN_BRANCH:-master}
readonly AUTO_TAG=${AUTO_TAG:-"true"}

# Get latest  release tag
# --sort : https://git-scm.com/docs/git-tag#Documentation/git-tag.txt---sortltkeygt

function get_tag(){
  git tag --sort=-version:refname | grep -E "$1" | head -n 1
}

_latest_release_tag=$(get_tag "v[0-9]\.[0-9]\.[0-9]$")
if [ -z "$_latest_release_tag" ]; then
    echo "No release tags found. Please create a release tag first (like v0.1.0)"
    exit 1
fi
echo "Latest release tag: $_latest_release_tag"

_next_release_tag=$(echo "$_latest_release_tag" | awk -F'.' '{print $1"."$2+1".0"}')


function get_next_inc_tag(){
    _release_name=$1
    local _tag
    _tag=$(get_tag "${_next_release_tag}-${_release_name}\.[0-9]*")
    if [ -z "$_tag" ]; then
        _next_tag="$_next_release_tag-$_release_name.0"
    else
        _next_tag=$(echo "$_tag" | awk -v rn="$_release_name" -F "-$_release_name." '{print $1"-"rn"."$2+1}')
    fi
    echo "$_next_tag"
}

_branch=$(git branch --show-current)
#echo "Current branch $_branch"
if [ "$_branch" = "develop" ]; then
    _next_beta_tag=$(get_next_inc_tag "beta")
#    echo "New beta tag: $_next_beta_tag"
    if [ "$AUTO_TAG" = "true" ]; then
        git tag "$_next_beta_tag"
    fi
elif [ "$_branch" = "$MAIN_BRANCH" ]; then
#    echo "New main tag: $_next_release_tag"
    if [ "$AUTO_TAG" = "true" ]; then
        git tag "$_next_release_tag"
    fi
else
    echo "No tag to create"
fi
