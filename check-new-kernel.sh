#!/bin/bash
set -u

period="10m"
first_msg_shown=false
retry_connect=false
while :; do
    while :; do
        LATEST_KERNEL=$(curl -s https://www.kernel.org/releases.json | jq -r '.latest_stable.version')
        if [[ -n $LATEST_KERNEL ]]; then 
            $retry_connect && echo
            retry_connect=false
            break
        fi
        retry_connect=true
        echo -n "."
        first_msg_shown=false
        sleep 10
    done

    # Extract the major version (the number before the first dot)
    MAJOR="${LATEST_KERNEL%%.*}"
    CHANGELOG_URL="https://cdn.kernel.org/pub/linux/kernel/v${MAJOR}.x/ChangeLog-${LATEST_KERNEL}"

    if [[ "$LATEST_KERNEL" != "$(uname -r)" ]]; then
        notify-send -u critical "New Stable Kernel" "New kernel available: $LATEST_KERNEL"
        echo "New stable kernel available: $LATEST_KERNEL"
        echo "Changelog: $CHANGELOG_URL"

        period="24h"
    else
        if ! $first_msg_shown; then
            echo "System is already running on latest stable kernel: v$LATEST_KERNEL"
            echo "Changelog: $CHANGELOG_URL"
            first_msg_shown=true
        fi
    fi
    sleep $period
done
