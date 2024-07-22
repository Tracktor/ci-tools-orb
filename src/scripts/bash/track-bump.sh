#!/usr/bin/env bash

set -xe

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

_BRANCH=$BRANCH
# shellcheck disable=SC2153
if [ -z "$BRANCH" ]; then
  _BRANCH=$(git branch --show-current)
fi

cmd="pipx run track-bump"
[ -n "$_VERBOSE" ] && cmd+=" $_VERBOSE"
cmd+=" bump --branch $_BRANCH"
[ -n "$_flags" ] && cmd+=" $_flags"
[ -n "$CUSTOM_PARAMS" ] && cmd+=" $CUSTOM_PARAMS"

# Execute the command
eval "$cmd"

if [ "$_DRY_RUN" = "false" ]; then
  git push origin "$_BRANCH" --follow-tags
  gh release create -F CHANGELOG.md "$TAG"
else
  echo "Dry run, not pushing (branch: $BRANCH, version: $TAG)"
fi
