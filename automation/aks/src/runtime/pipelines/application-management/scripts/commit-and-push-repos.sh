#!/usr/bin/env bash
set -euo pipefail
# This script creates / updates repos. The $_repos param should be *all* repos needed in the system, not just new ones needs.

_prefix="$1"
_application="$2"

for suffix in "state" "src"; do
    cd "$_prefix-$_application-$suffix"
    git add -A
    git diff-index --quiet HEAD || git commit -a -m "C12 CI Update"
    git push
    cd ..
done
