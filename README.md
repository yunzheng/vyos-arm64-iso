# vyos-arm64-iso
This reposistory contains a `Makefile` and some helper scripts to build the VyOS iso on ARM64 using docker.
It utilizes the official [vyos-build](https://github.com/vyos/vyos-build) repository.

Tested on a Debian arm64 VM with Docker installed:

```shell
$ git clone https://github.com/yunzheng/vyos-arm64-iso.git
$ cd vyos-arm64-iso
$ make iso
```

The resulting ISO should be in `vyos-build/build/*.iso`

# Other make commands
Drop into shell, useful for testing and debugging of building packages:

```shell
$ make shell
```

Build a local package using `make build-<package>`:

```shell
$ make build-vyos-1x
```

Build a Git package using `make git-<package>`:

```shell
$ make git-libvyosconfig
```

Build all known Git packages:

```shell
$ make git-packages
```

Build all known local packages:

```shell
$ make local-packages
```

# Log files
Most build output is redirected to `scripts/log/*.log`.
