#!/bin/sh
# Download firmware images from a Github release.

set -eu

REPO="quel-inc/quel-firmwares"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/quelware/firmwares"
TARGZ_TEMP=$(mktemp)
PACKAGES_JSON_TEMP=$(mktemp)

trap 'rm -f "$TARGZ_TEMP" "$PACKAGES_JSON_TEMP"' EXIT

error_exit() {
  echo "Error: $1" >&2
  exit 1
}

download() {
  _url="$1"
  _dest="$2"
  echo "Downloading $(basename "$_url") to $_dest..."
  curl -L -sSf "$_url" -o "$_dest" || error_exit "Failed to download from $_url"
}

extract_from_targz() {
  echo "Extracting specified targets to $_dest..."
  mkdir -p "$DATA_DIR"
  cd "$DATA_DIR"
  while IFS= read -r target; do
    echo "Extracting $target from $TARGZ_TEMP"
    tar -xzf "$TARGZ_TEMP" "$target" || error_exit "Failed to extract $target from $TARGZ_TEMP"
  done
}

remove_existing_files() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    find "$_dir" -mindepth 1 -delete
  fi
}

get_archive_url() {
  _tag="$1"
  _api="https://api.github.com/repos/$REPO/releases"
  if [ -n "$_tag" ]; then
    _api="${_api}/tags/$_tag"
  else
    _api="${_api}/latest"
  fi
  curl -sSf "$_api" | jq -r '.assets[] | select(.name | startswith("archive.tar.gz")) | .browser_download_url'
}


show_usage() {
  cat << EOM >&2
Downloader of firmware images for QuEL devices.

Usage: $0 [-r] [-p <name>] [-t <tag>] [-y] [-h]

Options:
  -r            Remove all downloaded firmware images.
  -p <name>     Specify the name of the package to download directories for.
  -t <tag>      Specify a release tag to download. If not specified, the latest release is used.
  -y            Assume yes to all prompts.
  -h            Show this help message and exit.
EOM
}

REMOVE=false
TAG=
ASSUME_YES=false
PACKAGE_NAME="default"

while getopts "rp:t:yh" opt; do
  case "$opt" in
    r) REMOVE=true ;;
    p) PACKAGE_NAME="$OPTARG" ;;
    t) TAG="$OPTARG" ;;
    y) ASSUME_YES=true ;;
    h) show_usage; exit 0 ;;
    *) show_usage; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ "$REMOVE" = true ]; then
  echo "Removing firmware images from $DATA_DIR"
  remove_existing_files "$DATA_DIR"
  exit 0
fi

archive_url=$(get_archive_url "$TAG")
if [ -z "$archive_url" ]; then
  error_exit "archive.tar.gz file found in the latest/specified release."
fi

echo "Downloading archive..."
download "$archive_url" "$TARGZ_TEMP"

echo "Extracting package information..."
tar -xzf "$TARGZ_TEMP" "package.json" -O > "$PACKAGES_JSON_TEMP" || error_exit "Failed to extract package.json from $TARGZ_TEMP"

directories=$(jq -r ".packages[] | select(.name == \"$PACKAGE_NAME\") | .directories[]" < "$PACKAGES_JSON_TEMP")
[ -n "$directories" ] || error_exit "No package found with the name $PACKAGE_NAME."

if [ -d "$DATA_DIR" ] && [ -n "$(ls -A "$DATA_DIR")" ]; then
  response="yes"
  if [ "$ASSUME_YES" != true ]; then
    echo "Firmware images already exist in $DATA_DIR. Do you want to replace them? (yes/no) "
    read -r response
  fi
  if [ "$response" != "yes" ]; then
    echo "Download cancelled."
    exit 0
  fi
  echo "Replacing existing firmware images..."
  remove_existing_files "$DATA_DIR"
fi
echo "Downloading and extracting specified content for package '$PACKAGE_NAME'..."
echo "$directories" | extract_from_targz
echo "Specified content downloaded and extracted to $DATA_DIR"
