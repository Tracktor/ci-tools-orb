#!/usr/bin/env bash

set -xe

export MAIN_BRANCH=${DEFAULT_BRANCH}

_DRY_RUN="false"
# shellcheck disable=SC2153
if [ "$DRY_RUN" -eq "1" ]; then
  _DRY_RUN="true"
fi

_VERBOSE=
# shellcheck disable=SC2153
if [ "$VERBOSE" -eq "1" ]; then
  _VERBOSE="-vv"
fi

_flags=
# shellcheck disable=SC2153
if [ "$SIGN_COMMIT" -eq "1" ]; then
  _flags="--sign"
fi

_branch="$BRANCH"
if [ -z "$_branch" ]; then
  _branch=$(git branch --show-current)
fi

cmd="pipx run track-bump"
[ -n "$_VERBOSE" ] && cmd+=" $_VERBOSE"
cmd+=" bump --branch $_branch"
[ -n "$_flags" ] && cmd+=" $_flags"
[ -n "$CUSTOM_PARAMS" ] && cmd+=" $CUSTOM_PARAMS"

# Execute the command
eval "$cmd"

TAG=$(git tag -l --sort=-version:refname  | head -n 1)

if [ "$_DRY_RUN" = "false" ]; then
  echo "Pushing branch $_branch and tag $TAG"
  git push origin "$_branch" --follow-tags
  echo "Creating Github release $TAG"
  gh release create -F CHANGELOG.md "$TAG"
else
  echo "Dry run, not pushing (branch: $_branch, version: $TAG)"
fi
