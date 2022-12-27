This repository contains tooling to build packages of Tailscale suitable for
use with Turris OS using the static binaries provided by upstream (Tailscale
Inc.) at https://pkgs.tailscale.com/.

Building the packages
---------------------

Requirements:
- GNU make
- GNU tar
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

Automatic updates using a custom package feed
---------------------------------------------

**Serving up a custom package feed**

For this to work, you need a HTTPS-enabled static web server to host the custom
package feed. The tools currently need to be run on the web server host.

Run `make update-feed PKG_FEED_DEST=/some/path` where _/some/path_ is the
destination directory for your custom package feed. This will build the
packages, copy them to the destination directory and update the feed metadata
(`Packages`).

**Configuring your router to use the custom package feed**

Install `tailscale.lua` to your router as `/etc/updater/conf.d/tailscale.lua`
and follow the instructions in it.

To test that updates are working as expected, run 'pkgupdate' on the router
from the CLI.

NOTE: Package and feed signing/verification is not supported yet, use at your
own risk.

Feedback
--------

Discuss at https://forum.turris.cz/t/experimental-tailscale-packages-using-upstream-binaries/18276.
