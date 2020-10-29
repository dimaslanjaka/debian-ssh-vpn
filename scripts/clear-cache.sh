#!/bin/bash
if ! [ -x "$(command -v curl)" ]; then
  apt-get install curl -y
fi
if ! [ -x "$(command -v sync)" ]; then
  apt-get install sync -y
fi
sync
if [ $(dpkg-query -W -f='${Status}' polipo 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  apt-get install polipo -y
fi
polipo -x
echo 3 >/proc/sys/vm/drop_caches
swapoff -a && swapon -a
printf '\n%s\n\n' 'Ram-cache and Swap Cleared'
if [ -f /opt/lampp/xampp ]; then
  /opt/lampp/xampp restart
fi
free -h
