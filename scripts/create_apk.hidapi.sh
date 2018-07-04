#!/bin/sh

set -e

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

. "$script_dir"/version.sh

build_dir=${build_dir:-_docker_build}

if [ -f "$build_dir"/hidapi-$hidapi_version-r0.apk ] && \
   [ -f "$build_dir"/hidapi-dev-$hidapi_version-r0.apk ] && \
   [ -d "$build_dir"/keys/ ] ; then
    exit 0
fi

tmp_image="${1:-tezos_build_deps/hidapi.apk}"
tmp_dir=$(mktemp -dt tezos.hidapi.XXXXXXXX)
cleanup () {
    set +e
    rm -rf "$tmp_dir"
    if ! [ -z "$container" ]; then docker rm $container; fi
    # docker rmi $tmp_image || true
}
trap cleanup EXIT INT

cp -a "$script_dir"/hidapi-$hidapi_version.APKBUILD "$tmp_dir"/APKBUILD

cat <<EOF > "$tmp_dir/Dockerfile"
FROM andyshinn/alpine-abuild:v4
ENV PACKAGER "Tezos <ci@tezos.com>"
WORKDIR /home/builder/
RUN abuild-keygen -a -i
COPY APKBUILD .
RUN abuilder -r
EOF

echo
echo "### Building hidapi..."
echo

## may pull cache...
docker pull $tmp_image:$hidapi_version || true > /dev/null 2>&1

docker build \
       --cache-from $tmp_image:$hidapi_version \
       -t $tmp_image:$hidapi_version "$tmp_dir"

mkdir -p "$build_dir"

container=$(docker create $tmp_image:$hidapi_version)
docker cp -L $container:/etc/apk/keys "$build_dir"
docker cp -L $container:/packages/home/x86_64/hidapi-$hidapi_version-r0.apk \
             "$build_dir"
docker cp -L $container:/packages/home/x86_64/hidapi-dev-$hidapi_version-r0.apk \
             "$build_dir"
