# A script to update asuscomm ddns for openwrt

 This script called by function send_update() in dynamic_dns_functions.sh

 options required in /etc/config/ddns
 * option username - mac address registered to asuscomm.com, for example AA:BB:CC:DD:EE:FF:12
 * option password - wps pin, eight digits wps pin for example 123456
 * option domain   - domain registered to asuscomm.com, for example user.asuscomm.com

Thasnks BigNerd95 https://github.com/BigNerd95/ASUSddns
