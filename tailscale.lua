--[[
Tailscale packages for Turris OS.

Based on the upstream precompiled static binaries at
https://pkgs.tailscale.com/.

Packaging-specific documentation can be found at
https://github.com/mato/tailscale-turris/.

Package hosting provided by Martin Lucina (Github: @mato).
]]

-- To use the unstable release track, replace /stable with /unstable below.
Repository("tailscale", "https://pkgs-tailscale.lucina.net/stable", { ca = {}, crl = {}, ocsp = false})
Install("tailscaled", "tailscale", { repository = {"tailscale"} })
