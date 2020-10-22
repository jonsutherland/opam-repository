#! /bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

. "$script_dir"/version.sh

image_name="${1:-tezos_build_deps/minimal}"
image_version="${2:-latest}"

echo
echo "### Building minimal alpine image..."
echo

docker build \
       -f minimal.Dockerfile \
       --build-arg BUILD_IMAGE="alpine:${alpine_version}" \
       -t "$image_name:$image_version" \
       $repo_dir
