ARG BUILD_IMAGE

FROM ${BUILD_IMAGE}

ARG OCAML_VERSION
ARG RUST_VERSION
ARG PYTHON_VERSION

USER root
RUN apk --no-cache add \
        build-base bash perl xz m4 git curl tar rsync patch jq \
        py3-pip python3 python3-dev coreutils \
        py3-sphinx py3-sphinx_rtd_theme \
        ncurses-dev gmp-dev libev-dev opam \
        openssl-dev \
        hidapi-dev libffi-dev cargo

# Check versions of other interpreters/compilers
RUN test $(python3 --version | cut -d ' ' -f2) = ${PYTHON_VERSION}
RUN test $(rustc --version | cut -d' ' -f2) = ${RUST_VERSION}

### Begin Rust dependencies compilation
COPY rust rust
RUN RUSTFLAGS='-C target-feature=-crt-static' cargo build --release --manifest-path ./rust/Cargo.toml

# librustzcash
RUN cp rust/target/release/librustzcash.a /usr/lib/
RUN cp rust/librustzcash/include/librustzcash.h /usr/include/

# rustc-bls12-381
RUN cp rust/rustc-bls12-381/include/rustc_bls12_381.h /usr/include/
RUN cp rust/target/release/librustc_bls12_381.a /usr/lib/

RUN rm -rf rust
### End Rust dependencies compilation

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

### Begin Python setup
# Install poetry (https://github.com/python-poetry/poetry)
RUN pip3 install --user poetry==1.0.10

# Required to have poetry in the path in the CI
ENV PATH="/home/tezos/.local/bin:${PATH}"

# Copy poetry files to install the dependencies in the docker image
COPY poetry.lock poetry.lock
COPY pyproject.toml pyproject.toml

# Poetry will create the virtual environment in $(pwd)/.venv.
# The containers running this image can load the virtualenv with
# $(pwd)/.venv/bin/activate and do not require to run `poetry install`
# It speeds up the Tezos CI and simplifies the .gitlab-ci.yml file
# by avoiding duplicated poetry setup checks.
RUN poetry config virtualenvs.in-project true
RUN poetry install
### End Python setup

ENTRYPOINT [ "opam", "exec", "--" ]
CMD [ "/bin/sh" ]
