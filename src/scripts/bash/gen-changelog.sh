#!/usr/bin/env bash

set -xeuo pipefail

_TAG_PATTERN=${TAG_PATTERN:-"^v\d+\.\d+\.\d+$"}

if ! uvx git-cliff -o CHANGELOG.md --latest --tag-pattern "$_TAG_PATTERN"; then
    echo "Error: Failed to generate CHANGELOG" >&2
    exit 1
fi
sed -i '$ d' CHANGELOG.md
