#!/bin/bash -xe
pkg="$1"
eval $(opam env --root=/opt/opam --set-root)
mkdir -p /vyos/scripts/package-build/git
cd /vyos/scripts/package-build/git
[ -d "$pkg" ] || git clone "https://github.com/vyos/$pkg"

cd /vyos/scripts/package-build/git/$pkg
sudo apt-get build-dep -y .
dpkg-buildpackage -us -uc -b
