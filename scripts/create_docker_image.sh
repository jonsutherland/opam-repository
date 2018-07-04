#! /bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

image_name="${1:-tezos_build_deps}"
image_version="${2:-latest}"

"$script_dir"/create_apk.hidapi.sh "$image_name/hidapi.apk"
"$script_dir"/create_apk.opam.sh "$image_name/opam.apk"

## may pull cache...
docker pull "registry.gitlab.com/tezos/opam-repository:master" || true > /dev/null 2>&1

"$script_dir"/create_docker_image.minimal.sh \
             "$image_name" "minimal--$image_version"

"$script_dir"/create_docker_image.opam.sh \
             "$image_name" "opam--$image_version" \
             "$image_name:minimal--$image_version"

"$script_dir"/create_docker_image.build_deps.sh \
             "$image_name" "$image_version" \
             "$image_name:opam--$image_version"

