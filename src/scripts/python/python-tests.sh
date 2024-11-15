#!/bin/bash



# Pytest
if [[ "${EXTRA_PARAMS}" == "" ]]; then
  poetry run pytest -vv --junitxml=tests/junit.xml ${EXTRA_PARAMS}
else
  poetry run pytest -vv --junitxml=tests/junit.xml
# Coverage
poetry run coverage html
