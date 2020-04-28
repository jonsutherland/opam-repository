#! /bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

. "$script_dir"/version.sh

image_name="${1:-tezos_build_deps}"
image_version="${2:-latest}"
opam_image="${3:-$image_name/opam:$image_version}"

echo
echo "### Building build-dependencies image..."
echo

docker build \
       --build-arg BUILD_IMAGE=${opam_image} \
       -t "$image_name:$image_version" \
       $repo_dir

