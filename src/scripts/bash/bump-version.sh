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

_USE_POETRY="true"
# shellcheck disable=SC2153
if [ "$USE_POETRY" -eq "0" ]; then
  _USE_POETRY="false"
fi

function bump_push_python() {
  if [ "$_USE_POETRY" = "true" ]; then
    bump_push_python_poetry
  else
    bump_push_python_no_poetry
  fi
}

function bump_push_python_poetry() {
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

function bump_push_python_no_poetry() {
  cz bump --yes
  readonly BUMP_CODE=$?

  if [ $BUMP_CODE -eq 0 ]; then
    # shellcheck disable=SC2002
    TAG=$(cat .cz.toml | grep 'version = ' | cut -d'"' -f2)
    readonly TAG
    cz changelog "$TAG"
    if [ "$_DRY_RUN" = "false" ]; then
      git push origin "$BRANCH"
      gh release create -F CHANGELOG.md "$TAG" # ./dist/*.whl
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
  echo "Setting user.email to $CI_EMAIL"
  git config --global user.email "$CI_EMAIL"
  echo "Setting user.name to $CI_USER"
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
