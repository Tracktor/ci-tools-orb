#!/usr/bin/env bash

# Convert boolean/numeric environment variables to true/false



function to_boolean() {
    local value="${1:-}"
    case "$value" in
        true|1|yes|y) echo "true" ;;
        *) echo "false" ;;
    esac
}