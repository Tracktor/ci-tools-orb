#!/usr/bin/env bash

# Utility script to bump the version and push to git
# Usage: ./bump-version.sh <python|js> <branch>
# If no branch is provided, it will default to master
# For this script to work, you need to have the following environment variables set:
# - CI_EMAIL
# - CI_USER
# You can also set the following environment variables:
# - DRY_RUN: if set to true, it will not push to git
# You will need to have the following tools installed:
# - python: poetry with commitizen and the gh cli
# - js: yarn with commit-and-tag-version

_DRY_RUN="false"
# shellcheck disable=SC2153
if [ "$DRY_RUN" -eq "1" ]; then
   _DRY_RUN="true"
fi


echo "Dry run: $DRY_RUN - $_DRY_RUN"

function bump_push_python() {
  poetry run cz bump --yes
  readonly BUMP_CODE=$?

  if [ $BUMP_CODE -eq 0 ]; then
    TAG=$(poetry version -s)
    readonly TAG
    poetry run cz changelog "$TAG"
    poetry build
    # We need to push before releasing so that the pyproject.toml matches
    # for the cache
    if [ "$_DRY_RUN" = "false" ]; then
      git push origin "$BRANCH"
      gh release create -F CHANGELOG.md "$TAG" ./dist/*.whl
    else
      echo "Dry run, not pushing"
    fi
  else
    echo "Bump failed"
    exit 1
  fi
}

function bump_push_js() {
  yarn commit-and-tag-version
   if [ "$_DRY_RUN" = "false" ]; then
     git push origin "$BRANCH" --follow-tags
  else
      echo "Dry run, not pushing"
  fi
}


function git_init() {
  if [ -z "$CI_EMAIL" ]; then
    echo "CI_EMAIL is not set"
    exit 1
  fi
  if [ -z "$CI_USER" ]; then
    echo "CI_USER is not set"
    exit 1
  fi

  git config --global user.email "$CI_EMAIL"
  git config --global user.name "$CI_USER"
}

git_init

case $LANG_TYPE in
python)
  bump_push_python
  ;;
js)
  bump_push_js
  ;;
*)
  echo "Please choose a command: python or js"
  exit 1
  ;;
esac
