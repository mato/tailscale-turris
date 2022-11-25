This repository contains tooling to build packages of Tailscale suitable for
use with Turris OS using the static binaries provided by upstream (Tailscale
Inc.) at https://pkgs.tailscale.com/.

Building the packages
---------------------

Requirements:
- GNU make
- curl

To build. run `make`. This will produce packages of `tailscaled` and
`tailscale` in `build/`.

Installing on the Turris Omnia
------------------------------

1. Copy both packages to the router via SSH and install them with `opkg install`.
2. Enable and start the `tailscaled` service with `service tailscaled enable && service tailscaled start`.
3. Run `tailscale up [ OPTIONS ... ]` as you normally would.

These packages use the same filesystem conventions as those in upstream
OpenWRT. Notably, `tailscaled.state` is located in `/etc/tailscale`. If you
have been previously using Tailscale on the router via a manual install from
static binaries and would like to preserve your node's existing identity in the
network, be sure to copy  your existing `tailscaled.state` to `/etc/tailscale`.

Upgrades from the OpenWRT upstream packages of Tailscale should work, but have
not been tested.

