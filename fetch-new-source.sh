#!/bin/bash
set -eu

LATEST_KERNEL=$(curl -s https://www.kernel.org/releases.json | jq -r '.latest_stable.version')
cd linux
git fetch origin tag v$LATEST_KERNEL --depth=1
git checkout FETCH_HEAD

