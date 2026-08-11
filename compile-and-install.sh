#!/bin/bash
set -eu

echo "This script requires sudo privileges for certain commands."
sudo -v || exit 1
while true; do
    sudo -v
    sleep 60
done &
KEEPALIVE_PID=$!
trap 'kill "$KEEPALIVE_PID" 2>/dev/null' EXIT

echo_popup(){
    notify-send -u critical "Kernel Compile Info" "$1"
    echo "$1"
}

running_vms=()
save_and_close_vms(){
    if ! timeout 5 VBoxManage list runningvms > /dev/null; then
        echo_popup "Pausing running VMs failed. (VMs can not be listed)"
        return
    fi
    readarray -t running_vms <<< $(VBoxManage list runningvms | awk -F'"' '{print $2}')
    for vm in "${running_vms[@]}"; do
        [[ -z "$vm" ]] && continue
        echo_popup "Saving and closing VirtualBox VM: $vm"
        VBoxManage controlvm "$vm" savestate || true
    done
}
resume_vms(){
    for vm in "${running_vms[@]}"; do
        [[ -z "$vm" ]] && continue
        echo_popup "Resuming VirtualBox VM: $vm"
        VBoxManage startvm "$vm"
    done
}

echo_popup "Reminder: Make space if needed in /boot partition: Available space: $(df -h --output=avail /boot | tail -n 1)"

start_time=$(date +%s)

cca-suspend --disable-by kernel-compile || true
./1-fetch-new-source.sh
./2-compile-kernel.sh
./3-install-kernel.sh
save_and_close_vms
./4-reload-virtualbox-modules.sh
resume_vms
cca-suspend --enable-by kernel-compile || true

end_time=$(date +%s)
duration=$((end_time - start_time))

# Format and display as hh:mm:ss
printf "Elapsed Time: %02d:%02d:%02d\n" $((duration/3600)) $((duration%3600/60)) $((duration%60))
