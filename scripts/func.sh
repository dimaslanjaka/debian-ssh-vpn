#!/bin/bash

# Make sure root user
rootNess() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${WARNING} MUST RUN AS ${RED}ROOT${PLAIN} USER!"
    exit 1
  fi
}

# Get public IP address
get_ip() {
  local IP=$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1)
  [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ipv4.icanhazip.com)
  [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ipinfo.io/ip)
  [ ! -z ${IP} ] && echo ${IP} || echo
}
