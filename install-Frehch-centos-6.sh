#!/bin/bash
# centos 6
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

yum -y update
yum -y install gcc make rpm-build autoconf.noarch zlib-devel pam-devel openssl-devel wget chkconfig sudo zip unzip
wget http://openvpn.net/release/lzo-1.08-4.rf.src.rpm
yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-1.el6.rf.$(uname -m).rpm
rpmbuild --rebuild lzo-1.08-4.rf.src.rpm
rpm -Uvh lzo-*.rpm
rm lzo-*.rpm
yum install openvpn -y
cp -R /usr/share/doc/openvpn-2.2.2/easy-rsa/ /etc/openvpn/
country=FR
dep=59
proto=tcp
port=443
ville=Roubaix
org=s2.frabelu.eu
email=andykimpe@gmail.com
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
export EASY_RSA=/etc/openvpn/easy-rsa/2.0/

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


sed -i 's|export EASY_RSA="${EASY_RSA:-.}"|export EASY_RSA=/etc/openvpn/easy-rsa/2.0/|' /etc/openvpn/easy-rsa/2.0/build-ca
sed -i 's|export EASY_RSA="${EASY_RSA:-.}"|export EASY_RSA=/etc/openvpn/easy-rsa/2.0/|' /etc/openvpn/easy-rsa/2.0/build-key-server
sed -i 's|export EASY_RSA="${EASY_RSA:-.}"|export EASY_RSA=/etc/openvpn/easy-rsa/2.0/|' /etc/openvpn/easy-rsa/2.0/build-dh

cd /etc/openvpn/easy-rsa/2.0
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
iptables -A INPUT -p $proto -m state --state NEW -m $proto --dport $port -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
service iptables save
service iptables restart
service openvpn restart
mkdir /etc/openvpn/clientconf
cp /tmp/openvpnscripts/openvpnscripts-centos.sh /bin/openvpnscripts.sh
dos2unix /openvpnscripts
chmod +x openvpnscripts