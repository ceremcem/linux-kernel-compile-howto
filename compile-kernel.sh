#!/bin/bash

cca-suspend --disable-by Linux_kernel_compile
cd linux
TIMEFORMAT="Elapsed time: %R"; time make -j$(nproc) bindeb-pkg
cca-suspend --enable-for Linux_kernel_compile
