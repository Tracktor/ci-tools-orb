#!/bin/bash

set -e

TOOL=${TOOL:-poetry}

function export_poetry() {
  poetry version -s > .version
  if [[ "${EXTRA_PARAMS}" == "" ]]; then
      # shellcheck disable=SC2094
      poetry export -f requirements.txt --output requirements.txt
  else
      # shellcheck disable=SC2094 disable=SC2086
      poetry export -f requirements.txt --output requirements.txt ${EXTRA_PARAMS}
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
