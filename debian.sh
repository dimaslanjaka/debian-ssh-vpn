#!/bin/bash
# initialize variable
export DEBIAN_FRONTEND=noninteractive
OS=$(uname -m)
MYIP=$(wget -qO- ipv4.icanhazip.com)
MYIP2="s/xxxxxxxxx/$MYIP/g"

# go to root
cd ~

# disable ipv6
echo 1 >/proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update -y
apt-get -y install wget curl

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
deb http://cdn.debian.net/debian wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb http://packages.dotdeb.org wheezy all
deb http://download.webmin.com/download/repository sarge contrib
deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -
rm dotdeb.gpg
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -

# update
apt-get update -y

# install webserver
apt-get -y install nginx

# install essential package
apt-get -y install nano iptables dnsutils openvpn screen whois ngrep unzip unrar

# install neofetch
echo "deb http://dl.bintray.com/dawidd6/neofetch jessie main" | tee -a /etc/apt/sources.list
curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" | apt-key add -
apt-get update
apt-get install neofetch -y

echo "install webserver"
cd ~
mkdir /etc/nginx
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
echo "installing nginx.conf to /etc/nginx/"
cp nginx.conf /etc/nginx/
echo "creating index"
mkdir -p /home/vps/public_html
echo "INDEX" >/home/vps/public_html/index.html
echo "installing vps.conf to /etc/nginx/conf.d/"
cp vps.conf /etc/nginx/conf.d/
service nginx restart

echo "install openvpn.tar to /etc/openvpn/"
cd ~
cp openvpn.tar /etc/openvpn/
cd /etc/openvpn/
tar xf openvpn.tar
rm -f /etc/openvpn/openvpn.tar

echo "install 1194.conf to /etc/openvpn/"
cd ~
cp 1194.conf /etc/openvpn/
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables-save >/etc/iptables_set.conf

echo "install iptables to /etc/network/if-up.d/"
cd ~
mkdir /etc/network
mkdir /etc/network/if-up.d
cp iptables /etc/network/if-up.d/
chmod +x /etc/network/if-up.d/iptables
service openvpn restart

echo "Configuring openvpn"
cd ~
echo "install client.ovpn to /etc/openvpn/"
mkdir /etc/openvpn
cp client.ovpn /etc/openvpn/
cd /etc/openvpn/
sed -i $MYIP2 /etc/openvpn/client.ovpn
cp client.ovpn /home/vps/public_html/

# install badvpn
cd ~
# install badvpn-udpgw to /usr/bin/
cp badvpn-udpgw /usr/bin/
if [ "$OS" == "x86_64" ]; then
  # install badvpn-udpgw to /usr/bin/ when architecture OS is 64bit
  cp badvpn-udpgw64 /usr/bin/badvpn-udpgw
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

echo "setting port ssh"
cd ~
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
service ssh restart

echo "install dropbear"
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=444/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 444 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >>/etc/shells
echo "/usr/sbin/nologin" >>/etc/shells
service ssh restart
service dropbear restart

cd ~
echo "install dropbear 2017"
apt-get install zlib1g-dev -y
bzip2 -cd dropbear-2017.75.tar.bz2 | tar xvf -
cd dropbear-2017.75
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
service dropbear restart
rm -f /root/dropbear-2017.75.tar.bz2

cd ~
mkdir /etc/stunnel
echo "install stunnel4"
apt-get -y install stunnel4
echo "install stunnel.pem to /etc/stunnel/"
cp stunnel.pem /etc/stunnel/
echi "install stunnel.conf to /etc/stunnel/"
cp stunnel.conf /etc/stunnel/
sed -i $MYIP2 /etc/stunnel/stunnel.conf
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart

# install fail2ban
apt-get -y install fail2ban
service fail2ban restart

# install squid3
cd ~
apt-get -y install squid3
# install squid.conf to /etc/squid3/
mkdir /etc/squid3
cp squid.conf /etc/squid3/
sed -i $MYIP2 /etc/squid3/squid.conf
service squid3 restart

# install webmin
cd ~
dpkg --install webmin_1.850_all.deb
apt-get -y -f install
rm /root/webmin_1.850_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart

# blockir torrent
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 1024:65534 -j DROP
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP

echo "install ddos deflate"
cd ~
apt-get -y install dnsutils dsniff
unzip ddos-deflate-master.zip
cd ddos-deflate-master
./install.sh
rm -rf /root/ddos-deflate-master.zip

echo "setting banner"
rm /etc/issue.net
echo "install issue.net to /etc/"
cp issue.net /etc/
sed -i 's@#Banner@Banner@g' /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
service ssh restart
service dropbear restart

echo "Copy script to /usr/bin"
cp menu /usr/bin/
cp user-add /usr/bin/
cp trial /usr/bin/
cp user-del /usr/bin/
cp user-login /usr/bin/
cp user-list /usr/bin/
cp expdel /usr/bin/
cp resvis /usr/bin/
cp speedtest /usr/bin/
cp info /usr/bin/
cp about /usr/bin/

echo "0 0 * * * root /sbin/reboot" >/etc/cron.d/reboot
# Setting permissions
cd /usr/bin/
chmod +x menu
chmod +x user-add
chmod +x trial
chmod +x user-del
chmod +x user-login
chmod +x user-list
chmod +x resvis
chmod +x speedtest
chmod +x info
chmod +x expdel
chmod +x about

# finishing
cd ~
chown -R www-data:www-data /home/vps/public_html
service nginx start
service openvpn restart
service cron restart
service ssh restart
service dropbear restart
service stunnel4 restart
service squid3 restart
service fail2ban restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >>/etc/profile
clear

# info
echo "Autoscript Include:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Service" | tee -a log-install.txt
echo "-------" | tee -a log-install.txt
echo "OpenSSH  : 22, 143" | tee -a log-install.txt
echo "Dropbear : 80, 444" | tee -a log-install.txt
echo "SSL      : 443" | tee -a log-install.txt
echo "Squid3   : 8080, 3128 (limit to IP SSH)" | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.ovpn)" | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300" | tee -a log-install.txt
echo "nginx    : 81" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Script" | tee -a log-install.txt
echo "------" | tee -a log-install.txt
echo "menu         (Show available commands)" | tee -a log-install.txt
echo "user-add     (Create Account SSH)" | tee -a log-install.txt
echo "trial        (Create Account Trial)" | tee -a log-install.txt
echo "user-del     (Delete Account SSH)" | tee -a log-install.txt
echo "user-login   (Check User Login)" | tee -a log-install.txt
echo "user-list    (Check Member SSH)" | tee -a log-install.txt
echo "expdel       (Delete User expired)" | tee -a log-install.txt
echo "resvis       (Restart Service Dropbear, Webmin, Squid3, OpenVPN dan SSH)" | tee -a log-install.txt
echo "reboot       (Reboot VPS)" | tee -a log-install.txt
echo "speedtest    (Speedtest VPS)" | tee -a log-install.txt
echo "info         (INFO System)" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Other features" | tee -a log-install.txt
echo "----------" | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/" | tee -a log-install.txt
echo "Timezone : Asia/Jakarta (GMT +7)" | tee -a log-install.txt
echo "IPv6     : [off]" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Thanks To" | tee -a log-install.txt
echo "---------" | tee -a log-install.txt
echo "Allah" | tee -a log-install.txt
echo "L3n4r0x" | tee -a log-install.txt
echo "Admin And All Member KPN Family" | tee -a log-install.txt
echo "Google" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Group" | tee -a log-install.txt
echo "----" | tee -a log-install.txt
echo "Dark-IT" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "VPS AUTO REBOOT EVERY MIDNIGHT" | tee -a log-install.txt
echo "Log Installation --> /root/log-install.txt" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "===========================================" | tee -a log-install.txt
cd
rm -f /root/debian.sh
