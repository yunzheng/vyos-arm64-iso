#!/bin/bash

declare -a exclude_patterns=("*dbgsym*" "*xen-*")

# start with a clean packages dir
find /vyos/packages -type l -name "*.deb" -delete

find_command="find /vyos/scripts/package-build -type f -name '*.deb'"

# Build the find command with exclusions
for pattern in "${exclude_patterns[@]}"; do
    find_command+=" -not -name '$pattern'"
done

# symlink the deb packages
cd /vyos/packages
for deb in $(eval $find_command); do
	ln -s $deb
done
