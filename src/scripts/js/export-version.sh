#!/usr/bin/env bash

set -e

echo "export VERSION=$(grep version package.json | awk -F \" '{print $4}')" >> "$BASH_ENV"
