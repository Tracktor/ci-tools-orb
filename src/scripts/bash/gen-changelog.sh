#!/usr/bin/env bash

set -xeuo pipefail

_CUSTOM_ARGS="${CUSTOM_ARGS:-}"
_TAG_PATTERN=${TAG_PATTERN:-"^v\d+\.\d+\.\d+$"}

if [ -f .tag ]; then
    TAG=$(cat .tag)
fi

[[ -z "${TAG:-}" ]] && echo "TAG is not set" && exit 1


if ! uvx git-cliff -o CHANGELOG.md --unreleased --tag-pattern "$_TAG_PATTERN" --tag "$TAG"  "$_CUSTOM_ARGS"; then
    echo "Error: Failed to generate CHANGELOG" >&2
    exit 1
fi
sed -i '$ d' CHANGELOG.md
