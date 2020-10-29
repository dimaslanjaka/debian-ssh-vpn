#!/bin/bash
# Script delete ssh user

read -p "Delete User : " Pengguna

if getent passwd $Pengguna >/dev/null 2>&1; then
  userdel $Pengguna
  echo -e "User $Pengguna delted."
else
  echo -e "User $Pengguna not found."
fi
