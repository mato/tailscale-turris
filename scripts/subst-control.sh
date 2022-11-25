#!/bin/sh

die()
{
	echo "ERROR: $@" >&2
	exit 1
}

if [ $# -ne 5 ]; then
	echo usage: $0 INPUT PKG_VERSION PKG_ARCH DATA_DIR OUTPUT >&2
	exit 1
fi

INPUT="$1"
DATA_DIR="$4"
OUTPUT="$5"
[ -f "${INPUT}" ] || die "${INPUT}: does not exist"
[ -d "${DATA_DIR}" ] || die "${DATA_DIR}: not a directory"

PKG_VERSION="$2"
PKG_ARCH="$3"
PKG_INSTALLED_SIZE=$(du -sb "${DATA_DIR}" | cut -f1)

sed -e "s!@@PKG_VERSION@@!${PKG_VERSION}!g" \
	-e "s!@@PKG_ARCH@@!${PKG_ARCH}!g" \
	-e "s!@@PKG_INSTALLED_SIZE@@!${PKG_INSTALLED_SIZE}!g" \
	${INPUT} >${OUTPUT} || exit 1

