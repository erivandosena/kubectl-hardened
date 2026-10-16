#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <source-directory> <destination-directory>" >&2
  exit 2
fi

SRC="$1"
DEST="$2"

if [[ ! -d "$SRC" ]]; then
  echo "Source directory not found: $SRC" >&2
  exit 1
fi

if [[ ! -d "$DEST" ]]; then
  echo "Destination directory not found: $DEST" >&2
  exit 1
fi

if [[ ! -f "$SRC/go.work" || ! -f "$SRC/vendor/modules.txt" ]]; then
  echo "Source tree missing go.work or vendor/modules.txt" >&2
  exit 1
fi

SRC="$(cd "$SRC" && pwd -P)"
DEST="$(cd "$DEST" && pwd -P)"

# Prevent output from being written into the source tree.
if [[ "$DEST" == "$SRC" || "$DEST" == "$SRC/"* ]]; then
  echo "Destination must not be equal to or inside the source directory" >&2
  exit 1
fi

ARCHIVE="$DEST/kubernetes-v1.35.9-patched-go1.26.9-source.tar.gz"

if [[ -e "$ARCHIVE" || -e "$ARCHIVE.sha256" ]]; then
  echo "Archive or checksum already exists; refusing overwrite" >&2
  exit 1
fi

tar -czf "$ARCHIVE" -C "$(dirname "$SRC")" "$(basename "$SRC")"

gzip -t "$ARCHIVE"

sha256sum "$ARCHIVE" | tee "$ARCHIVE.sha256"

printf 'SOURCE_ARCHIVE=%s\n' "$ARCHIVE"
