#!/bin/sh
set -eu

PWD="$(pwd)"
REPO_ROOT="$(cd "$(dirname "$0")"; cd ..; pwd)"
ARCHIVE=$PWD/archive.tar.gz

if [ -f "$ARCHIVE" ]; then
  echo "$ARCHIVE already exists."
  exit 1
fi

cd "$REPO_ROOT"

tar -czvf "$ARCHIVE" --exclude='*.ltx' plain_bits package.json 

echo "Archive created: $ARCHIVE"
