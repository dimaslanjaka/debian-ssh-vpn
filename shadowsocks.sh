#!/bin/bash
if ! [ -x "$(command -v curl)" ]; then
  apt-get install curl -y
fi
IP=$(curl icanhazip.com)

sudo apt update && apt upgrade -y
sudo apt install -y snapd
sudo apt install -y haveged
sudo apt-get install software-properties-common -y
sudo apt-get update -y
sudo add-apt-repository "deb http://ftp.debian.org/debian stretch-backports main"
sudo apt update
sudo apt -t stretch-backports install shadowsocks-libev -y
sudo systemctl start shadowsocks-libev
sudo systemctl enable shadowsocks-libev

sed -i "s/xxxxxxxxx/$IP/g" shadowsocks-config.json

read -p "Password Shadowsocks : " Pass
sed -i "s/PASS/$Pass/g" shadowsocks-config.json

cp -rf shadowsocks-config.json /etc/shadowsocks-libev/config.json
sudo systemctl restart shadowsocks-libev
