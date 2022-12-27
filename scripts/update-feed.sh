#!/bin/sh
# usage: update-feed.sh FEED_DIR
#
# Regenerates the pacakge feed index ("Packages") in FEED_DIR with metadata
# from all ipkg package files found in FEED_DIR.
#

die()
{
	echo "ERROR: $@" >&2
	exit 1
}

# Generate a Packages entry for a single .ipk package.
# Does the simplest thing that could possibly work: Extract the control file
# from the .ipk and add the minimal required metadata fields.
get_ipk_index_entry()
{
	[ $# -ne 1 ] && die "$0: get_ipk_index_entry(): invalid argument"
	[ ! -f "$1" ] && die "$0: get_ipk_index_entry(): not found: $1"
	ipk="$1"

	tmpdir="$(mktemp -d)"
	tar -C "${tmpdir}" -f "${ipk}" -xz ./control.tar.gz || return 1
	tar -C "${tmpdir}" -f "${tmpdir}/control.tar.gz" -xz ./control || return 1
	cat "${tmpdir}/control"
	echo "Size: $(stat -c %s ${ipk})"
	sha256sum="$(sha256sum ${ipk} | cut -d' ' -f1)"
	echo "SHA256sum: ${sha256sum}"
	echo "SHA256Sum: ${sha256sum}"
	echo "Filename: ${ipk}"
	rm -rf "${tmpdir}"
}

if [ $# -ne 1 ]; then
	echo usage: $0 FEED_DIR >&2
	exit 1
fi

FEED_DIR="$1"
[ -d "${FEED_DIR}" ] || die "${FEED_DIR}: not a directory"

cd "${FEED_DIR}"
packages=*.ipk

>Packages.new || die "could not create Packages.new"
for ipk in ${packages}; do
	get_ipk_index_entry "${ipk}" >>Packages.new
	echo >>Packages.new
done
mv Packages.new Packages || die "could not swap Packages"
