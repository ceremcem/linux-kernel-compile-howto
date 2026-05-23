#!/bin/bash

cca-suspend --disable-by Linux_kernel_compile
cd linux
export CC="ccache gcc" # sudo apt install ccache
export KDEB_DISABLE_DEBUG=1 # no debug-*.deb generation
TIMEFORMAT="Elapsed time: %E"; time make -j$(nproc) bindeb-pkg
cca-suspend --enable-for Linux_kernel_compile
