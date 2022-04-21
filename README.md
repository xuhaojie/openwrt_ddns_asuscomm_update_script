# A script to update asuscomm ddns for openwrt

 This script called by function send_update() in dynamic_dns_functions.sh

 options required in /etc/config/ddns
 * option username - mac address registered to asuscomm.com, for example AA:BB:CC:DD:EE:FF:12
 * option password - wps pin, eight digits wps pin for example 123456
 * option domain   - domain registered to asuscomm.com, for example user.asuscomm.com

The makefile not been tested yet.
Please put asuscomm.com.json to /usr/share/ddns/default
Please put update_asuscomm_com.sh to /usr/lib/ddns
Then you can update script list throught web interface by click "Update DDns Services List" button

Don't forget to install curl and openssl-util 

opkg install curl
opkg install openssl-util

Thasnks BigNerd95 https://github.com/BigNerd95/ASUSddns
Thanks sensec https://github.com/sensec/ddns-scripts_aliyun
