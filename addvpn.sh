#!/bin/bash

if [ "$1" == "" ]; then
    echo -e "You Must Put Client Name!"
    exit 1
fi

CLIENT_NAME=$1

CLIENT_NAME_EXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "/CN=$CLIENT_NAME\$")
if [[ $CLIENT_NAME_EXISTS == '1' ]]; then
  echo "The specified client CN was already found in easy-rsa, please choose another name."
  exit 2
fi

cd /etc/openvpn/easy-rsa/ || return

if [ "$2" == "" ]; then
    # Without Password
    ./easyrsa build-client-full "$CLIENT_NAME" nopass
else
	# With Password
    ./easyrsa-nostdin build-client-full "$CLIENT_NAME" <<EOF
$2
$2
EOF
fi

# Home directory of the user, where the client configuration (.ovpn) will be written
if [ -e "/home/$CLIENT_NAME" ]; then # if $1 is a user name
	HOME_DIR="/home/$CLIENT_NAME"
elif [ "${SUDO_USER}" ]; then # if not, use SUDO_USER
	HOME_DIR="/home/${SUDO_USER}"
else # if not SUDO_USER, use /root
	HOME_DIR="/root"
fi

# Determine if we use tls-auth or tls-crypt
if grep -qs "^tls-crypt" /etc/openvpn/server.conf; then
	TLS_SIG="1"
elif grep -qs "^tls-auth" /etc/openvpn/server.conf; then
	TLS_SIG="2"
fi

# Generates the custom client.ovpn
cp /etc/openvpn/client-template.txt "$HOME_DIR/$CLIENT_NAME.ovpn"
{
	echo "<ca>"
	cat "/etc/openvpn/easy-rsa/pki/ca.crt"
	echo "</ca>"

	echo "<cert>"
	awk '/BEGIN/,/END/' "/etc/openvpn/easy-rsa/pki/issued/$CLIENT_NAME.crt"
	echo "</cert>"

	echo "<key>"
	cat "/etc/openvpn/easy-rsa/pki/private/$CLIENT_NAME.key"
	echo "</key>"

	case $TLS_SIG in
	1)
		echo "<tls-crypt>"
		cat /etc/openvpn/tls-crypt.key
		echo "</tls-crypt>"
		;;
	2)
		echo "key-direction 1"
		echo "<tls-auth>"
		cat /etc/openvpn/tls-auth.key
		echo "</tls-auth>"
		;;
	esac
} >>"$HOME_DIR/$CLIENT_NAME.ovpn"
