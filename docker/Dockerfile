FROM ubuntu:18.04 as intermediate

# Add metadata identifying this image as an
# intermediate build image so that we can
# clean it up from our host after a successful
# build
LABEL stage=intermediate

RUN apt-get update -qq && apt-get upgrade -qq && apt-get install -qq \
  build-essential git gdb cmake libudev-dev \
  curl wget unzip \
  pkg-config software-properties-common \
  python python-pyelftools \
  # for rust openssl
  libssl-dev libcurl4-openssl-dev \
  # for rocksdb
  libsnappy-dev librocksdb-dev \
  # for benchmarks
  python3-prometheus-client \
  # convenience
  golang

ENV HOME="/root"
ENV PATH="${HOME}/.cargo/bin:${PATH}"

# install rust version that we have validated against our tools
RUN curl "https://sh.rustup.rs" -sfo rustup.sh && \
  sh rustup.sh -y --default-toolchain nightly-2018-10-01

ARG GITHUB_USER
ARG GITHUB_TOKEN

ARG PARITY_ETHEREUM_COMMIT_SHA
ARG PARITY_ETHEREUM_BUILD_IMAGE_TAG

LABEL com.oasislabs.parity-ethereum-commit-sha="${PARITY_ETHEREUM_COMMIT_SHA}"
LABEL com.oasislabs.parity-ethereum-build-image-tag="${PARITY_ETHEREUM_BUILD_IMAGE_TAG}"

WORKDIR /code

RUN git config --global credential.helper store && \
  git config --global credential.https://github.com.username ${GITHUB_USER} && \
  echo "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com" > ~/.git-credentials

RUN rustup target add wasm32-unknown-unknown && \
  cargo install --force --git https://github.com/oasislabs/owasm-utils.git && \
  cargo install --force --features evm-debug --git https://github.com/oasislabs/parity-ethereum parity-ethereum --bin parity

FROM ubuntu:18.04

COPY --from=intermediate /root/.cargo/bin /root/.cargo/bin

