iptables -A INPUT -i tun0 -j ACCEPT
iptables -A INPUT -p udp -m state --state NEW -m udp --dport 1194 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
chmod +x openvpn-install.sh
sh openvpn-install.sh
