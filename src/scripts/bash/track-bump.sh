#!/usr/bin/env bash

set -e

_DRY_RUN="false"
# shellcheck disable=SC2153
if [ "$DRY_RUN" -eq "1" ]; then
  _DRY_RUN="true"
fi

_flags=""
# shellcheck disable=SC2153
if [ "$SIGN_COMMIT" -eq "1" ]; then
  _flags="--sign"
fi

pipx run track-bump bump --branch "$BRANCH" "$_flags" "$CUSTOM_PARAMS"

if [ "$_DRY_RUN" = "false" ]; then
  git push origin "$BRANCH" --follow-tags
  gh release create -F CHANGELOG.md "$TAG"
else
  echo "Dry run, not pushing (branch: $BRANCH, version: $TAG)"
fi
