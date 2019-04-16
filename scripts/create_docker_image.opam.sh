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
minimal_image="${3:-$image_name/minimal:$image_version}"

echo
echo "### Building minimal opam image..."
echo

cp -a "$build_dir"/opam-$opam_version-r0.apk \
      "$build_dir"/hidapi-dev-$hidapi_version-r0.apk \
      "$build_dir"/keys/ \
      "$tmp_dir"

mkdir -p "$tmp_dir"/opam-repository
cp -a packages repo "$tmp_dir"/opam-repository

cat <<EOF > "$tmp_dir"/Dockerfile
FROM $minimal_image

COPY keys /etc/apk/keys/
COPY hidapi-dev-$hidapi_version-r0.apk .
COPY opam-$opam_version-r0.apk .

USER root
RUN apk --no-cache add \
        build-base bash perl xz m4 git curl tar rsync patch jq \
        ncurses-dev gmp-dev libev-dev \
        hidapi-dev-$hidapi_version-r0.apk \
        opam-$opam_version-r0.apk && \
    rm hidapi-dev-$hidapi_version-r0.apk \
       opam-$opam_version-r0.apk

USER tezos
WORKDIR /home/tezos

COPY --chown=tezos:nogroup opam-repository/repo opam-repository/

COPY --chown=tezos:nogroup \
      opam-repository/packages/ocaml \
      opam-repository/packages/ocaml-config \
      opam-repository/packages/ocaml-base-compiler \
      opam-repository/packages/base-bigarray \
      opam-repository/packages/base-bytes \
      opam-repository/packages/base-unix \
      opam-repository/packages/base-threads \
      opam-repository/packages/

RUN cd opam-repository && opam admin cache

RUN mkdir ~/.ssh && \
    chmod 700 ~/.ssh && \
    git config --global user.email "ci@tezos.com" && \
    git config --global user.name "Tezos CI" && \
    opam init --disable-sandboxing --no-setup --yes \
              --compiler ocaml-base-compiler.${ocaml_version} \
              tezos /home/tezos/opam-repository

COPY --chown=tezos:nogroup opam-repository opam-repository

RUN cd opam-repository && \
       opam admin cache && \
       opam update && \
       opam install opam-depext

ENTRYPOINT [ "opam", "exec", "--" ]
CMD [ "/bin/sh" ]
EOF

docker build -t "$image_name:$image_version" "$tmp_dir"

