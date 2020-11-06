# runtime + build dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
# - opam build-dependencies
#
# This image is intended for
# - building tezos from source
# - building the runtime-build-test-dependencies image


ARG BUILD_IMAGE

FROM ${BUILD_IMAGE}

RUN opam depext --update --yes $(opam list --all --short | grep -v ocaml-variants)
RUN opam install --yes $(opam list --all --short | grep -v ocaml-variants)
