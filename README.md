# debian-ssh-vpn 32/64 bit
Debian SSH OPENVPN Auto Installer

```bash
sudo su
# insert root password
# run script
netstat -ntulp | grep 443 # check port 443, if output exist, change port SSL (stunnel.conf) to other port
```

## default settings
- Dropbear port 423
- OpenVPN port 424 - xxxx (any if not used)

## How to change dropbear port
- edit ./dropbear
- change the port
- replace config dropbear and restart dropbear
```bash
sudo cp -rf dropbear /etc/default/dropbear
sudo service dropbear stop
sudo service dropbear start
```

## How to change certificate signature of STUNNEL (SSH SSL)
- Generate new Certificate
- Replace Default Certificate
- Restart STUNNEL
```bash
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095
# insert your own signature
cat key.pem cert.pem >>/etc/stunnel/stunnel.pem
/etc/init.d/stunnel4 restart
```