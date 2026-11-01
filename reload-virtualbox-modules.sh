#!/bin/bash

[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

systemctl stop vboxdrv.service
if ! /sbin/vboxconfig; then
    echo "--------------------"
    echo "Trying to update VirtualBox"
    echo "--------------------"
    apt update
    latest_vbox=$(apt-cache search virtualbox | grep -E '^virtualbox-[0-9]' | sort -V | tail -n 1 | awk '{print $1}')
    [[ -z $latest_vbox ]] && { echo "Can not get latest VirtualBox version. Exiting"; exit 1; }
    echo "Latest Virtualbox is $latest_vbox"
    apt install $latest_vbox
fi
/sbin/vboxconfig

for m in vboxdrv vboxnetflt vboxnetadp; do
    subject="=== $m ==="
    body="$(modinfo "$m" 2>/dev/null | grep -E 'filename|vermagic')"
    notify-send -u critical "$subject" "$body"
done
