#! /bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

. "$script_dir"/version.sh

tmp_dir=$(mktemp -dt tezos.opam.tezos.XXXXXXXX)

cleanup () {
    set +e
    echo Cleaning up...
    rm -rf "$tmp_dir"
}
trap cleanup EXIT INT

image_name="${1:-tezos_build_deps}"
image_version="${2:-latest}"
opam_image="${3:-$image_name/opam:$image_version}"

echo
echo "### Building build-dependencies image..."
echo

mkdir -p "$tmp_dir"/opam-repository
cp -a packages repo "$tmp_dir"/opam-repository

cp $script_dir/Dockerfile_build_deps.template $tmp_dir/Dockerfile
docker build \
       --build-arg BUILD_IMAGE=${opam_image} \
       -t "$image_name:$image_version" \
       $tmp_dir

