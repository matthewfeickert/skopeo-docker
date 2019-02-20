FROM golang:latest

SHELL [ "/bin/bash", "-c" ]

# https://github.com/containers/skopeo#building-without-a-container
RUN apt-get -qq -y update && \
    apt-get -qq -y upgrade && \
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

RUN git clone --depth 1 https://github.com/containers/skopeo $GOPATH/src/github.com/containers/skopeo && \
    cd $GOPATH/src/github.com/containers/skopeo && \
    make binary-local && \
    mkdir -p /etc/containers && \
    cp default-policy.json /etc/containers/policy.json && \
    ./skopeo --help

# Create user "docker" with sudo powers
RUN useradd -m docker && \
    usermod -aG sudo docker && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    cp /root/.bashrc /home/docker/ && \
    chown -R --from=root docker /home/docker

RUN mv $GOPATH/src/github.com/containers/skopeo/skopeo /home/docker/skopeo

WORKDIR /home/docker
ENV HOME /home/docker
ENV USER docker
USER docker
ENV PATH /home/docker/.local/bin:$PATH

CMD [ "/bin/bash" ]
