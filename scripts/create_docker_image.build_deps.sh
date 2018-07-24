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

image_name="${1:-tezos_build_deps}"
image_version="${2:-latest}"
opam_image="${3:-$image_name/opam:$image_version}"

echo
echo "### Building build-dependencies image..."
echo

cp -a "$build_dir"/opam-$opam_version-r4.apk \
      "$build_dir"/hidapi-dev-$hidapi_version-r0.apk \
      "$build_dir"/keys/ \
      "$tmp_dir"

mkdir -p "$tmp_dir"/opam-repository
cp -a packages repo "$tmp_dir"/opam-repository

cat <<EOF > "$tmp_dir"/Dockerfile
FROM $opam_image

RUN opam depext --update --yes \$(opam list --all --short | grep -v ocaml-variants) && \
    opam install --yes \$(opam list --all --short | grep -v ocaml-variants)

EOF

docker build -t "$image_name:$image_version" "$tmp_dir"

