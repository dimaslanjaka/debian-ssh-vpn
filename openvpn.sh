iptables -A INPUT -i tun0 -j ACCEPT
iptables -A INPUT -p udp -m state --state NEW -m udp --dport 1194 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

#iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
#iptables -I INPUT -p udp --dport 1194 -j ACCEPT
#iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to 104.237.156.154

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install ufw -y
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
# sudo ufw status
wget https://git.io/vpn -O openvpn-install.sh
sudo bash openvpn-install.sh
# udp, ip vps, 1194, windows-vpn-client
#
