# Tailscale packages for Turris OS
![CI](https://github.com/mato/tailscale-turris/workflows/CI/badge.svg)

Tailscale packages for Turris OS based on upstream precompiled [static
binaries](https://pkgs.tailscale.com/stable/#static).

## Disclaimer

You use everything here at your own risk. Make sure you have other network
paths to your router before installing this, in case something goes wrong.

Package signing and CA pinning of the feed server is not yet implemented.

Package hosting provided by Martin Lucina (@mato on Github), you can view the
repositories manually by browsing to https://pkgs-tailscale.lucina.net/.

## Issue Tracker

File packaging issues in this repository. For all other issues with Tailscale
on Turris OS please use the normal support channels.

## Installation

SSH into the router as root, and:

1. Install [tailscale.lua](tailscale.lua?raw=1) as `/etc/updater/conf.d/tailscale.lua`.
2. Run `pkgupdate` to install the packages. Update approvals are not required
   when running the updater from the command line.
3. Enable and start the `tailscaled` service with `service tailscaled enable &&
   service tailscaled start`.
4. Run `tailscale up` as you normally would.

If you have update approvals enabled, subsequent updates will need to be
approved via the web interface.

If you want to use the unstable release track instead, edit `tailscale.lua` to
suit.

## Upgrading

These packages use the same filesystem conventions as those in upstream
OpenWRT. Notably, `tailscaled.state` is located in `/etc/tailscale`. If you
have been previously using Tailscale on the router via a manual install from
static binaries and would like to preserve your node's existing identity in the
network, be sure to copy  your existing `tailscaled.state` to `/etc/tailscale`.

Upgrades from the OpenWRT upstream packages of Tailscale should work, but have
not been tested.

## Compatibility

The package is created based on Tailscale [static
binaries](https://pkgs.tailscale.com/stable/#static) which are confirmed to
work on Turris OS 5.x or later.

## Making packages

Requirements:
- GNU make
- GNU tar
- curl
- jq

To build packages of the latest upstream stable release run `make`. This will
produce packages of `tailscaled` and `tailscale` in `build/stable/`.

Set `TRACK=unstable` on the `make` command line to build the latest unstable
release instead, and/or `RELEASE=X.YY.Z` to build a specific release from the
release track as set in `TRACK`.  Refer to the [Makefile](Makefile) for further
targets, including those used to update package feeds.

## Credits

- Packaging based on the OpenWRT upstream
  [package](https://github.com/openwrt/packages/tree/openwrt-21.02/net/tailscale)
  by Ján Pavlinec of CZ.NIC.
