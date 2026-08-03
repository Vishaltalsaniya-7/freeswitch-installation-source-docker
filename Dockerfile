FROM debian:11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/freeswitch/bin:$PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"

# RUN apt-get update && apt-get install -y \
#     build-essential cmake git wget curl pkg-config \
#     libtool libtool-bin autoconf automake bash \
#     ca-certificates gnupg \
#     libssl-dev libsqlite3-dev libcurl4-openssl-dev \
#     libpcre2-dev libspeex-dev libspeexdsp-dev \
#     libsofia-sip-ua-dev libldns-dev uuid-dev \
#     libpq-dev libopus-dev libsndfile1-dev \
#     libavformat-dev libavcodec-dev libavutil-dev \
#     libswscale-dev libjpeg-dev libtiff-dev \
#     libedit-dev liblua5.3-dev \
#     yasm nasm sox libsox-dev libsox-fmt-all \
#     su-exec \
#     && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    build-essential cmake git wget curl pkg-config \
    libtool libtool-bin autoconf automake bash \
    ca-certificates gnupg \
    vim nano \
    iptables iproute2 \
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
    libssl-dev libsqlite3-dev libcurl4-openssl-dev \
    libpcre3-dev libspeex-dev libspeexdsp-dev \
    libldns-dev uuid-dev \
    libpq-dev libopus-dev libsndfile1-dev \
    libavformat-dev libavcodec-dev libavutil-dev \
    libswscale-dev libjpeg-dev libtiff-dev \
    libedit-dev liblua5.3-dev \
    yasm nasm sox libsox-dev \
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
RUN git clone https://github.com/freeswitch/spandsp.git /usr/src/spandsp && \
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
RUN git clone --branch v1.10.11 --depth 1 \
    https://github.com/signalwire/freeswitch.git \
    /usr/src/freeswitch

WORKDIR /usr/src/freeswitch

# Copy custom modules configuration
COPY modules.conf /usr/src/freeswitch/modules.conf

# RUN ./bootstrap.sh -j && \
#       ldconfig && \
#     ./configure \
#     make -j$(nproc) && \
#     make install && \
#     RUN ln -s /usr/local/freeswitch/etc/freeswitch /usr/local/freeswitch/conf
#     make sounds-install && \
#     make moh-install && \
#     rm -rf /usr/src/freeswitch
RUN ./bootstrap.sh -j $(nproc) && \
    ldconfig && \
    ./configure \
        --prefix=/usr/local/freeswitch \
        --with-openssl && \
    make -j$(nproc) && \
    make install && \
    ln -s /usr/local/freeswitch/etc/freeswitch /usr/local/freeswitch/conf && \
    sed -i 's|default_password=1234|default_password=vspl@123|g' \
        /usr/local/freeswitch/conf/vars.xml && \
    make sounds-install && \
    make moh-install && \
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

# Expose ports
EXPOSE \
5060/udp \
5060/tcp \
5061/tcp \
8021/tcp \
16384-32768/udp

ENTRYPOINT ["/entrypoint.sh"]
# CMD ["-nonat", "-ncwait"]