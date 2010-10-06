#!/bin/bash
#
# Script de creation d'un nouveau client sur un serveur OpenVPN
# http://blog.nicolargo.com/2010/10/installation-dun-serveur-openvpn-sous-debianubuntu.html
#
# Nicolargo - 10/2010
# GPL
#
# Syntaxe: # sudo ./ovcreateclient.sh <nomduclient>
VERSION="0.1"

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0 <nomduclient>" 1>&2
  exit 1
fi

# Test parametre
if [ $# -ne 1 ]; then
  echo "Il faut saisir le nom du client: # sudo $0 <nomduclient>" 1>&2
  exit 1
fi

echo "---"
echo "Creation du client OpenVPN: $1"
echo "Entrer pour continuer ou CTRL-C pour annuler"
read key

cd /etc/openvpn/easy-rsa
source vars
./build-key $1
sudo mkdir /etc/openvpn/clientconf/$1
sudo cp /etc/openvpn/ca.crt /etc/openvpn/ta.key keys/$1.crt keys/$1.key /etc/openvpn/clientconf/$1/

cd /etc/openvpn/clientconf/$1
cat >> client.conf << EOF
# Client
client
dev tun
proto tcp-client
remote `wget -qO- whatismyip.org` 443
resolv-retry infinite
cipher AES-256-CBC
# Cles
ca ca.crt
cert $1.crt
key $1.key
tls-auth ta.key 1
# Securite
nobind
persist-key
persist-tun
comp-lzo
verb 3
EOF
sudo cp client.conf client.ovpn

sudo zip $1.zip *.*

echo "Creation du client OpenVPN $1 termine"
echo "/etc/openvpn/clientconf/$1/$1.zip" 
echo "---"
