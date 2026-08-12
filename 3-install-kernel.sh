#!/bin/bash
set -euo pipefail

if [[ ! -d "linux" ]]; then
    echo "Error: 'linux' directory not found." >&2
    exit 1
fi

latest=$(cd linux && git describe --tags --abbrev=0)
version=${latest#v}

mkdir -p deb
mv *.deb *.buildinfo *.changes deb/ 2> /dev/null || true
cd deb

# 'ls -v' sorts naturally by version number; 'tail -n 1' grabs the newest build
image=$(ls -v linux-image*"$version"* 2>/dev/null | grep -v dbg | tail -n 1)
header=$(ls -v linux-headers*"$version"* 2>/dev/null | tail -n 1)

if [[ -z "$image" || -z "$header" ]]; then
    echo "Error: Could not find matching packages for version $version" >&2
    exit 1
fi

echo "Installing latest build: $image and $header"
sudo apt install ./"$image" ./"$header"
