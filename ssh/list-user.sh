#!/bin/bash

echo "-------------------------------"
echo "USERNAME           EXPIRED DATE"
echo "-------------------------------"
while read idwx; do
  AKUN="$(echo $idwx | cut -d: -f1)"
  ID="$(echo $idwx | grep -v nobody | cut -d: -f3)"
  exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
  if [[ $ID -ge 500 ]]; then
    printf "%-17s %2s\n" "$AKUN" "$exp"
  fi
done </etc/passwd
JUMLAH="$(awk -F: '$3 >= 500 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo "-------------------------------"
echo "Total: $JUMLAH users"
echo "-------------------------------"
