ARG BASE_IMAGE=golang:latest
FROM ${BASE_IMAGE} as base

SHELL [ "/bin/bash", "-c" ]

FROM base as builder
# https://github.com/containers/skopeo/blob/master/install.md#building-without-a-container
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
        libgpgme-dev \
        libassuan-dev \
        btrfs-progs \
        libdevmapper-dev \
        libostree-dev \
        sudo && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt-get/lists/*

ARG VERSION_TAG=v1.1.0
RUN git clone --depth 1 https://github.com/containers/skopeo \
      --branch "${VERSION_TAG}" \
      --single-branch \
      $GOPATH/src/github.com/containers/skopeo && \
    cd $GOPATH/src/github.com/containers/skopeo && \
    make binary-local && \
    mkdir -p /etc/containers && \
    cp default-policy.json /etc/containers/policy.json && \
    ./skopeo --help

FROM base
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
        libgpgme-dev \
        libassuan-dev \
        libbtrfs-dev \
        libdevmapper-dev \
        sudo && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt-get/lists/*
# Create user "docker" with sudo powers
RUN useradd -m docker && \
    usermod -aG sudo docker && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    cp /root/.bashrc /home/docker/ && \
    chown -R --from=root docker /home/docker

COPY --from=builder $GOPATH/src/github.com/containers/skopeo/skopeo /usr/local/bin/
COPY --from=builder $GOPATH/src/github.com/containers/skopeo/default-policy.json /etc/containers/policy.json

WORKDIR /home/docker
ENV HOME /home/docker
ENV USER docker
USER docker

CMD [ "/bin/bash" ]
