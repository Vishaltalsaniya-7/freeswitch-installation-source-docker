# freeswitch-installation-source-docker
# FreeSWITCH 1.10.11 Source Build with Docker (Debian 11)

Build and run **FreeSWITCH v1.10.11** from source inside a **Debian 11 Slim** Docker container.

This project compiles FreeSWITCH from source along with all required libraries including:

- libks
- signalwire-c
- SpanDSP
- Sofia-SIP
- FreeSWITCH 1.10.11

The container is intended for development, testing, and production deployments where FreeSWITCH is built directly from source.

---

# Features

- Debian 11 Slim base image
- FreeSWITCH 1.10.11
- Builds everything from source
- Uses Docker Compose
- Host networking support
- Automatic sounds installation
- Automatic MOH installation
- Custom `modules.conf`
- Custom entrypoint
- Configurable FreeSWITCH password
- Ready for custom modules

---

# Directory Structure

```
.
├── DockerFile
├── docker-compose.yml
├── modules.conf
├── entrypoint.sh
└── README.md
```

---

# Requirements

- Docker 20+
- Docker Compose
- Linux Host (Recommended Ubuntu/Debian)

Host networking is recommended for SIP/RTP.

---

# Installed Packages

The Docker image installs:

- build-essential
- cmake
- git
- wget
- curl
- autoconf
- automake
- libtool
- OpenSSL
- SQLite
- Lua
- PostgreSQL
- Opus
- SpanDSP
- Sofia-SIP
- FFmpeg libraries
- SoX
- NASM
- YASM

as well as several networking and debugging utilities:

- vim
- nano
- tcpdump
- lsof
- net-tools
- telnet
- ping
- dnsutils
- strace
- sudo

---

# Libraries Built from Source

## libks

```
https://github.com/signalwire/libks
```

## signalwire-c

```
https://github.com/signalwire/signalwire-c
```

## SpanDSP

```
https://github.com/freeswitch/spandsp
```

## Sofia-SIP

```
https://github.com/freeswitch/sofia-sip
```

## FreeSWITCH

```
https://github.com/signalwire/freeswitch
```

Version:

```
v1.10.11
```

---

# Build Docker Image

```bash
docker compose build
```

or

```bash
docker build -t freeswitch:1.10.11 .
```

---

# Start Container

```bash
docker compose up -d
```

View logs

```bash
docker compose logs -f
```

---

# Docker Compose

This project uses **host networking**.

```yaml
network_mode: host
```

Host networking avoids SIP and RTP NAT issues.

---

# Default Installation Path

```
/usr/local/freeswitch
```

Configuration:

```
/usr/local/freeswitch/conf
```

Logs:

```
/usr/local/freeswitch/log
```

Runtime:

```
/usr/local/freeswitch/run
```

---

# Default Ports

| Port | Protocol | Purpose |
|-------|----------|----------|
| 5060 | UDP | SIP |
| 5060 | TCP | SIP |
| 5061 | TCP | SIP TLS |
| 8021 | TCP | Event Socket |
| 16384-32768 | UDP | RTP |

---

# FreeSWITCH Password

The Dockerfile changes the default Event Socket password.

Default:

```
1234
```

Configured password:

```
vspl@123
```

The change is applied automatically during the image build.

---

# Custom Modules

Replace the provided

```
modules.conf
```

with your own module list before building the image.

Example:

```
applications/mod_commands
applications/mod_dptools
endpoints/mod_sofia
formats/mod_sndfile
languages/mod_lua
```

---

# Sounds

Installed automatically during build.

```
make sounds-install
```

---

# Music On Hold

Installed automatically.

```
make moh-install
```

---

# Useful Commands

Open shell

```bash
docker exec -it freeswitch bash
```

FreeSWITCH CLI

```bash
fs_cli
```

Check status

```bash
fs_cli -x status
```

Reload XML

```bash
fs_cli -x reloadxml
```

Restart Sofia

```bash
fs_cli -x "sofia profile internal restart"
```

List calls

```bash
fs_cli -x "show calls"
```

---

# Rebuild

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

# Troubleshooting

## Check logs

```bash
docker logs freeswitch
```

or

```bash
fs_cli
```

---

## Verify SIP Port

```bash
netstat -tulpn
```

---

## Verify RTP Ports

```bash
ss -anu
```

---

## Verify Sofia

```bash
fs_cli -x "sofia status"
```

---

# Notes

- Built from official FreeSWITCH source.
- Uses Debian 11 Slim.
- Intended for development and production environments.
- Host networking is recommended for SIP deployments.
- Easily extendable with additional FreeSWITCH modules.

---

# License

FreeSWITCH is licensed under the MPL 1.1 license.

See the official project for details:

https://github.com/signalwire/freeswitch
