#!/usr/bin/env bash

set -xeuo pipefail

if [ -f .tag ]; then
    TAG=$(cat .tag)
fi

[[ -z "${TAG:-}" ]] && echo "TAG is not set" && exit 1
[[ -z "${STABLE_BRANCH:-}" ]] && echo "STABLE_BRANCH is not set" && exit 1
_BRANCH="${BRANCH:-$(git branch --show-current)}"

git tag "$TAG"
echo "Pushing branch $_BRANCH and tag $TAG"
if ! git push origin "$_BRANCH" --tags; then
    echo "Error: Failed to push branch and tags" >&2
    exit 1
fi

if [ "$STABLE_BRANCH" = "$_BRANCH" ]; then
    echo "Creating Github release $TAG"
    if ! gh release create -F CHANGELOG.md "$TAG"; then
        echo "Error: Failed to create Github release" >&2
        exit 1
    fi
else
  echo "Skipping Github release for branch $_BRANCH (stable branch: $STABLE_BRANCH)"
fi
