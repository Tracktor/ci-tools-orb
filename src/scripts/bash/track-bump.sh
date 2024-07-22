#!/usr/bin/env bash

set -xe

export MAIN_BRANCH=${DEFAULT_BRANCH}

_DRY_RUN="false"
# shellcheck disable=SC2153
if [ "$DRY_RUN" -eq "1" ]; then
  _DRY_RUN="true"
fi

_GEN_CHANGELOG="false"
# shellcheck disable=SC2153
if [ "$GEN_CHANGELOG" -eq "1" ]; then
  _GEN_CHANGELOG="true"
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

if [ "$_GEN_CHANGELOG" = "true" ]; then
  echo "Generating CHANGELOG"
  pipx run git-cliff -o CHANGELOG.md --latest
  # Remove last line
  sed -i '$ d' CHANGELOG.md
  git add CHANGELOG.md
  git commit --amend --no-edit
else
  echo "Not generating CHANGELOG"
fi

# Redirect git tag output to a temporary file to avoid SIGPIPE issue
_tag_file=$(mktemp)
git tag -l --sort=-version:refname > "$_tag_file"
TAG=$(head -n 1 "$_tag_file")
rm "$_tag_file"

if [ "$_DRY_RUN" = "false" ]; then
  echo "Pushing branch $_branch and tag $TAG"
  git push origin "$_branch" --follow-tags
  echo "Creating Github release $TAG"
  gh release create -F CHANGELOG.md "$TAG"
else
  echo "Dry run, not pushing (branch: $_branch, version: $TAG)"
fi
