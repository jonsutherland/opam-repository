ARG BUILD_IMAGE

FROM ${BUILD_IMAGE}

ARG OCAML_VERSION

USER root
RUN apk --no-cache add \
        build-base bash perl xz m4 git curl tar rsync patch jq \
        py-pip python3 python3-dev coreutils \
        py3-sphinx py3-sphinx_rtd_theme \
        ncurses-dev gmp-dev libev-dev opam \
        hidapi-dev libffi-dev

COPY scripts/python_deps/requirements.txt ./python_requirements.txt

RUN pip install --upgrade pip
RUN pip3 install -r python_requirements.txt && \
  pip3 uninstall --yes idna && \
  pip3 install 'idna<2.7'

USER tezos
WORKDIR /home/tezos

COPY --chown=tezos:nogroup repo opam-repository/

COPY --chown=tezos:nogroup \
      packages/ocaml \
      packages/ocaml-config \
      packages/ocaml-base-compiler \
      packages/base-bigarray \
      packages/base-bytes \
      packages/base-unix \
      packages/base-threads \
      opam-repository/packages/

RUN cd opam-repository && opam admin cache

RUN mkdir ~/.ssh && \
    chmod 700 ~/.ssh && \
    git config --global user.email "ci@tezos.com" && \
    git config --global user.name "Tezos CI" && \
    opam init --disable-sandboxing --no-setup --yes \
              --compiler ocaml-base-compiler.${OCAML_VERSION} \
              tezos /home/tezos/opam-repository

COPY --chown=tezos:nogroup packages opam-repository/packages

RUN cd opam-repository && \
       opam admin cache && \
       opam update && \
       opam install opam-depext && \
       opam clean

ENTRYPOINT [ "opam", "exec", "--" ]
CMD [ "/bin/sh" ]
