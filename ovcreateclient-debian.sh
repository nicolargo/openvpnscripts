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
VERSION="0.5"
port=$(cat /etc/openvpnport)
proto=$(cat /etc/openvpnproto)
echo -e "------------------------------------"
echo -e "openvpn auto createclient v $VERSION"
echo -e "------------------------------------"
echo "To continue in English, type e"
echo "Pour continuer en Français, tapez f"
echo "To Exit / Pour quitter : CTRL-C"
while true; do
read -e -p "? " lang
   case $lang in
     [e]* ) LANGUAGE=en.sh && break;;
     [f]* ) LANGUAGE=fr.sh && break;;
   esac
done
source /etc/openvpnlang/$LANGUAGE
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
  echo -e "$root# sudo $0 <$nameclient>" 1>&2
  exit 1
fi

# Test parametre
if [ $# -ne 1 ]; then
  echo -e "$mustclient # sudo $0 <$nameclient>" 1>&2
  exit 1
fi

cd /etc/openvpn/easy-rsa

echo -e "$createclient $1"
echo -e $certif1
echo -e "1) $certif2"
echo -e "2) $certif3"
read key

case $key in
	1)
		echo -e "$createclient2 $1"
		source vars
		./build-key $1
		;;

	2)
		echo "$createclient3 $1"
		source vars
		./build-key-pass $1
		;;

	*)
		echo -e $error
		echo -e $stop
		exit 0
		;;
esac

sudo mkdir /etc/openvpn/clientconf/$1
sudo cp /etc/openvpn/ca.crt /etc/openvpn/ta.key keys/$1.crt keys/$1.key /etc/openvpn/clientconf/$1/
sudo chmod -R 777 /etc/openvpn/clientconf/$1
cd /etc/openvpn/clientconf/$1
cat >> /etc/openvpn/clientconf/$1/client.conf << EOF
# Client
client
dev tun
proto $proto
remote `wget -qO- ifconfig.me/ip` $port
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

echo -e "$createclient $1 $finish"
echo "/etc/openvpn/clientconf/$1/$1.zip" 
echo "---"
