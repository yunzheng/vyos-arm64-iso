#!/usr/bin/env bash
export PATH=/opt/go/bin:$PATH
package="$1"
package_dir="/vyos/scripts/package-build/$package"
logdir="$(realpath $(dirname $0)/log)"
mkdir -p "$logdir"
set +e
cd $package_dir
echo "-------- BUILDING $package_dir ------"
[ -x /scripts/build-hooks.d/pre-$package.sh ] && {
	echo "PRE-HOOK /scripts/build-hooks.d/pre-$package.sh"
	/scripts/build-hooks.d/pre-$package.sh
}
sudo apt-get update
echo "./build.py > $logdir/$package.log"
./build.py > "$logdir/$package.log" 2>&1 && {
	echo "SUCCESS"
} || {
	echo "FAILED :("
}
[ -x /scripts/build-hooks.d/post-$package.sh ] && {
	echo "POST-HOOK /scripts/build-hooks.d/post-$package.sh"
	/scripts/build-hooks.d/post-$package.sh
}
exit 0
