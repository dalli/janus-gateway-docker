FROM ubuntu:18.04
LABEL maintainer="SangKug Cha <skcha67@gmail.com>"

RUN apt update

ARG DEBIAN_FRONTEND=noninteractive

RUN apt install --no-install-recommends --no-install-suggests -y \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsrtp-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \ 
    libopus-dev \
    libogg-dev \
    libcurl4-openssl-dev \
    liblua5.3-dev \
    libconfig-dev \
    pkg-config \
    gengetopt \
    libtool \
    automake

RUN apt install --no-install-recommends --no-install-suggests -y \
    apt-transport-https \
    ca-certificates \
    cmake \
    git \
    gnupg1 \
    gtk-doc-tools \
    wget

RUN apt install --no-install-recommends --no-install-suggests -y \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel ninja-build
    
RUN pip3 install meson

RUN apt remove libnice-dev

RUN cd /tmp && \
    git clone https://gitlab.freedesktop.org/libnice/libnice.git && \
    cd libnice && \
    meson --prefix=/usr build && ninja -C build && ninja -C build install && \
    cd /tmp && \
    rm -rf libnice

RUN cd /tmp && \
    wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz && \
    tar xfv v2.2.0.tar.gz && \
    cd libsrtp-2.2.0 && \
    ./configure --prefix=/usr --enable-openssl && \
    make shared_library && make install && \
    cd /tmp && \
    rm -rf libsrtp-2.2.0

RUN cd /tmp && \
    git clone https://github.com/warmcat/libwebsockets.git && \
    cd libwebsockets && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
    make && make install && \
    cd /tmp && \
    rm -rf libwebsockets 

RUN cd /tmp && \
    git clone https://github.com/meetecho/janus-gateway.git && \
    cd janus-gateway && \
    git checkout tags/v0.10.3 && \
    ./autogen.sh && \
    ./configure --prefix=/opt/janus --disable-boringssl && \
    make && make install && \
    make configs && \
    cd /tmp && \
    rm -rf janus-gateway

WORKDIR /
