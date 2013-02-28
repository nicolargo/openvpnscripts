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
if [ ! -e "/usr/bin/sudo" ]; then
# si sudo n'est pas installer ont l'install
apt-get -y install sudo
fi
# verifier si zip et installer
if [ ! -e "/usr/bin/zip" ]; then
# si zip n'est pas installer ont l'install
apt-get -y install zip
fi
# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit �tre lanc� en root: # sudo $0 <nomduclient>" 1>&2
  exit 1
fi

# Test parametre
if [ $# -ne 1 ]; then
  echo "Il faut saisir le nom du client: # sudo $0 <nomduclient>" 1>&2
  exit 1
fi

cd /etc/openvpn/easy-rsa

echo "Creation du client OpenVPN: $1"

echo "Creation du certificat pour le client $1"
		source vars
		./build-key $1


sudo mkdir /etc/openvpn/clientconf/$1
sudo cp /etc/openvpn/ca.crt keys/$1.crt keys/$1.key /etc/openvpn/clientconf/$1/
sudo chmod -R 777 /etc/openvpn/clientconf/$1
cd /etc/openvpn/clientconf/$1
cat >> /etc/openvpn/clientconf/$1/client.conf << EOF
# Client
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
comp-lzo
reneg-sec 0
verb 3
script-security 3 system
up /etc/openvpn/update-resolv-conf
EOF
# ajout de la compatibilité pour windows xp (la même config sauf que je change le pour pouvoir les diférencier)
sudo cp client.conf client-xp.ovpn
# ajout de la compatibilité pour windows vista et windows 7
sudo cp client.conf client-vista-7.ovpn
# ajout de ligne suivante a la fin du fichier de config
# route-method exe
# route-delay 2
# permet de corriger les problème de routage sur windows vista et windows 7
sudo sed -i 's/script-security 3 system/ /g' /etc/openvpn/clientconf/$1/client-xp.ovpn
sudo sed -i 's|up /etc/openvpn/update-resolv-conf| |' /etc/openvpn/clientconf/$1/client-xp.ovpn
sudo sed -i 's/script-security 3 system/route-method exe/g' /etc/openvpn/clientconf/$1/client-vista-7.ovpn
sudo sed -i 's|up /etc/openvpn/update-resolv-conf|route-delay 2|' /etc/openvpn/clientconf/$1/client-vista-7.ovpn
sudo zip $1.zip *.*

echo "Creation du client OpenVPN $1 termine"
echo "/etc/openvpn/clientconf/$1/$1.zip" 
echo "---"
