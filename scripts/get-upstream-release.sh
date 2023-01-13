#!/bin/sh
# usage: get-upstream-release.sh TRACK [ ARCH ]
#
# Returns the latest available upstream static binary release for the specified
# release TRACK ("stable" or "unstable").
# ARCH defaults to "arm".
#
# Dependencies: curl, jq

die()
{
	echo "ERROR: $@" >&2
	exit 1
}

if [ $# -lt 1 ]; then
	echo usage: $0 TRACK [ ARCH ]>&2
	exit 1
fi

TRACK="$1"
ARCH="${2:-arm}"
JSON=$(curl -Ssf "https://pkgs.tailscale.com/${TRACK}/?mode=json") \
	|| die "could not retreive latest release from server"
TARBALL=$(echo "${JSON}" | jq -r ".Tarballs.${ARCH}") \
	|| die "could not parse JSON response"
RELEASE=$(echo "${TARBALL}" | cut -d_ -f2) \
	|| die "could not parse JSON response"
if [ -z "${RELEASE}" -o "${RELEASE}" = "null" ]; then
       	die "could not parse JSON response: ${RELEASE}"
fi
echo "${RELEASE}"
