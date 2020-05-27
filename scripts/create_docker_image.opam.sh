#! /bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

. "$script_dir"/version.sh

image_name="${1:-tezos_build_deps}"
image_version="${2:-latest}"
minimal_image="${3:-$image_name/minimal:$image_version}"

echo
echo "### Building minimal opam image..."
echo

docker build \
       -f opam.Dockerfile \
       --build-arg BUILD_IMAGE=${minimal_image} \
       --build-arg OCAML_VERSION=${ocaml_version} \
       --build-arg RUST_VERSION=${rust_version} \
       -t "$image_name:$image_version" \
       $repo_dir
