#!/bin/bash

set -e

TOOL=${TOOL:-poetry}
EXTRA_PARAMS=${EXTRA_PARAMS:-}

function run_poetry(){
  if [[ "${EXTRA_PARAMS}" == "" ]]; then
    poetry run pytest -vv --junitxml=tests/junit.xml
  else
    # shellcheck disable=SC2086
    poetry run pytest -vv --junitxml=tests/junit.xml ${EXTRA_PARAMS}
  fi

  poetry run coverage html
}

function run_uv(){
  if [[ "${EXTRA_PARAMS}" == "" ]]; then
    uv run pytest -vv --junitxml=tests/junit.xml
  else
    # shellcheck disable=SC2086
    uv run pytest -vv --junitxml=tests/junit.xml ${EXTRA_PARAMS}
  fi

  uv run coverage html
}

case $TOOL in
  "poetry")
    echo "Running tests with poetry..."
    run_poetry
    ;;
  "uv")
    echo "Running tests with uv..."
    run_uv
    ;;
  *)
    echo "Unsupported tool: $TOOL"
    echo "Supported tools: poetry, uv"
    exit 1
    ;;
esac
