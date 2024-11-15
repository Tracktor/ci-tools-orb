#!/bin/bash

# Pytest
if [[ "${EXTRA_PARAMS}" == "" ]]; then
  poetry run pytest -vv --junitxml=tests/junit.xml
else
  # shellcheck disable=SC2086
  poetry run pytest -vv --junitxml=tests/junit.xml ${EXTRA_PARAMS}
fi
# Coverage
poetry run coverage html
