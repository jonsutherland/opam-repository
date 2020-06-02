ARG BUILD_IMAGE

FROM ${BUILD_IMAGE}

ARG OCAML_VERSION
ARG RUST_VERSION

USER root
RUN apk --no-cache add \
        build-base bash perl xz m4 git curl tar rsync patch jq \
        py-pip python3 python3-dev coreutils \
        py3-sphinx py3-sphinx_rtd_theme \
        ncurses-dev gmp-dev libev-dev opam \
        hidapi-dev libffi-dev cargo

RUN test $(rustc --version | cut -d' ' -f2) = ${RUST_VERSION}
COPY rust rust
RUN RUSTFLAGS='-C target-feature=-crt-static' cargo build --release --manifest-path ./rust/Cargo.toml

# librustzcash
RUN cp rust/target/release/librustzcash.a /usr/lib/
RUN cp rust/librustzcash/include/librustzcash.h /usr/include/

# rustc-bls12-381
RUN cp rust/rustc-bls12-381/include/rustc_bls12_381.h /usr/include/
RUN cp rust/target/release/librustc_bls12_381.a /usr/lib/

RUN rm -rf rust

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
