#! /bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

. "$script_dir"/version.sh

image_name="${1}"
image_version="${2:-latest}"

echo
echo "### Building runtime-dependencies image"
echo "### (includes: alpine, runtime-linked libraries)"
echo

docker build \
       -f runtime-dependencies.Dockerfile \
       --build-arg BUILD_IMAGE="alpine:${alpine_version}" \
       --build-arg IMAGE_VERSION="${image_version}" \
       -t "$image_name:$image_version" \
       $repo_dir
