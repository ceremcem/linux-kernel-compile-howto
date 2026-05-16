# Prepare for manual maintenance

1. sudo apt-mark hold linux-image-amd64 linux-headers-amd64
2. apt-mark showhold 

# Download source and prepare for the first time 

    LATEST_KERNEL=$(curl -s https://www.kernel.org/releases.json | jq -r '.latest_stable.version')

1. git clone --depth 1 --branch v$LATEST_KERNEL https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
2. cd linux 
3. Copy .config from elsewhere: cp /boot/config-$(uname -r) .config
4. make olddefconfig

# Compile and install kernel 

1. Update sources (if needed) 

    git fetch origin tag v$LATEST_KERNEL --depth=1
    git checkout FETCH_HEAD

2. Verify `git log` commit hash with kernel.org
3. make menuconfig (optional)
4. time make -j$(nproc) bindeb-pkg
5. sudo dpkg -i ../linux-image-<VERSION>.deb ../linux-headers-<VERSION>.deb
6. sudo reboot
7. uname -r 

# Cleanup old kernels 

1. List installed kernels: 

    apt list --installed 'linux-image-*'

2. Remove unnecessary ones.
