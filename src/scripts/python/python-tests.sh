#!/bin/bash



# Pytest
if [[ "${EXTRA_PARAMS}" == "" ]]; then
  # shellcheck disable=SC2086
  poetry run pytest -vv --junitxml=tests/junit.xml ${EXTRA_PARAMS}
else
  poetry run pytest -vv --junitxml=tests/junit.xml
fi
# Coverage
poetry run coverage html
