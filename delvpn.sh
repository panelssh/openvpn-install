#!/bin/bash

if [ "$1" == "" ]; then
    echo -e "You Must Put Client Name!"
    exit 1
fi

CLIENT_NAME=$1

cd /etc/openvpn/easy-rsa/ || return

./easyrsa --batch revoke "$CLIENT_NAME"

EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl

rm -f /etc/openvpn/crl.pem

cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem

chmod 644 /etc/openvpn/crl.pem

find /home/ -maxdepth 2 -name "$CLIENT_NAME.ovpn" -delete

rm -f "/root/$CLIENT_NAME.ovpn"

sed -i "/^$CLIENT_NAME,.*/d" /etc/openvpn/ipp.txt
