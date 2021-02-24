# OpenVPN Install

This repository is a rewrite of [Angristan](https://github.com/angristan) [OpenVPN-install](https://github.com/angristan/OpenVPN-install) script.

OpenVPN installer for Debian, Ubuntu, Fedora, CentOS and Arch Linux.

## Installation

```bash
curl -O https://raw.githubusercontent.com/panelssh/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
./openvpn-install.sh
```

## Add Client User VPN

```bash
# without password
addvpn [clinet-name]

# without password
addvpn [clinet-name] [password]
```
## Remove Client User VPN

```bash
delvpn [clinet-name]
```
