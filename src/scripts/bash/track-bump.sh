#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=./utils.sh
# shellcheck disable=SC1091
source "./utils.sh"

# Initialize variables

_BRANCH="${BRANCH:-$(git branch --show-current)}"
_DRY_RUN="$(to_boolean "${DRY_RUN:-false}")"
_BUILD="$(to_boolean "${BUILD:-true}")"
_CREATE_RELEASE="$(to_boolean "${CREATE_RELEASE:-false}")"
_TRACK_BUMP_VERSION="${TRACK_BUMP_VERSION:-latest}"
_TRACK_BUMP="uvx track-bump@$_TRACK_BUMP_VERSION"

[[ -z "${CI_USER:-}" ]] && fail "CI_USER is not set"
[[ -z "${CI_EMAIL:-}" ]] && fail "CI_EMAIL is not set"


# Build the command array
cmd_args=("$_TRACK_BUMP")

if [ "${VERBOSE:-0}" = "1" ]; then
    cmd_args+=("-vv")
fi

cmd_args+=("bump" "--branch" "$_BRANCH")

if [ "${SIGN_COMMIT:-0}" = "1" ]; then
    cmd_args+=("--sign")
fi

if [ -n "${CUSTOM_PARAMS:-}" ]; then
    # Split CUSTOM_PARAMS into array elements
    read -ra custom_args <<< "$CUSTOM_PARAMS"
    cmd_args+=("${custom_args[@]}")
fi

# Run track bump
"${cmd_args[@]}"

if [ "$_CREATE_RELEASE" = "true" ] && [ "$_DRY_RUN" = "false" ]; then
    echo "Generating CHANGELOG"
    if ! uvx git-cliff -o CHANGELOG.md --latest --tag-pattern "^v\d+\.\d+\.\d+$"; then
        echo "Error: Failed to generate CHANGELOG" >&2
        exit 1
    fi
    sed -i '$ d' CHANGELOG.md
    git add CHANGELOG.md
    git commit --amend --no-edit
else
    echo "Not generating CHANGELOG"
fi

# Get the latest tag
TAG=$($_TRACK_BUMP get-latest-tag --branch "$_BRANCH")
if [ -z "$TAG" ]; then
    echo "Error: Failed to get latest tag" >&2
    exit 1
fi

if [ "$_DRY_RUN" = "false" ]; then
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
else
    echo "Dry run, not pushing (branch: $_BRANCH, version: $TAG)"
fi