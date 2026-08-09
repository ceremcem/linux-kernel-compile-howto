#!/bin/bash
set -eu
cca-suspend --disable-by kernel-compile || true
./1-fetch-new-source.sh
./2-compile-kernel.sh
./3-install-kernel.sh
./4-reload-virtualbox-modules.sh
cca-suspend --enable-by kernel-compile || true
