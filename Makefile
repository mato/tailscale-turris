
UPSTREAM_DIST := https://pkgs.tailscale.com/stable/tailscale_1.34.0_arm.tgz
PKG_VERSION := 1.34.0-1
PKG_ARCH := arm_cortex-a9_vfpv3-d16
PKG_SUFFIX := $(PKG_VERSION)_$(PKG_ARCH)
PACKAGES := build/tailscale_$(PKG_SUFFIX).ipk build/tailscaled_$(PKG_SUFFIX).ipk

# Common options for tar file components of ipk files
IPK_TAR := tar --numeric-owner --owner=0 --group=0

all: $(PACKAGES)

.PHONY: all

.SUFFIXES:

build/tailscale.tar.gz:
	mkdir -p $(@D) $(@D)/upstream
	curl -Ssf $(UPSTREAM_DIST) --output $@
	tar -C $(@D)/upstream --strip-components=1 -xzf $@

build/upstream/tailscale build/upstream/tailscaled: | build/tailscale.tar.gz ;

build/tailscale_$(PKG_SUFFIX)/data.tar.gz: build/upstream/tailscale
	mkdir -p $(@D)/data
	mkdir -m 0755 -p $(@D)/data/usr/sbin
	cp -p $< $(@D)/data/usr/sbin/tailscale
	$(IPK_TAR) -C $(@D)/data -czf $@ .

build/tailscale_$(PKG_SUFFIX)/control.tar.gz: files/tailscale-control.in files/prerm files/postinst build/tailscale_$(PKG_SUFFIX)/data.tar.gz
	mkdir -p $(@D)/control
	scripts/subst-control.sh $< $(PKG_VERSION) $(PKG_ARCH) $(@D)/data $(@D)/control/control
	cp files/prerm files/postinst $(@D)/control
	chmod 0755 $(@D)/control/prerm $(@D)/control/postinst
	$(IPK_TAR) -C $(@D)/control -czf $@ .

build/tailscaled_$(PKG_SUFFIX)/data.tar.gz: build/upstream/tailscaled files/tailscale.init files/tailscale.conf
	mkdir -p $(@D)/data
	mkdir -m 0755 -p $(@D)/data/usr/sbin
	cp -p $< $(@D)/data/usr/sbin/tailscaled
	mkdir -m 0755 -p $(@D)/data/etc/config
	cp files/tailscale.conf $(@D)/data/etc/config/tailscale
	chmod 0644 $(@D)/data/etc/config/tailscale
	mkdir -m 0755 -p $(@D)/data/etc/init.d
	cp files/tailscale.init $(@D)/data/etc/init.d/tailscale
	chmod 0755 $(@D)/data/etc/init.d/tailscale
	$(IPK_TAR) -C $(@D)/data -czf $@ .

build/tailscaled_$(PKG_SUFFIX)/control.tar.gz: files/tailscaled-control.in files/prerm files/postinst build/tailscaled_$(PKG_SUFFIX)/data.tar.gz
	mkdir -p $(@D)/control
	scripts/subst-control.sh $< $(PKG_VERSION) $(PKG_ARCH) $(@D)/data $(@D)/control/control
	cp files/prerm files/postinst $(@D)/control
	chmod 0755 $(@D)/control/prerm $(@D)/control/postinst
	echo "/etc/config/tailscale" >$(@D)/control/conffiles
	$(IPK_TAR) -C $(@D)/control -czf $@ .

# Given control.tar.gz and data.tar.gz, build the containing .ipk
# NOTE that paths in the containing .ipk must start with ./ otherwise opkg fails
# in the configuration phase.
$(PACKAGES): build/%.ipk: build/%/data.tar.gz build/%/control.tar.gz
	echo "2.0" > build/$*/debian-binary
	$(IPK_TAR) -C build/$* -czf $@ ./debian-binary ./control.tar.gz ./data.tar.gz

clean:
	$(RM) -r build

.PHONY: clean
