for install in centos 6 enter commande in root (sudo su root)

pour installer sur centos 6 entrez ces commande en root (sudo su root)

yum -y install git dos2unix
cd /tmp
git clone git://github.com/nicolargo/openvpnscripts.git
# English install
dos2unix openvpnscripts/install-centos-6.sh
./openvpnscripts/install-centos-6.sh

# French install
dos2unix openvpnscripts/install-Frehch-centos-6.sh
./openvpnscripts/install-Frehch-centos-6.sh

