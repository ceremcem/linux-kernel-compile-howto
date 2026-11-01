#!/bin/bash
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source

[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

service_file="/etc/systemd/system/setup-vbox-next-boot.service"

cat << EOF > "$service_file"
[Unit]
Description=Configure VirtualBox kernel modules after kernel boot
After=multi-user.target

[Service]
Type=oneshot
ExecStart="$_sdir/reload-virtualbox-modules.sh"
ExecStartPost=/usr/bin/systemctl disable setup-vbox-next-boot.service
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

echo "Created service file: $service_file"
echo "Virtualbox modules will be compiled on next boot"
