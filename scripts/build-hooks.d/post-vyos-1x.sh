#!/bin/bash -xe
# vyos-1x-vmware package is only build on amd64 architecture, fix this
cd vyos-1x
git checkout debian/control
perl -p -i -e 's/Architecture: amd64$/Architecture: all/' debian/control
dpkg-buildpackage -us -uc -b
