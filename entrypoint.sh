#!/bin/sh
set -e

# Set permissions
chown -R freeswitch:freeswitch /usr/local/freeswitch

exec /usr/local/freeswitch/bin/freeswitch \
    -u freeswitch \
    -g freeswitch \
    -nonat \
    -nf