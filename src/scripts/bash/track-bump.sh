#!/usr/bin/env bash

set -xe

_DRY_RUN="false"
# shellcheck disable=SC2153
if [ "$DRY_RUN" -eq "1" ]; then
  _DRY_RUN="true"
fi

_VERBOSE=""
# shellcheck disable=SC2153
if [ "$VERBOSE" -eq "1" ]; then
  _VERBOSE="-vv"
fi

_flags=""
# shellcheck disable=SC2153
if [ "$SIGN_COMMIT" -eq "1" ]; then
  _flags="--sign"
fi

_BRANCH=""
# shellcheck disable=SC2153
if [ -z "$BRANCH" ]; then
  _BRANCH=$(git branch --show-current)
fi

pipx run track-bump "$_VERBOSE" bump --branch "$_BRANCH" "$_flags" "$CUSTOM_PARAMS"

if [ "$_DRY_RUN" = "false" ]; then
  git push origin "$_BRANCH" --follow-tags
  gh release create -F CHANGELOG.md "$TAG"
else
  echo "Dry run, not pushing (branch: $BRANCH, version: $TAG)"
fi
