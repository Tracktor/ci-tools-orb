#!/bin/bash

set -e

TOOL=${TOOL:-poetry}
EXTRA_PARAMS=${EXTRA_PARAMS:-}

function export_poetry() {
  poetry version -s > .version
  if [[ "${EXTRA_PARAMS}" == "" ]]; then
      poetry export -f requirements.txt > requirements.txt
  else
      poetry export -f requirements.txt $EXTRA_PARAMS > requirements.txt
  fi
}

function export_uv(){
  grep -m1 "^version\s*=\s*\".*\"" pyproject.toml | sed 's/version\s*=\s*"\(.*\)"/\1/' > .version

  if [[ "${EXTRA_PARAMS}" == "" ]]; then
    uv export --format requirements-txt > requirements.txt
  else
    # shellcheck disable=SC2086
    uv export --format requirements-txt $EXTRA_PARAMS > requirements.txt
  fi
}


case $TOOL in
  "poetry")
    echo "Using poetry to export requirements..."
    export_poetry
    ;;
  "uv")
    echo "Using uv to export requirements..."
    export_uv
    ;;
  *)
    echo "Unsupported tool: $TOOL"
    echo "Supported tools: poetry, uv"
    exit 1
    ;;
esac
