#!/bin/bash
set -u

now() {
    date +%s
}

first_msg_shown=false
retry_connect=false
latest_informed_kernel=
reset_period=$((48 * 3600)) # seconds
last_reset=$(now)

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
        if [[ "$LATEST_KERNEL" != "$latest_informed_kernel" ]]; then
            notify-send -u critical "New Stable Kernel" "New kernel available: $LATEST_KERNEL"
            echo "New stable kernel available: $LATEST_KERNEL"
            echo "Changelog: $CHANGELOG_URL"
            latest_informed_kernel="$LATEST_KERNEL"
        fi
    else
        if ! $first_msg_shown; then
            echo "System is already running on latest stable kernel: v$(uname -r)"
            echo "Changelog: $CHANGELOG_URL"
            first_msg_shown=true
        fi
    fi

    # Reset info popup in every 24h
    if [[ $(now) -gt $((last_reset + reset_period)) ]]; then
        latest_informed_kernel=
        last_reset=$(now)
    fi
    sleep 10m
done
