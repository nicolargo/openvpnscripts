#!/bin/bash
# centos 6 , ubuntu and debian
# vérifier si la distribution et de type debian ou read hat
if [ "$LANG" = "fr_FR" -o "$LANG" = "fr_FR.UTF-8" ]; then
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m######################openv""\033[00m""\033[37mpn Instalation "automatique"\033[00m""\033[31m en francais###############""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"
echo -e "\033[34m###########################""\033[00m""\033[37m###########################""\033[00m""\033[31m##########################""\033[00m"


country=FR
org=$(hostname)
echo "Entrez les premierre lettre de votre pays en majuscule"
echo "ex : pour la france FR"
read -e -p "Entrez les premierre lettre de votre pays en majuscule  : " -i $country country
read -e -p "Entrez le numero de votre departemant : " dep
read -e -p "Entrez le numéro de port qui sera utilise par le serveur (recommander 443 tcp) : " port
cat > /etc/openvpnport <<EOF
$port
EOF
cat > /etc/openvpnproto<<EOF
$proto
EOF
read -e -p "Entrez le protocol udp ou tcp : " proto
read -e -p " Entrez le nom de votre ville : " ville
read -e -p "Entrez le nom de votre entreprise ou si vous ete un particulier entrez le nom de votre serveur : " -i $org org
read -e -p "Entrez votre adresse mail : " email
else
echo "################################################################################"
echo "################################################################################"
echo "################################################################################"
echo "################################################################################"
echo "################################################################################"
echo "##########################Openvpn Auto Install English##########################"
echo "################################################################################"
echo "################################################################################"
echo "################################################################################"
echo "################################################################################"
echo "################################################################################"



country=EN
org=$(hostname)
echo "Enter the first letter of your country in uppercase"
echo "eg : for France FR"
read -e -p "Enter the first letter of your country in uppercase  : " -i $country country
read -e -p "Enter the number of your department : " dep
read -e -p "Enter the port number that will be used by the server (tcp 443 recommended) : " port
cat > /etc/openvpnport <<EOF
$port
EOF
cat > /etc/openvpnproto<<EOF
$proto
EOF
read -e -p "Enter the protocol tcp or udp : " proto
read -e -p "Enter the name of your city : " ville
read -e -p "Enter your company name or if particular enter the name of the server : " -i $org org
read -e -p "Enter your email address : " email
fi

if [ -f /etc/debian_version ]
then
#ici les commande pour debian ubuntu
apt-get update
apt-get -y dist-upgrade
apt-get -y install openvpn sudo zip unzip
mkdir /etc/openvpn/easy-rsa/
cp -R /usr/share/doc/openvpn/examples/easy-rsa/2.0/* /etc/openvpn/easy-rsa/
chown -R $USER /etc/openvpn/easy-rsa/

rm /etc/openvpn/easy-rsa/vars
cat > /etc/openvpn/easy-rsa/vars <<EOF
export EASY_RSA="/etc/openvpn/easy-rsa/"
export OPENSSL="openssl"
export PKCS11TOOL="pkcs11-tool"
export GREP="grep"
export KEY_CONFIG=/etc/openvpn/easy-rsa/openssl.cnf
export KEY_DIR="/etc/openvpn/easy-rsa/keys"
echo NOTE: If you run ./clean-all, I will be doing a rm -rf on $KEY_DIR
export PKCS11_MODULE_PATH="dummy"
export PKCS11_PIN="dummy"
export KEY_SIZE=1024
export CA_EXPIRE=3650
export KEY_EXPIRE=3650
export KEY_COUNTRY="$country"
export KEY_PROVINCE="$dep"
export KEY_CITY="$ville"
export KEY_ORG="$org"
export KEY_EMAIL="$email"
EOF
cd /etc/openvpn/easy-rsa/
source vars
./vars
./clean-all
./build-dh
./pkitool --initca
./pkitool --server server
sudo openvpn --genkey --secret keys/ta.key
cp keys/ca.crt keys/ta.key keys/server.crt keys/server.key keys/dh1024.pem /etc/openvpn/
mkdir /etc/openvpn/chroot
mkdir /etc/openvpn/clientconf
cat >  /etc/openvpn/server.conf <<EOF
mode server
proto $proto
port $port
dev tun
# Cles et certificats
ca ca.crt
cert server.crt
key server.key
dh dh1024.pem
tls-auth ta.key 0
cipher AES-256-CBC
# Reseau
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
# Securite
user nobody
group nogroup
chroot /etc/openvpn/chroot
persist-key
persist-tun
comp-lzo
# Log
verb 3
mute 20
status openvpn-status.log
log-append /var/log/openvpn.log
EOF
service openvpn start
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
iptables -A INPUT -p $proto -m state --state NEW -m $proto --dport $port -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables-save > /etc/iptables.rules
cat > /etc/init.d/NAT<<EOF
#!/bin/sh

### BEGIN INIT INFO
# Provides:          openvpn-nat
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: OpenVZ-NAT
# Description:       Active le NAT et le firewall
### END INIT INFO

# Vider les tables actuelles
iptables -t filter -F

# Vider les règles personnelles
iptables -t filter -X
iptables -A INPUT -p $proto -m state --state NEW -m $proto --dport $port -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
EOF
chmod 755 /etc/init.d/NAT
insserv /etc/init.d/NAT
update-rc.d NAT defaults
cp /tmp/openvpnscripts/ovcreateclient-debian.sh /bin/ovcreateclient
dos2unix /bin/ovcreateclient
chmod +x /bin/ovcreateclient
rm -rf /tmp/openvpnscripts/
else
cd /root
yum -y update
if [ "$LANG" = "fr_FR" -o "$LANG" = "fr_FR.UTF-8" ]; then
echo "Entrez votre numéro de version de read-hat"
echo "ex: pour centos 6 entrez 6 pour centos 5 entrez 5"
read -e -p "Entrez votre numéro de version de read-hat" VERSION
yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el$VERSION.rf.$(uname -m).rpm
else
echo "Enter the version number of read-hat"
echo "eg: centos 6 to enter 6 centos 5 to enter 5"
read-e-p "Enter the version number of read-hat" VERSION
yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el$VERSION.rf.$(uname -m).rpm
fi
yum -y install gcc make iptables rpm-build autoconf.noarch zlib-devel pam-devel openssl-devel wget chkconfig zip unzip sudo
wget http://openvpn.net/release/lzo-1.08-4.rf.src.rpm
rpmbuild --rebuild lzo-1.08-4.rf.src.rpm
rpm -Uvh lzo-*.rpm
rm lzo-*.rpm
yum install openvpn -y
cp -R /usr/share/doc/openvpn-2.2.2/easy-rsa/ /etc/openvpn/
cd /etc/openvpn/easy-rsa/2.0
chmod 755 *
rm -f /etc/openvpn/easy-rsa/2.0/vars
touch /etc/openvpn/easy-rsa/2.0/vars
cat > /etc/openvpn/easy-rsa/2.0/vars <<EOF
# easy-rsa parameter settings

# NOTE: If you installed from an RPM,
# don't edit this file in place in
# /usr/share/openvpn/easy-rsa --
# instead, you should copy the whole
# easy-rsa directory to another location
# (such as /etc/openvpn) so that your
# edits will not be wiped out by a future
# OpenVPN package upgrade.

# This variable should point to
# the top level of the easy-rsa
# tree.
export EASY_RSA="/etc/openvpn/easy-rsa/2.0/"

#
# This variable should point to
# the requested executables
#
export OPENSSL="openssl"
export PKCS11TOOL="pkcs11-tool"
export GREP="grep"


# This variable should point to
# the openssl.cnf file included
# with easy-rsa.
export KEY_CONFIG=/etc/openvpn/easy-rsa/2.0/openssl-1.0.0.cnf

# Edit this variable to point to
# your soon-to-be-created key
# directory.
#
# WARNING: clean-all will do
# a rm -rf on this directory
# so make sure you define
# it correctly!
export KEY_DIR="/etc/openvpn/easy-rsa/2.0/keys"

# Issue rm -rf warning
echo NOTE: If you run ./clean-all, I will be doing a rm -rf on $KEY_DIR

# PKCS11 fixes
export PKCS11_MODULE_PATH="dummy"
export PKCS11_PIN="dummy"

# Increase this to 2048 if you
# are paranoid.  This will slow
# down TLS negotiation performance
# as well as the one-time DH parms
# generation process.
export KEY_SIZE=1024

# In how many days should the root CA key expire?
export CA_EXPIRE=3650

# In how many days should certificates expire?
export KEY_EXPIRE=3650

# These are the default values for fields
# which will be placed in the certificate.
# Don't leave any of these fields blank.
export KEY_COUNTRY="$country"
export KEY_PROVINCE="$dep"
export KEY_CITY="$ville"
export KEY_ORG="$org"
export KEY_EMAIL="$email"
export KEY_EMAIL=$email
export KEY_CN=changeme
export KEY_NAME=changeme
export KEY_OU=changeme
export PKCS11_MODULE_PATH=changeme
export PKCS11_PIN=1234
EOF

mkdir keys
chmod 755 *
source ./vars
./vars
./clean-all
./build-ca
./build-key-server server
./build-dh
cat > /etc/openvpn/server.conf <<EOF
port $port #- port
proto $proto #- protocol
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
reneg-sec 0
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
plugin /usr/share/openvpn/plugin/lib/openvpn-auth-pam.so /etc/pam.d/login #- Comment this line if you are using FreeRADIUS
#plugin /etc/openvpn/radiusplugin.so /etc/openvpn/radiusplugin.cnf #- Uncomment this line if you are using FreeRADIUS
client-cert-not-required
username-as-common-name
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status $port.log
verb 3
EOF
echo 0 > /selinux/enforce
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
service openvpn start
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A INPUT -p $proto -m state --state NEW -m $proto --dport $port -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
service iptables save
service iptables restart
cat > /etc/init.d/NAT<<EOF
#!/bin/sh

### BEGIN INIT INFO
# Provides:          openvpn-nat
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: OpenVZ-NAT
# Description:       Active le NAT et le firewall
### END INIT INFO

# Vider les tables actuelles
iptables -t filter -F

# Vider les règles personnelles
iptables -t filter -X
iptables -A INPUT -p $proto -m state --state NEW -m $proto --dport $port -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
EOF
chmod 755 /etc/init.d/NAT
chkconfig --add NAT
chkconfig NAT on
chkconfig --ad openvpn
chkconfig openvpn on
service openvpn restart
mkdir /etc/openvpn/clientconf
cp /tmp/openvpnscripts/ovcreateclient-centos.sh /bin/ovcreateclient
dos2unix /bin/ovcreateclient
chmod +x /bin/ovcreateclient
rm -rf /tmp/openvpnscripts/
fi
