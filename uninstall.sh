#!/bin/bash
if [ -f /etc/debian_version ]
then
apt-get -y remove openvpn
else
yum -y remove openvpn
fi
rm -rf /etc/openvpn
rm -rf /etc/openvpnlang
rm -rf /tmp/*
rm -f /bin/ovcreateclient
