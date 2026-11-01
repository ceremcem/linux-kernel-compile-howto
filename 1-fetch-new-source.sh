#!/bin/bash
set -eu

# Usage: ./1-fetch-new-source.sh [BRANCH]
#   BRANCH like 7.3 or 7.4; default: the branch of the currently checked-out tag
STABLE_URL=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git

cd linux
CURRENT=$(git describe --tags --abbrev=0)   # e.g. v7.3 or v7.3.2
echo "Current status: $CURRENT"

BRANCH=${1:-$(echo "${CURRENT#v}" | cut -d. -f1,2)}

JSON=$(curl -fs https://www.kernel.org/releases.json) || {
    echo "Could not fetch releases.json" >&2
    exit 1
}

# Latest release on the chosen branch (mainline moniker covers a fresh X.Y with no X.Y.1 yet)
LATEST=$(echo "$JSON" | jq -r --arg b "$BRANCH" '
    [.releases[]
     | select(.moniker == "stable" or .moniker == "longterm" or .moniker == "mainline")
     | select((.version == $b) or (.version | startswith($b + ".")))
     | .version][0] // empty')

if [[ -z $LATEST ]]; then
    echo "Branch $BRANCH is not listed upstream (EOL?)." >&2
    echo "Newest stable: $(echo "$JSON" | jq -r '.latest_stable.version')" >&2
    echo "Longterm: $(echo "$JSON" | jq -r '[.releases[] | select(.moniker=="longterm") | .version] | join(", ")')" >&2
    exit 1
fi

if [[ "v$LATEST" == "$CURRENT" ]]; then
    echo "Already on the latest $BRANCH release: $CURRENT"
    exit 0
fi

echo "Fetching v$LATEST from the stable tree"
git fetch "$STABLE_URL" tag "v$LATEST" --depth=1
git checkout FETCH_HEAD
echo "Now at: $(git describe --tags --abbrev=0)"
