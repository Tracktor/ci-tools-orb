#!/usr/bin/env bash

set -xeuo pipefail

[[ -z "${CI_USER:-}" ]] && echo "CI_USER is not set" && exit 1
[[ -z "${CI_EMAIL:-}" ]] && echo "CI_EMAIL is not set" && exit 1

# Initialize variables
_BRANCH="${BRANCH:-$(git branch --show-current)}"
_TRACK_BUMP_VERSION="${TRACK_BUMP_VERSION:-latest}"
export CI_USER_EMAIL=$CI_EMAIL


# Build the command array
cmd_args=("uvx" "track-bump@$_TRACK_BUMP_VERSION")

if [ "${VERBOSE:-0}" = "1" ]; then
    cmd_args+=("-vv")
fi

cmd_args+=("bump" "--branch" "$_BRANCH" "--no-reset-git" "--no-tag")

if [ "${SIGN_COMMIT:-0}" = "1" ]; then
    cmd_args+=("--sign")
fi

if [ -n "${CUSTOM_PARAMS:-}" ]; then
    # Split CUSTOM_PARAMS into array elements
    read -ra custom_args <<< "$CUSTOM_PARAMS"
    cmd_args+=("${custom_args[@]}")
fi

# Run track bump
"${cmd_args[@]}" | tee >(tail -n 1 > .tag)

# Check that .tag is not empty
if [ ! -s .tag ]; then
    echo "Error: .tag is empty" >&2
    exit 1
fi

# shellcheck disable=SC2016
echo "$TAG" > .tag
