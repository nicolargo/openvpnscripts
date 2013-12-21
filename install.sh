#!/bin/bash
# centos 6 , ubuntu and debian
version="0.5"
#create log file
logfile=/var/log/openvpn-auto-install.log
exec > >(tee $logfile)
exec 2>&1
# check system compatibility
echo "detect system"
BITS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ -f /etc/lsb-release ]; then
  OS=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^.*=//')
  VERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | sed 's/^.*=//')
if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ] && [ "$VERSION" = "12.04" ] || [ "$VERSION" = "12.10" ] || [ "$VERSION" = "13.04" ] || [ "$VERSION" = "13.10" ] || [ "$VERSION" = "6" ] || [ "$VERSION" = "7" ] ;then
echo "$OS $VERSION $BITS ok"
elif [ -f /etc/centos-release ]; then
OS=CentOS
VERSION=$(cat /etc/centos-release | sed 's/^.*release //;s/ (Fin.*$//')
if [ "$VERSION" = "5.9" ] || [ "$VERSION" = "6" ] || [ "$VERSION" = "6.1" ] || [ "$VERSION" = "6.2" ] || [ "$VERSION" = "6.3" ] || [ "$VERSION" = "6.4" ] || [ "$VERSION" = "6.5" ] ; then
echo "$OS $VERSION $BITS ok"
elif [ -f /etc/redhat-release ]; then
VERSION=$(cat /etc/redhat-release | sed 's/^.*release //;s/ (Fin.*$//')
if [ "$VERSION" = "17" ] || [ "$VERSION" = "18" ] || [ "$VERSION" = "19" ] ; then
OS=Fedora
echo "$OS $VERSION $BITS ok"
else
echo "your system $OS $VERSION $BITS is not compatible with this script"
exit
fi
fi
else
OS=$(uname -s)
VERSION=$(uname -r)
echo "your system $OS $VERSION $BITS is not compatible with this script"
exit
fi
fi
mkdir /etc/openvpnlang
cp openvpnscripts/fr.sh /etc/openvpnlang
cp openvpnscripts/en.sh /etc/openvpnlang

while true; do
clear
echo -e "----------------------------"
echo -e " openvpn auto Install v $version"
echo -e "----------------------------"
echo "To continue in English, type e"
echo "Pour continuer en Français, tapez f"
echo "To Exit / Pour quitter : CTRL-C"
read -e -p "? " lang
   case $lang in
     [e]* ) LANGUAGE=en.sh && break;;
     [f]* ) LANGUAGE=fr.sh && break;;
   esac
done
source /etc/openvpnlang/$LANGUAGE


echo -e $country1
echo -e $country2
read -e -p "$country3" country
read -e -p "$dep1" dep
read -e -p "$port1" port
cat > /etc/openvpnport <<EOF
$port
EOF
read -e -p "$proto1" proto
cat > /etc/openvpnproto<<EOF
$proto
EOF
read -e -p "$city" ville
read -e -p "$org1" org
read -e -p "$mail" email


if [ -f /etc/debian_version ]
then
#ici les commande pour debian ubuntu
apt-get update
apt-get -y dist-upgrade
apt-get -y install openvpn sudo zip unzip
cd /etc/openvpn
git clone git://github.com/andykimpe/easy-rsa.git /etc/openvpn/test
mkdir /etc/openvpn/easy-rsa
cp -R /etc/openvpn/test/easy-rsa/2.0/* /etc/openvpn/easy-rsa
rm -rf /etc/openvpn/test
chown -R $USER /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa/
chmod 755 *
rm -f /etc/openvpn/easy-rsa/vars
touch /etc/openvpn/easy-rsa/vars
cat > /etc/openvpn/easy-rsa/vars <<EOF
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
export EASY_RSA="/etc/openvpn/easy-rsa/"

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
export KEY_CONFIG=/etc/openvpn/easy-rsa/openssl-1.0.0.cnf

# Edit this variable to point to
# your soon-to-be-created key
# directory.
#
# WARNING: clean-all will do
# a rm -rf on this directory
# so make sure you define
# it correctly!
export KEY_DIR="/etc/openvpn/easy-rsa/keys"

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
openvpn --genkey --secret keys/ta.key
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
log-append $port.log
EOF
/etc/init.d/openvpn start
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

# Vider les règles personnelles
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
yum -y install gcc make iptables rpm-build autoconf.noarch zlib-devel pam-devel openssl-devel wget chkconfig zip unzip sudo
wget http://openvpn.net/release/lzo-1.08-4.rf.src.rpm
rpmbuild --rebuild lzo-1.08-4.rf.src.rpm
if [ "$OS" = "Fedora" ] ;then
rpm -Uvh lzo-*.rpm
rm lzo-*.rpm
yum install openvpn -y
cd /etc/openvpn
git clone git://github.com/andykimpe/easy-rsa.git /etc/openvpn/test
mkdir /etc/openvpn/easy-rsa
cp -R /usr/share/doc/openvpn-2.3.2/easy-rsa/* /etc/openvpn/easy-rsa
rm -rf /etc/openvpn/test
cd /etc/openvpn/easy-rsa/
chmod 755 *
rm -f /etc/openvpn/easy-rsa/vars
touch /etc/openvpn/easy-rsa/vars
cat > /etc/openvpn/easy-rsa/vars <<EOF
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
export EASY_RSA="/etc/openvpn/easy-rsa/"

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
export KEY_CONFIG=/etc/openvpn/easy-rsa/openssl-1.0.0.cnf

# Edit this variable to point to
# your soon-to-be-created key
# directory.
#
# WARNING: clean-all will do
# a rm -rf on this directory
# so make sure you define
# it correctly!
export KEY_DIR="/etc/openvpn/easy-rsa/keys"

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
cp keys/ca.crt keys/server.crt keys/server.key keys/dh1024.pem /etc/openvpn/
cat > /etc/openvpn/server.conf <<EOF
mode server
proto $proto
port $port
dev tun
# Cles et certificats
ca ca.crt
cert server.crt
key server.key
dh dh1024.pem
# Reseau
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
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
ln -s '/usr/lib/systemd/system/openvpn@.service' '/etc/systemd/system/multi-user.target.wants/openvpn@server.service'
systemctl enable openvpn@server.service
systemctl start openvpn@server.service
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1
cat > /etc/sysconfig/iptables<<EOF
# Generated by iptables-save v1.4.14 on Wed Feb 27 18:59:14 2013
*raw
:PREROUTING ACCEPT [253:20060]
:OUTPUT ACCEPT [197:23072]
COMMIT
# Completed on Wed Feb 27 18:59:14 2013
# Generated by iptables-save v1.4.14 on Wed Feb 27 18:59:14 2013
*nat
:PREROUTING ACCEPT [4:240]
:INPUT ACCEPT [4:240]
:OUTPUT ACCEPT [4:836]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o eth0 -j MASQUERADE
COMMIT
# Completed on Wed Feb 27 18:59:14 2013
# Generated by iptables-save v1.4.14 on Wed Feb 27 18:59:14 2013
*mangle
:PREROUTING ACCEPT [253:20060]
:INPUT ACCEPT [253:20060]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [197:23072]
:POSTROUTING ACCEPT [197:23072]
COMMIT
# Completed on Wed Feb 27 18:59:14 2013
# Generated by iptables-save v1.4.14 on Wed Feb 27 18:59:14 2013
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [550:64375]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport $port -j ACCEPT
COMMIT
# Completed on Wed Feb 27 18:59:14 2013
EOF
service iptables restart
iptables-restore </etc/sysconfig/iptables
systemctl restart openvpn@server.service
mkdir /etc/openvpn/clientconf
cp /tmp/openvpnscripts/ovcreateclient-fedora.sh /bin/ovcreateclient
dos2unix /bin/ovcreateclient
chmod +x /bin/ovcreateclient
rm -rf /tmp/openvpnscripts/
exit
else
UNAME=$(uname -m)
if [ "$VERSION" = "5.9" ] && [ "$UNAME" = "i686" ]
then
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
rpm -Uvh rpmforge-release-0.5.2-2.el5.rf.i386.rpm
wget http://safesrv.net/public/dl/openvpn-auth-pam.zip
unzip openvpn-auth-pam.zip
mv openvpn-auth-pam.so /etc/openvpn/openvpn-auth-pam.so
elif [ "$VERSION" = "5.9" ] && [ "$UNAME" = "x_86_64" ]
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.$(uname -m).rpm
rpm -Uvh rpmforge-release-0.5.2-2.el6.rf.$(uname -m).rpm
wget http://safesrv.net/public/openvpn-auth-pam.zip
unzip openvpn-auth-pam.zip
mv openvpn-auth-pam.so /etc/openvpn/openvpn-auth-pam.so
elif [ "$UNAME" = "i386" ]
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.$(uname -m).rpm
rpm -Uvh rpmforge-release-0.5.2-2.el6.rf.$(uname -m).rpm
wget http://safesrv.net/public/dl/openvpn-auth-pam.zip
unzip openvpn-auth-pam.zip
mv openvpn-auth-pam.so /etc/openvpn/openvpn-auth-pam.so
else
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.$(uname -m).rpm
rpm -Uvh rpmforge-release-0.5.2-2.el6.rf.$(uname -m).rpm
wget http://safesrv.net/public/openvpn-auth-pam.zip
unzip openvpn-auth-pam.zip
mv openvpn-auth-pam.so /etc/openvpn/openvpn-auth-pam.so
fi
rpm -Uvh lzo-*.rpm
rm lzo-*.rpm
yum install openvpn -y
cp -R /usr/share/doc/openvpn-2.3.2/easy-rsa/ /etc/openvpn/
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

if [ "$VERSION" = "6" ] && [ "$UNAME" = "i386" ]
then
wget http://safesrv.net/public/dl/openvpn-auth-pam.zip
unzip openvpn-auth-pam.zip
mv openvpn-auth-pam.so /etc/openvpn/openvpn-auth-pam.so
else
wget http://safesrv.net/public/openvpn-auth-pam.zip
unzip openvpn-auth-pam.zip
mv openvpn-auth-pam.so /etc/openvpn/openvpn-auth-pam.so
fi

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
plugin /etc/openvpn/openvpn-auth-pam.so /etc/pam.d/login #- Comment this line if you are using FreeRADIUS
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
ln -s /lib/systemd/system/openvpn\@server.service /etc/systemd/system/multi-user.target.wants/openvpn\@server.service
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

# Vider les règles personnelles
iptables -A INPUT -p $proto -m state --state NEW -m $proto --dport $port -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
EOF
chmod 755 /etc/init.d/NAT
chkconfig --add NAT
chkconfig NAT on
chkconfig --add openvpn
chkconfig openvpn on
service openvpn restart
mkdir /etc/openvpn/clientconf
cp /tmp/openvpnscripts/ovcreateclient-centos.sh /bin/ovcreateclient
dos2unix /bin/ovcreateclient
chmod +x /bin/ovcreateclient
rm -rf /tmp/openvpnscripts/
exit
fi
fi
