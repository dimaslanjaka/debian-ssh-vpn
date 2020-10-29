#!/bin/bash
#Script auto create user SSH

if ! [ -x "$(command -v curl)" ]; then
  apt-get install curl -y
fi

read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (day): " masaaktif

IP=$(curl icanhazip.com)
useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n" | passwd $Login &>/dev/null
echo -e ""
echo -e "INFO SSH"
echo -e "=========-account-=========="
echo -e "Host: $IP"
echo -e "Port: 22, 80, 143, 443, 109, 110"
echo -e "Username: $Login "
echo -e "Password: $Pass"
echo -e "-----------------------------"
echo -e "Expire Date: $exp"
echo -e "==========================="
