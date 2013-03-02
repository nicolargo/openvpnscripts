ce script a était conçu pour vous permettre d'installer et de configurer automatique et facilement openvpn sur votre serveur

il a était tester cher ovh il et compatible avec les distribution suivante

This script was designed to allow you to install and configure openvpn automatic and easily on your server

it was expensive test ovh it compatible with the following distribution

CentOS 5.9 64 bit et (and) client ubuntu 12.04 64 bit ok

CentOS 5.9 32 bit et (and) client ubuntu 12.04 64 bit ok

CentOS 6.3 64 bit et (and) client ubuntu 12.04 64 bit ok

CentOS 6.3 32 bit et (and) client ubuntu 12.04 64 bit ok

Debian 6.0 (Squeeze) 64 bit et (and) client ubuntu 12.04 64 bit ok

Debian 6.0 (Squeeze) 32 bit et (and) client ubuntu 12.04 64 bit ok

Debian 7.0 (Wheezy) (ALPHA) 64 bit et (and) client ubuntu 12.04 64 bit ok

Debian 7.0 (Wheezy) (ALPHA) 32 bit et (and) client ubuntu 12.04 64 bit ok

Ubuntu Server 12.04 "Precise Pangolin" LTS 64 bit et (and) client ubuntu 12.04 64 bit ok

Ubuntu Server 12.04 "Precise Pangolin" LTS 32 bit et (and) client ubuntu 12.04 64 bit ok

VPS Proxmox VE 2.2 et (and) client ubuntu 12.04 64 bit ok

VPS Proxmox VE 2.2 et (and) client Windows 7 32 bit ok

CentOS 6 + SolusVM OpenVZ (Master) et (and) client ubuntu 12.04 64 bit ok

CentOS 6 + SolusVM OpenVZ (Master) et (and) client Windows 7 32 bit ok

CentOS 6 + SolusVM OpenVZ (Slave) et (and) client ubuntu 12.04 64 bit ok

CentOS 6 + SolusVM OpenVZ (Slave) et (and) client Windows 7 32 bit ok

Fedora Core 17 "Beefy Miracle" et (and) client ubuntu 12.04 64 bit ok


d'autre distribution seront tester et ajouté par la suite

other distribution will be tested and later added

si vous rencontrez des erreurs ou voulez faire part de vos test vous pouvez me contacter à

If you encounter any errors or want to share your test you can contact me at

andykimpe[AT]gmail[DOT]com

for install enter commande in root (sudo su root)

pour installer entrez ces commande en root (sudo su root)

install packet git and dos2unix

installer les packet git et dos2unix

debian ubuntu attention ce script n'est pas compatible sur ubuntu 12.10 (attention to this script is not compatible ubuntu 12.10)

apt-get -y install git dos2unix 

or (ou)

fedora centos 6 read-hat 6

yum -y install git dos2unix 

ou (or) pour (for) 

centos 5 64bit red-aht 5 64 bit

yum -y install dos2unix zlib-devel openssl-devel cpio expat-devel gettext-devel gcc make automake && wget http://git-core.googlecode.com/files/git-1.7.9.tar.gz && tar xvzf git-1.7.9.tar.gz && cd git-1.7.9 && ./configure && make && make install 

ou (or) pour (for) 

centos 5 32 bit red-aht 5 bit

wget http://mirror.centos.org/centos/5/updates/i386/RPMS/kernel-headers-2.6.18-348.1.1.el5.i386.rpm && rpm -i kernel-headers-2.6.18-348.1.1.el5.i386.rpm && yum -y update && yum -y install dos2unix zlib-devel openssl-devel cpio expat-devel gettext-devel gcc make automake && wget http://git-core.googlecode.com/files/git-1.7.9.tar.gz && tar xvzf git-1.7.9.tar.gz && cd git-1.7.9 && ./configure && make && make install

puis pour installer

then to install

cd /tmp && git clone git://github.com/nicolargo/openvpnscripts.git && dos2unix openvpnscripts/install.sh && chmod +x openvpnscripts/install.sh  && openvpnscripts/install.sh

après installation pour crée un client executer ovcreateclient non du client

after install for create client execute ovcreateclient name of client

ex :
eg :

ovcreateclient myclient

vous pouvez ensuite récupérer l'archive zip dans le dossier /etc/openvpn/clientconf/nomduclient

you can then retrieve the zip file in the /etc/openvpn/clientconf/nameofclient
