#!/usr/bin/env bash

set -xeuo pipefail

if [ -f .tag ]; then
    TAG=$(cat .tag)
fi

[[ -z "${TAG:-}" ]] && echo "TAG is not set" && exit 1

_BRANCH="${BRANCH:-main}"
_CREATE_RELEASE="$(to_boolean "${CREATE_RELEASE:-true}")"

echo "Pushing branch $_BRANCH and tag $TAG"
if ! git push origin "$_BRANCH" --tags; then
    echo "Error: Failed to push branch and tags" >&2
    exit 1
fi

if [ "$_CREATE_RELEASE" = "true" ]; then
    echo "Creating Github release $TAG"
    if ! gh release create -F CHANGELOG.md "$TAG"; then
        echo "Error: Failed to create Github release" >&2
        exit 1
    fi
fi
