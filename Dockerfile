FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/freeswitch/bin:${PATH}"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"
# Add these BEFORE FreeSWITCH build:
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    pkg-config \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    bash \
    ca-certificates \
    gnupg \
    vim \
    nano \
    \
    iptables \
    iproute2 \
    net-tools \
    iputils-ping \
    procps \
    lsof \
    psmisc \
    telnet \
    dnsutils \
    tcpdump \
    strace \
    sudo \
    \
    libssl-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    libpcre3-dev \
    libpcre2-dev \
    libspeex-dev \
    libspeexdsp-dev \
    # libspandsp-dev \
    libldns-dev \
    uuid-dev \
    libpq-dev \
    libopus-dev \
    libsndfile1-dev \
    \
    libavformat-dev \
    libavcodec-dev \
    libavutil-dev \
    libavfilter-dev \
    libavdevice-dev \
    libpostproc-dev \
    libswscale-dev \
    \
    libjpeg-dev \
    libtiff-dev \
    libpng-dev \
    libvpx-dev \
    \
    libedit-dev \
    liblua5.3-dev \
    \
    libxml2-dev \
    libxslt1-dev \
    \
    libogg-dev \
    libvorbis-dev \
    libmpg123-dev \
    libsamplerate0-dev \
    \
    yasm \
    nasm \
    sox \
    libsox-dev \
    \
    libsrtp2-dev \
    librabbitmq-dev \
    \
    flite \
    flite-dev \
    \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
    
# libks
RUN git clone https://github.com/signalwire/libks.git /usr/src/libks && \
    cd /usr/src/libks && \
    cmake . && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /usr/src/libks
# signalwire-c
RUN git clone https://github.com/signalwire/signalwire-c.git /usr/src/signalwire-c && \
    cd /usr/src/signalwire-c && \
    cmake . && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /usr/src/signalwire-c
# spandsp
RUN git clone  https://github.com/freeswitch/spandsp.git /usr/src/spandsp && \
    cd /usr/src/spandsp && \
    ./bootstrap.sh && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /usr/src/spandsp
# sofia sip
RUN git clone https://github.com/freeswitch/sofia-sip.git /usr/src/sofia-sip && \
    cd /usr/src/sofia-sip && \
    ./bootstrap.sh && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /usr/src/sofia-sip
# FreeSWITCH source
RUN git clone --branch v1.10.12 --depth 1 \
    https://github.com/signalwire/freeswitch.git \
    /usr/src/freeswitch
WORKDIR /usr/src/freeswitch
# Copy custom modules configuration
COPY modules.conf /usr/src/freeswitch/modules.conf
RUN ./bootstrap.sh -j "$(nproc)" && \
    ./configure \
        --with-openssl \
        --with-pgsql && \
    make -j1 && \
    make install && \
    make sounds-install && \
    make moh-install && \
    test -x /usr/local/freeswitch/bin/freeswitch && \
    test -x /usr/local/freeswitch/bin/fs_cli && \
    /usr/local/freeswitch/bin/freeswitch -version && \
    rm -rf /usr/src/freeswitch
    
# Create freeswitch user and directories
RUN useradd -r -s /bin/false freeswitch && \
    mkdir -p /usr/local/freeswitch/run \
             /usr/local/freeswitch/log \
             /var/log/freeswitch && \
    chown -R freeswitch:freeswitch /usr/local/freeswitch /var/log/freeswitch
# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
WORKDIR /usr/local/freeswitch
# Expose ports
EXPOSE \
5060/udp \
5060/tcp \
5061/tcp \
8021/tcp \
16384-32768/udp
ENTRYPOINT ["/entrypoint.sh"]
# CMD ["-nonat", "-ncwait"]
