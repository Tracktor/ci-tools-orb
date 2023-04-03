#!/bin/bash

# Pytest
poetry run pytest -vv --junitxml=tests/junit.xml
# Coverage
poetry run coverage html
