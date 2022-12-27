--[[
Tailscale updates.

Copy this file to your Turris Omnia as /etc/updater/conf.d/tailscale.lua, edit
the URL to suit and uncomment the commands below.

To test that updates are working as expected, run 'pkgupdate' on the router
from the CLI.

Updater language reference: https://gitlab.nic.cz/turris/updater/updater/-/blob/master/docs/language.txt
]]

--Repository("tailscale", "https://your-repo.example.com/", { ca = {}, crl = {}, ocsp = false})
--Install("tailscaled", "tailscale", { repository = {"tailscale"} })
