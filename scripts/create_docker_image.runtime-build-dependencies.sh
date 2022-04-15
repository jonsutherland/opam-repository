#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

# shellcheck source=scripts/version.sh
. "$script_dir"/version.sh

image_name="${1:-tezos_runtime-build-dependencies}"
image_version="${2:-latest}"
runtime_prebuild_dependencies_image="${3}"

echo
echo "### Building runtime-build-dependencies image"
echo "### (includes: rust dependencies, ocaml dependencies)"
echo

docker build \
       -f runtime-build-dependencies.Dockerfile \
       --build-arg BUILD_IMAGE="${runtime_prebuild_dependencies_image}" \
       -t "$image_name:$image_version" \
       "$repo_dir"
