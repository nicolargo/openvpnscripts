#!/bin/bash
#
# Script de creation d'un nouveau client sur un serveur OpenVPN
# http://blog.nicolargo.com/2010/10/installation-dun-serveur-openvpn-sous-debianubuntu.html
#
# Authors:
# - Nicolargo (aka Nicolas Hennion)
# - Fran�ois ANTON (add choice for certificate password)
# - Kimpe Andy (add conpatibility for windows vista and windows 7)
#
# GPLv3
#
# Syntaxe: # sudo ./ovcreateclient.sh <nomduclient>
#
VERSION="0.3"
port=$(cat /etc/openvpnport)
proto=$(cat /etc/openvpnproto)
# verifier si sudo et installer
if [ ! -e "/usr/bin/sudo" ]
then
# si sudo n'est pas installer ont l'install
yum -y install sudo
fi
# verifier si zip et installer
if [ ! -e "/usr/bin/zip" ]
then
# si zip n'est pas installer ont l'install
yum -y install zip
fi
# Test que le script est lance en root
if [ "$LANG" = "fr_FR" -o "$LANG" = "fr_FR.UTF-8" ]
then
if [ $EUID -ne 0 ]; then
  echo "Le script doit etre lance en root: # sudo $0 <nomduclient>" 1>&2
  exit 1
fi

# Test parametre
if [ $# -ne 1 ]; then
  echo "Il faut saisir le nom du client: # sudo $0 <nomduclient>" 1>&2
  exit 1
fi

cd /etc/openvpn/easy-rsa

echo "Creation du client OpenVPN: $1"
sudo useradd $1 -s /bin/false
passwd $1
sudo mkdir /etc/openvpn/clientconf/$1
sudo cp /etc/openvpn/easy-rsa/2.0/keys/ca.crt /etc/openvpn/clientconf/$1/
sudo chmod -R 777 /etc/openvpn/clientconf/$1
cd /etc/openvpn/clientconf/$1
cat >> /etc/openvpn/clientconf/$1/client.conf << EOF
client
dev tun
proto $proto
remote `wget -qO- ifconfig.me/ip` $port
resolv-retry infinite
nobind
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
persist-key
persist-tun
ca ca.crt
auth-user-pass
comp-lzo
reneg-sec 0
verb 3
EOF
sudo cp client.conf client.ovpn
sudo zip $1.zip *.*

echo "Creation du client OpenVPN $1 termine"
echo "/etc/openvpn/clientconf/$1/$1.zip" 
echo "---"
else
if [ $EUID -ne 0 ]; then
  echo "The script must be launched as root : # sudo $0 <nomduclient>" 1>&2
  exit 1
fi

# Test parametre
if [ $# -ne 1 ]; then
  echo "You must enter the name of the client : # sudo $0 <nomduclient>" 1>&2
  exit 1
fi

cd /etc/openvpn/easy-rsa

echo "Creation of OpenVPN client : $1"
sudo useradd $1 -s /bin/false
passwd $1
sudo mkdir /etc/openvpn/clientconf/$1
sudo cp /etc/openvpn/easy-rsa/2.0/keys/ca.crt /etc/openvpn/clientconf/$1/
sudo chmod -R 777 /etc/openvpn/clientconf/$1
cd /etc/openvpn/clientconf/$1
cat >> /etc/openvpn/clientconf/$1/client.conf << EOF
client
dev tun
proto udp
remote `wget -qO- ifconfig.me/ip` $port
resolv-retry infinite
nobind
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
persist-key
persist-tun
ca ca.crt
auth-user-pass
comp-lzo
reneg-sec 0
verb 3
EOF
sudo cp client.conf client.ovpn
sudo zip $1.zip *.*
echo "Creation of OpenVPN client OpenVPN $1 End"
echo "/etc/openvpn/clientconf/$1/$1.zip" 
echo "---"
EOF
fi
