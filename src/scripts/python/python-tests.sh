#!/bin/bash

# Pyright
poetry run pyright

# Pytest
poetry run pytest -vv --junitxml=tests/junit.xml

# Coverage
poetry run coverage xml -o tests/coverage.xml
poetry run coverage html
