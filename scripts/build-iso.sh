#!/bin/sh -xe
$(dirname $0)/symlink-debs.sh 2>/dev/null
cd /vyos
sudo ./build-vyos-image --architecture arm64 generic --custom-package neovim
