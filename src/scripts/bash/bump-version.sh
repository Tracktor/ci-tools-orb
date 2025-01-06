#!/usr/bin/env bash

set -euo pipefail

# Utility script to bump the version and push to git based on commit messages.
# Updates the CHANGELOG.md file.
#
# Environment variables:
# Required:
#   - LANG_TYPE: Language of the project (js or python)
#   - BRANCH: Branch to use (default: main)
#   - CI_EMAIL: Email for git config
#   - CI_USER: Username for git config
#   - TOOL: Tool to use (poetry|uv|npm|yarn)
# Optional:
#   - DRY_RUN: Set to true to prevent git pushes (default: false)
#   - BUILD: Set to false to skip build step (default: true)
#   - SIGN_COMMIT: Set to true to enable GPG signing (default: false)

# Default configuration
declare -r BRANCH="${BRANCH:-main}"
declare -r TOOL="${TOOL:-poetry}"
declare -r LANG_TYPE="${LANG_TYPE:-}"
declare -r _DRY_RUN="${DRY_RUN:-false}"
declare -r _BUILD="${BUILD:-true}"
declare -r _SIGN_COMMIT="${SIGN_COMMIT:-false}"

function log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

function fail() {
    log "ERROR: $*"
    exit 1
}

function check_requirements() {
    # Check required environment variables
    [[ -z "${CI_EMAIL:-}" ]] && fail "CI_EMAIL is not set"
    [[ -z "${CI_USER:-}" ]] && fail "CI_USER is not set"
    [[ -z "$LANG_TYPE" ]] && fail "LANG_TYPE is not set"

    # Validate language type
    case "$LANG_TYPE" in
        python|js) ;;
        *) fail "Invalid LANG_TYPE. Must be 'python' or 'js'" ;;
    esac

    # Validate tool selection
    case "$TOOL" in
        poetry|uv|default)
            [[ "$LANG_TYPE" != "python" ]] && fail "Tool $TOOL requires LANG_TYPE=python"
            ;;
        npm|yarn)
            [[ "$LANG_TYPE" != "js" ]] && fail "Tool $TOOL requires LANG_TYPE=js"
            ;;
        *) fail "Invalid TOOL. Must be one of: poetry, uv, default, npm, yarn" ;;
    esac

    # Check required tools
    case "$TOOL" in
        poetry) command -v poetry >/dev/null 2>&1 || fail "poetry is required but not installed" ;;
        uv) command -v uv >/dev/null 2>&1 || fail "uv is required but not installed" ;;
        npm) command -v npm >/dev/null 2>&1 || fail "npm is required but not installed" ;;
        yarn) command -v yarn >/dev/null 2>&1 || fail "yarn is required but not installed" ;;
        default) command -v python >/dev/null 2>&1 || fail "python is required but not installed" ;;
    esac

    # Check for commitizen if using Python
    if [[ "$LANG_TYPE" == "python" && "$TOOL" == "default" ]]; then
        command -v cz >/dev/null 2>&1 || fail "commitizen is required but not installed"
    fi

    if [[ "$_DRY_RUN" == "true"  ]]; then
      command -v gh >/dev/null 2>&1 || fail "gh CLI is required but not installed"
    fi
}

function git_init() {
    log "Configuring git..."
    git config --global user.email "$CI_EMAIL"
    git config --global user.name "$CI_USER"

    if [[ "$_SIGN_COMMIT" == "true" && "$_DRY_RUN" == "false" ]]; then
        git config --global commit.gpgsign true
    fi
}

function get_python_version() {
    case "$TOOL" in
        poetry)
            poetry version -s
            ;;
        *)
            # First try .cz.toml
            if [[ -f ".cz.toml" ]]; then
                version=$(grep 'version = ' .cz.toml | cut -d'"' -f2)
                if [[ -n "$version" ]]; then
                    echo "$version"
                    return 0
                fi
            fi

            # Fallback to pyproject.toml
            version=$(grep -m1 "^version\s*=\s*\".*\"" pyproject.toml | sed 's/version\s*=\s*"\(.*\)"/\1/')
            if [[ -z "$version" ]]; then
                fail "Failed to extract version from either .cz.toml or pyproject.toml"
            fi
            echo "$version"
            ;;
    esac
}

function build_python_package() {
    if [[ "$_BUILD" != "true" ]]; then
        return
    fi

    case "$TOOL" in
        poetry) poetry build ;;
        uv) uv build ;;
        default|*) python -m build ;;
    esac
}

function bump_push_python() {
    local bump_command="cz bump --yes"
    case "$TOOL" in
        poetry) bump_command="poetry run $bump_command" ;;
        uv) bump_command="uv run --only-group=bump $bump_command" ;;
        default|*)  ;;
    esac

    if ! $bump_command; then
        case $? in
            21) log "No bump needed" ; return 0 ;;
            *) fail "Version bump failed" ;;
        esac
    fi

    local tag
    tag=$(get_python_version)

    log "Generating changelog for version $tag"
    case "$TOOL" in
        poetry) poetry run cz changelog "$tag" ;;
        uv) uv run cz changelog "$tag" ;;
        *) cz changelog "$tag" ;;
    esac

    build_python_package

    if [[ "$_DRY_RUN" == "false" ]]; then
        log "Pushing changes to $BRANCH"
        git push origin "$BRANCH"

        if [[ "$_BUILD" == "true" ]]; then
            gh release create -F CHANGELOG.md "$tag" ./dist/*.whl
        else
            gh release create -F CHANGELOG.md "$tag"
        fi
    else
        log "Dry run - skipping push (version: $tag)"
    fi
}

function bump_push_js() {
    case "$TOOL" in
        npm) npm version patch ;;
        yarn) yarn commit-and-tag-version ;;
    esac

    local tag
    tag=$(grep '"version":' ./package.json | cut -d\" -f4)

    if [[ "$_DRY_RUN" == "false" ]]; then
        log "Pushing changes to $BRANCH"
        git push origin "$BRANCH" --follow-tags
        gh release create -F CHANGELOG.md "$tag"
    else
        log "Dry run - skipping push (version: $tag)"
    fi
}

# Main execution
check_requirements
git_init

case "$LANG_TYPE" in
    python) bump_push_python ;;
    js) bump_push_js ;;
    *) fail "Please choose a command: python or js" ;;
esac