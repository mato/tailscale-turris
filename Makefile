# Build Turris OS packages from upstream precompiled static binaries at
# https://pkgs.tailscale.com/{stable,unstable}/#static.
#
# Available targets:
#
# build (default): Builds packages of the latest upstream release, defaults to
# the stable track (see TRACK below).
#
# install: As for build, and then installs the packages to DESTDIR, updating
# the package feed metadata (Packages) to suit.
#
# update: Intended to be run periodically from e.g. cron, builds packages from
# TRACK if a new upstream release is available since the last time this target
# was run and installs them to DESTDIR, taking care to only regenerate the
# package feed metadata if a new release was published.
#
# Suggested cronjob for building and publishing updates:
#     make -s TRACK=stable DESTDIR=/path/to/feeds/root update
#     make -s TRACK=unstable DESTDIR=/path/to/feeds/root update
#
# clean: Cleans all built packages.
#
# distclean: As for clean, but also removes any cached
# .upstream-$(TRACK)-release.
#
# Note that both clean and distclean only work on the working directory,
# specifically they do not touch the package feed directory in DESTDIR.

# Upstream release track, defaults to "stable".
TRACK ?= stable

# Destination directory for package feeds for the "install" target.
DESTDIR ?= /tmp/tailscale-turris/$(TRACK)

# If not set, defaults to the latest upstream release on the server, as cached
# in .upstream-$(TRACK)-release.
RELEASE ?= $(file <.upstream-$(TRACK)-release)

# -----------------------------------------------------------------------------

DIST_BASE := tailscale_$(RELEASE)_arm
DIST_TARBALL := $(DIST_BASE).tgz
DIST_TARBALL_URL := https://pkgs.tailscale.com/$(TRACK)/$(DIST_TARBALL)

PKG_VERSION := $(RELEASE)-1
PKG_ARCH := arm_cortex-a9_vfpv3-d16
PKG_SUFFIX := $(PKG_VERSION)_$(PKG_ARCH)

B := build/$(TRACK)
PACKAGES := $(B)/tailscale_$(PKG_SUFFIX).ipk $(B)/tailscaled_$(PKG_SUFFIX).ipk

# Common options for tar file components of ipk files
IPK_TAR := tar --numeric-owner --owner=0 --group=0

build: .upstream-$(TRACK)-release $(PACKAGES)

.PHONY: build

.upstream-$(TRACK)-release: scripts/get-upstream-release.sh
ifeq ($(RELEASE),)
	scripts/get-upstream-release.sh $(TRACK) >$@
else
	echo "$(RELEASE)" >$@
endif

# Ensure that Makefile gets re-loaded if .upstream-$(TRACK)-release was
# rebuilt, this way $(RELEASE) will be set to the correct value and does not
# need to be a recursively evaluated variable.
Makefile: .upstream-$(TRACK)-release
	touch $@

.NOTPARALLEL: .upstream-$(TRACK)-release

.SUFFIXES:

$(B)/$(DIST_TARBALL):
	mkdir -p $(@D)
	curl -Ssf $(DIST_TARBALL_URL) --output $@
	tar -C $(@D) -xzf $@

$(B)/$(DIST_BASE)/tailscale $(B)/$(DIST_BASE)/tailscaled: | $(B)/$(DIST_TARBALL) ;

$(B)/tailscale_$(PKG_SUFFIX)/data.tar.gz: $(B)/$(DIST_BASE)/tailscale
	mkdir -p $(@D)/data
	mkdir -m 0755 -p $(@D)/data/usr/sbin
	cp -p $< $(@D)/data/usr/sbin/tailscale
	$(IPK_TAR) -C $(@D)/data -czf $@ .

$(B)/tailscale_$(PKG_SUFFIX)/control.tar.gz: files/tailscale-control.in files/prerm files/postinst $(B)/tailscale_$(PKG_SUFFIX)/data.tar.gz
	mkdir -p $(@D)/control
	scripts/subst-control.sh $< $(PKG_VERSION) $(PKG_ARCH) $(@D)/data $(@D)/control/control
	cp files/prerm files/postinst $(@D)/control
	chmod 0755 $(@D)/control/prerm $(@D)/control/postinst
	$(IPK_TAR) -C $(@D)/control -czf $@ .

$(B)/tailscaled_$(PKG_SUFFIX)/data.tar.gz: $(B)/$(DIST_BASE)/tailscaled files/tailscale.init files/tailscale.conf
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

$(B)/tailscaled_$(PKG_SUFFIX)/control.tar.gz: files/tailscaled-control.in files/prerm files/postinst $(B)/tailscaled_$(PKG_SUFFIX)/data.tar.gz
	mkdir -p $(@D)/control
	scripts/subst-control.sh $< $(PKG_VERSION) $(PKG_ARCH) $(@D)/data $(@D)/control/control
	cp files/prerm files/postinst $(@D)/control
	chmod 0755 $(@D)/control/prerm $(@D)/control/postinst
	echo "/etc/config/tailscale" >$(@D)/control/conffiles
	$(IPK_TAR) -C $(@D)/control -czf $@ .

# Given control.tar.gz and data.tar.gz, build the containing .ipk
# NOTE that paths in the containing .ipk must start with ./ otherwise opkg fails
# in the configuration phase.
$(PACKAGES): $(B)/%.ipk: $(B)/%/data.tar.gz $(B)/%/control.tar.gz
	echo "2.0" > $(B)/$*/debian-binary
	$(IPK_TAR) -C $(B)/$* -czf $@ ./debian-binary ./control.tar.gz ./data.tar.gz

clean:
	$(RM) -r build

.PHONY: clean

# Installs built .ipk files to $(DESTDIR) and updates the feed metadata for all
# packages in the destination directory.
install: build
	mkdir -p $(DESTDIR)
	cp $(PACKAGES) $(DESTDIR)
	scripts/update-feed.sh $(DESTDIR)

.PHONY: install

distclean: clean
	$(RM) .upstream-*-release

.PHONY: distclean

# Shorthand for running periodically from e.g. cron; forces a refresh of
# .upstream-*-release and only reinstalls packages if it changed.
update:
	if ! test -d $(DESTDIR); then \
		$(MAKE) install; \
	else \
		$(RM) .upstream-$(TRACK)-release; \
		$(MAKE) -q build || $(MAKE) install; \
	fi

.PHONY: update
