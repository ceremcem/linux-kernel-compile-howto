#!/bin/bash
set -eu

latest=$(cd linux && git describe --tags --abbrev=0)
version=${latest#v}
mv *.deb deb 2> /dev/null || true
cd deb
image=$(ls | grep $version | grep image | grep -v dbg)
header=$(ls | grep $version | grep header)
echo "Install: $image and $header"
sudo dpkg -i $image $header
