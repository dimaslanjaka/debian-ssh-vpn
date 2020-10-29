# debian-ssh-vpn 32/64 bit
Debian SSH OPENVPN Auto Installer

```bash
sudo su
# insert root password
# run script
netstat -ntulp | grep 443 # check port 443, if output exist, change port SSL (stunnel.conf) to other port
```

- Dropbear port 423
- OpenVPN port 424 - xxxx (any if not used)
