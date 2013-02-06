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
echo "Veuillez choisir le type de certificat :"
echo "1) Certificat SANS mot de passe"
echo "2) Certificat AVEC mot de passe"
read key

case $key in
	1)
		echo "Creation du certificat SANS mot de passe pour le client $1"
		source vars
		./build-key $1
		;;

	2)
		echo "Creation du certificat AVEC mot de passe pour le client $1"
		source vars
		./build-key-pass $1
		;;

	*)
		echo "Choix non correct !"
		echo "Arret du script"
		exit 0
		;;
esac

sudo mkdir /etc/openvpn/clientconf/$1
sudo cp /etc/openvpn/ca.crt /etc/openvpn/ta.key keys/$1.crt keys/$1.key /etc/openvpn/clientconf/$1/

cd /etc/openvpn/clientconf/$1
cat >> client.conf << EOF
# Client
client
dev tun
proto tcp-client
remote `wget -qO- ifconfig.me/ip` 443
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
# ajout de la compatibilité pour windows xp (la même config sauf que je change le pour pouvoir les diférencier)
sudo cp client.conf client-xp.ovpn
# ajout de la compatibilité pour windows vista et windows 7
sudo cp client.conf client-vista-7.conf
# ajout de ligne suivante a la fin du fichier de config
# route-method exe
# route-delay 2
# permet de corriger les problème de routage sur windows vista et windows 7
sudo echo route-method exe >> /etc/openvpn/clientconf/$1/client-vista-7.conf
sudo echo route-delay 2 >> /etc/openvpn/clientconf/$1/client-vista-7.conf
sudo zip $1.zip *.*

echo "Creation du client OpenVPN $1 termine"
echo "/etc/openvpn/clientconf/$1/$1.zip" 
echo "---"
