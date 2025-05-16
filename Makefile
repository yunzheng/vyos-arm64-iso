# Determined by checking the errors when building the iso
GIT_PACKAGES := libvyosconfig vyatta-bash vyatta-biosdevname vyatta-cfg vyos-http-api-tools ipaddrcheck vyos-utils hvinfo udp-broadcast-relay

# Created using dirlisting of vyos-build/scripts/package-build/
ALL_PACKAGES := amazon-cloudwatch-agent amazon-ssm-agent aws-gwlbtun bash-completion blackbox_exporter ddclient dropbear \
	    ethtool frr frr_exporter hostap hsflowd isc-dhcp kea keepalived libnss-mapuser libpam-radius-auth linux-kernel \
	    ndppd net-snmp netfilter node_exporter openvpn-otp owamp pmacct podman pyhumps radvd strongswan tacacs telegraf \
	    vpp vyos-1x waagent wide-dhcpv6 xen-guest-agent

# Skip building these
EXCLUDE_PACKAGES := amazon-cloudwatch-agent amazon-ssm-agent tacacs waagent xen-guest-agent

PACKAGES := $(filter-out $(EXCLUDE_PACKAGES),$(ALL_PACKAGES))


DOCKER_IMAGE_EXISTS := $(shell docker image inspect local/vyos-build >/dev/null 2>&1 && echo "yes" || echo "no")

vyos-build:
	[ -d "vyos-build" ] || git clone https://github.com/vyos/vyos-build.git

docker: vyos-build
ifeq ($(DOCKER_IMAGE_EXISTS),yes)
	@echo "Docker image local/vyos-build already exists. Skipping build."
else
	@echo "Building Docker image local/vyos-build..."
	@cd vyos-build/docker && docker build -t local/vyos-build .
endif

shell: docker
	docker run -it --rm --privileged -v $(CURDIR)/vyos-build:/vyos -v $(CURDIR)/scripts:/scripts -w /vyos local/vyos-build /bin/bash

kernel-xxx: docker
	docker run -it --rm --privileged -v $(CURDIR)/vyos-build:/vyos -v $(CURDIR)/scripts:/scripts -w /vyos/scripts/package-build/linux-kernel local/vyos-build ./build.py

package-build: docker
	docker run -it --rm --privileged -v $(CURDIR)/vyos-build:/vyos -v $(CURDIR)/scripts:/scripts -w /scripts local/vyos-build ./build-local-packages.sh

iso: docker local-packages git-packages
	docker run -it --rm --privileged -v $(CURDIR)/vyos-build:/vyos -v $(CURDIR)/scripts:/scripts -w /scripts local/vyos-build bash -i ./build-iso.sh

iso-only: docker
	docker run -it --rm --privileged -v $(CURDIR)/vyos-build:/vyos -v $(CURDIR)/scripts:/scripts -w /scripts local/vyos-build bash -i ./build-iso.sh

kernel: build-linux-kernel

local-packages: $(PACKAGES:%=build-%)

git-packages: $(GIT_PACKAGES:%=build-git-%)

# Pattern rule for building packages
build-%: docker
	@PACKAGE=$*; \
	PACKAGE_DIR="vyos-build/scripts/package-build/$$PACKAGE"; \
	if ls $${PACKAGE_DIR}/$${PACKAGE}*.deb >/dev/null 2>&1; then \
		echo "DEB package(s) already exist for $* ($$PACKAGE_DIR). Skipping build."; \
		ls -l $${PACKAGE_DIR}/$${PACKAGE}*.deb; \
	else \
		echo "Building package $*"; \
		docker run -it --rm --privileged -v $(CURDIR)/vyos-build:/vyos -v $(CURDIR)/scripts:/scripts -w /vyos local/vyos-build /scripts/build-local-deb.sh $$PACKAGE; \
	fi

# Pattern rule for building git packages
build-git-%: docker
	@PACKAGE=$*; \
	GIT_DIR="vyos-build/scripts/package-build/git"; \
	PACKAGE_DIR="$$GIT_DIR/$$PACKAGE"; \
	if ls $${GIT_DIR}/$${PACKAGE}*.deb >/dev/null 2>&1; then \
		echo "DEB package(s) already exist for $*. Skipping build."; \
		ls -l $${GIT_DIR}/$${PACKAGE}*.deb; \
	else \
		echo "Building package $*"; \
		docker run -it --rm --privileged -v $(CURDIR)/vyos-build:/vyos -v $(CURDIR)/scripts:/scripts -w /scripts local/vyos-build /scripts/build-git-deb.sh $*; \
	fi
