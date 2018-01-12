# pi-ripper

### Instalation

```bash
# @TODO install many tools

sudo apt-get install detox

git clone https://github.com/jwest/pi-ripper.git /home/pi/pi-ripper
```

Add ripper (/home/pi/ripper/ripper.sh&) to rc file

```bash
sudo nano /etc/rc.local
```

my look like:

```
#!/bin/sh -e

_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi

sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf -D wext

/home/pi/pi-ripper/ripper.sh& >> /home/pi/pi-ripper.log

exit 0
```
