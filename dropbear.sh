apt-get install dropbear -y
cp -rf dropbear /etc/default/dropbear
service dropbear stop
service dropbear start
