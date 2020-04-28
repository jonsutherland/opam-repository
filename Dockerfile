ARG BUILD_IMAGE

FROM ${BUILD_IMAGE}

RUN opam depext --update --yes $(opam list --all --short | grep -v ocaml-variants)
RUN opam install --yes $(opam list --all --short | grep -v ocaml-variants)
