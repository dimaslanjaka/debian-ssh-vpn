apt-get -y update && apt-get -y upgrade
apt-get -y install stunnel4 nano openssl
mkdir /etc/stunnel
cp -rf stunnel.conf /etc/stunnel/stunnel.conf
# openssl genrsa -out key.pem 2048
# openssl req -new -x509 -key key.pem -out cert.pem -days 1095
cat key.pem cert.pem >>/etc/stunnel/stunnel.pem
/etc/init.d/stunnel4 restart
