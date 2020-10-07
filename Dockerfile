FROM ubuntu:18.04
LABEL maintainer="SangKug Cha <skcha67@gmail.com>"

RUN apt update

ARG DEBIAN_FRONTEND=noninteractive

RUN apt install --no-install-recommends --no-install-suggests -y \
    libmicrohttpd-dev \
    libjansson-dev \
    # libssl-dev \
    libsrtp-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \ 
    libopus-dev \
    libogg-dev \
    # libcurl4-openssl-dev \
    libcurl4-gnutls-dev \
    liblua5.3-dev \
    libconfig-dev \
    pkg-config \
    gengetopt \
    libtool \
    automake \
    gcc \
    g++ \
    flex \
    bison
    

RUN apt install --no-install-recommends --no-install-suggests -y \
    apt-transport-https \
    ca-certificates \
    cmake \
    git \
    gnupg1 \
    gtk-doc-tools \
    wget \
    apache2 \
    # nanomsg \
    nanomsg-utils \
    libssl1.0-dev \
    nodejs-dev \
    node-gyp \
    npm

# apache configuration
COPY ./apache2/apache2.conf /etc/apache2
COPY ./apache2/000-default.conf /etc/apache2/sites-available

RUN cd /tmp && \
    # wget https://sourceforge.net/projects/doxygen/files/rel-1.8.15/doxygen-1.8.15.src.tar.gz/download && \
    # tar xvfz download && \
    # cd doxygen-1.8.15 && \
    git clone https://github.com/doxygen/doxygen.git && \
    cd doxygen && \
    git checkout tags/Release_1_8_15 && \
    mkdir -v build && \
    cd build && \
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make && \
    make install && \
    rm -rf doxygen

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
    git checkout tags/v0.10.5 && \
    ./autogen.sh && \
    ./configure --prefix=/opt/janus --disable-boringssl --enable-all-js-modules && \
    make && make install && \
    make configs && \
    cd /tmp && \
    rm -rf janus-gateway

COPY ./conf/*.cfg /opt/janus/etc/janus/

WORKDIR /
ADD startup.sh /

EXPOSE 80 7088 8088 8188

CMD ["/startup.sh"]