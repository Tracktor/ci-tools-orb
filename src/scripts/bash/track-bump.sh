#!/usr/bin/env bash

set -e

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

_CREATE_RELEASE="false"
if [ "$_branch" = "$DEFAULT_BRANCH" ]; then
  _CREATE_RELEASE="true"
fi

cmd="pipx run track-bump"
[ -n "$_VERBOSE" ] && cmd+=" $_VERBOSE"
cmd+=" bump --branch $_branch"
[ -n "$_flags" ] && cmd+=" $_flags"
[ -n "$CUSTOM_PARAMS" ] && cmd+=" $CUSTOM_PARAMS"

# Execute the command
eval "$cmd"

if [ "$_CREATE_RELEASE" = "true" ]; then
  echo "Generating CHANGELOG"
  pipx run git-cliff -o CHANGELOG.md --latest
  sed -i '$ d' CHANGELOG.md
  git add CHANGELOG.md
  git commit --amend --no-edit
else
  echo "Not generating CHANGELOG"
fi

TAG=$(pipx run track-bump get-latest-tag --branch "$_branch")

if [ "$_DRY_RUN" = "false" ]; then
  echo "Pushing branch $_branch and tag $TAG"
  git push origin "$_branch" --follow-tags
  if [ "$_CREATE_RELEASE" = "true" ]; then
    echo "Creating Github release $TAG"
    gh release create -F CHANGELOG.md "$TAG"
  fi
else
  echo "Dry run, not pushing (branch: $_branch, version: $TAG)"
fi
