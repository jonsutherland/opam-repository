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

cat <<EOF > "$tmp_dir"/Dockerfile
FROM alpine:$alpine_version

# Metadata
LABEL org.label-schema.vendor="Nomadic Labs" \
      org.label-schema.url="https://www.nomadic-labs.com" \
      org.label-schema.name="Tezos" \
      org.label-schema.description="Tezos node" \
      org.label-schema.vcs-url=https://gitlab.com/tezos/tezos \
      org.label-schema.vcs-ref=$image_version \
      org.label-schema.docker.schema-version="1.0" \
      distro_style="apk" \
      distro="alpine" \
      distro_long="alpine-$alpine_version" \
      arch="x86_64" operatingsystem="linux"

COPY hidapi-$hidapi_version-r0.apk .
COPY keys /etc/apk/keys/

RUN apk --no-cache add libev gmp sudo hidapi-$hidapi_version-r0.apk && \
    rm hidapi-$hidapi_version-r0.apk

RUN adduser -S tezos && \
    echo 'tezos ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/tezos && \
    chmod 440 /etc/sudoers.d/tezos && \
    chown root:root /etc/sudoers.d/tezos && \
    sed -i.bak 's/^Defaults.*requiretty//g' /etc/sudoers && \
    mkdir -p /var/run/tezos/node /var/run/tezos/client && \
    sudo chown -R tezos /var/run/tezos

USER tezos
ENV USER=tezos

WORKDIR /home/tezos
EOF

docker build -t "$image_name:$image_version" "$tmp_dir"
