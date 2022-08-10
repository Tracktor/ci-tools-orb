#!/bin/bash

poetry version -s > .version

if [[ "${EXTRA_PARAMS}" == "" ]]; then
  poetry export -f requirements.txt --output requirements.txt
else
  # shellcheck disable=SC2086
  poetry export -f requirements.txt --output requirements.txt ${EXTRA_PARAMS}
fi
