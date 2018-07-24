#!/bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

. "$script_dir"/version.sh

build_dir=${build_dir:-_docker_build}

if [ -f "$build_dir"/opam-$opam_version-r4.apk ] && \
   [ -f "$build_dir"/opam-doc-$opam_version-r4.apk ] && \
   [ -d "$build_dir"/keys/ ] ; then
    exit 0
fi

tmp_image="${1:-tezos_build_deps/opam.apk}"
tmp_dir=$(mktemp -dt tezos.opam.XXXXXXXX)
cleanup () {
    set +e
    rm -rf "$tmp_dir"
    if ! [ -z "$container" ]; then docker rm $container; fi
    # docker rmi $tmp_image || true
}
trap cleanup EXIT INT

cp -a "$script_dir"/opam-$opam_version.APKBUILD "$tmp_dir"/APKBUILD

cat <<EOF > "$tmp_dir/Dockerfile"
FROM andyshinn/alpine-abuild:v4
ENV PACKAGER "Tezos <ci@tezos.com>"
WORKDIR /home/builder/
RUN abuild-keygen -a -i
COPY APKBUILD .
RUN abuilder -r
EOF

echo
echo "### Building opam..."
echo

## may pull cache...
docker pull $tmp_image:$opam_tag || true > /dev/null 2>&1

docker build \
       --cache-from $tmp_image:$opam_tag \
       -t $tmp_image:$opam_tag "$tmp_dir"

mkdir -p "$build_dir"

container=$(docker create $tmp_image:$opam_tag)
docker cp -L $container:/etc/apk/keys "$build_dir"
docker cp -L $container:/packages/home/x86_64/opam-$opam_version-r4.apk \
             "$build_dir"
docker cp -L $container:/packages/home/x86_64/opam-doc-$opam_version-r4.apk \
             "$build_dir"
