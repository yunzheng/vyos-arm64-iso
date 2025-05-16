#!/bin/bash -xe
rm -fr frr/.pc
git checkout package.toml
perl -p -i -e 's/deb; dpkg-buildpackage/deb; sudo apt-get build-dep -y -Ppkg.frr.rtrlib,pkg.frr.lua .; dpkg-buildpackage/' package.toml
