#! /bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

. "$script_dir"/version.sh

export build_dir=${build_dir:-_docker_build}
tmp_dir=$(mktemp -dt tezos.opam.tezos.XXXXXXXX)

cleanup () {
    set +e
    echo Cleaning up...
    rm -rf "$tmp_dir"
}
trap cleanup EXIT INT

image_name="${1:-tezos_build_deps/minimal}"
image_version="${2:-latest}"

echo
echo "### Building minimal alpine image..."
echo

cp -a "$build_dir"/hidapi-$hidapi_version-r0.apk \
      "$build_dir"/keys/ \
      "$tmp_dir"

cp $script_dir/Dockerfile_minimal.template $tmp_dir/Dockerfile
docker build \
       --build-arg BUILD_IMAGE="alpine:${alpine_version}" \
       --build-arg HIDAPI_VERSION=${hidapi_version} \
       --build-arg IMAGE_VERSION=${image_version} \
       -t "$image_name:$image_version" \
       $tmp_dir
