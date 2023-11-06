#!/usr/bin/env bash

# Utility script to bump the version and push to git
# Usage: ./bump-version.sh <python|js> <branch>
# If no branch is provided, it will default to master
# For this script to work, you need to have the following environment variables set:
# - CI_EMAIL
# - CI_USER
# You will need to have the following tools installed:
# - poetry
# - gh
#

function bump_push_python() {
  poetry run bump --yes

  if [ $? -eq 0 ]; then
    readonly TAG=$(poetry version -s)
    poetry run cz changelog "$TAG"
    poetry build
    # We need to push before releasing so that the pyproject.toml matches
    # for the cache
    git push origin "$BRANCH"
    gh release create -F CHANGELOG.md "$TAG" ./dist/*.whl
  else
    echo "Bump failed"
    exit 1
  fi
}

function bump_push_js() {
  yarn commit-and-tag-version
  git push origin "$BRANCH" --follow-tags
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

export LANG_TYPE=$1
export BRANCH=${2:-master}

git_init

case $1 in
python)
  bump_push_python
  ;;
js)
  bump_push_js
  ;;
*)
  echo "Please choose a command: python or js"
  ;;
esac
