#!/bin/sh
#
# script for updating asuscomm ddns
# 2017-2021 Sense <xuhaojie at hotmail dot com>
#
# This script called by function send_update() in dynamic_dns_functions.sh
#
# options required in /etc/config/ddns
# option username - mac address registered to asuscomm.com, for example AA:BB:CC:DD:EE:FF:12
# option password - wps pin, eight digits wps pin for example 123456
# option domain   - domain registered to asuscomm.com, for example user.asuscomm.com

asus_request(){
    case $action_mode in
        "register")
            local path="ddns/register.jsp"
            ;;
        "update")
            local path="ddns/update.jsp"
            ;;
        *)
            log "Unknown action! Allowed action: register or update"
            return
            ;;			
    esac
    local password=$(calculate_password)
    echo $(curl --write-out %{http_code} --silent --output /dev/null --user-agent "ez-update-3.0.11b5 unknown [] (by Angus Mackay)" --basic --user $user:$password "http://ns1.asuscomm.com/$path?hostname=$domain&myip=$wanIP")
}

calculate_password(){
    local stripped_host=$(strip_dots_colons $host)
    local stripped_wanIP=$(strip_dots_colons $wanIP)
    echo $(echo -n "$stripped_host$stripped_wanIP" | openssl md5 -hmac "$key" 2>/dev/null | cut -d ' ' -f 2 | tr 'a-z' 'A-Z')
}

get_wan_ip(){
    echo $(curl --silent http://ip.3322.org/)
    #echo $(ifconfig -a $(nvram get pppoe_ifname) 2>/dev/null | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
}

is_dns_updated(){
    local dns_resolution=$(nslookup $host ns1.asuscomm.com 2>/dev/null)
    # check if wanIP is in nslookup result
    for token in $dns_resolution
    do
        if [ $token = $wanIP ]
        then
            return 0 # true
        fi
    done
    return 1 # false
}

code_to_string(){
    case $mode in
        "register")
            local log_mode="Registration"
            ;;
        "update")
            local log_mode="Update"
            ;;
    esac

    case $1 in
        200 )
            echo "$log_mode success."
            ;;
        203 | 233 )
            echo "$log_mode failed."
            ;;
        220 )
            echo "$log_mode same domain success."
            ;;
        230 )
            echo "$log_mode new domain success."
            ;;
        297 )
            echo "Invalid hostname."
            ;;
        298 )
            echo "Invalid domain name."
            ;;
        299 )
            echo "Invalid IP format."
            ;;
        401 )
            echo "Authentication failure."
            ;;
        407 )
            echo "Proxy authentication Required."
            ;;
        * )
            echo "Unknown result code. ($1)"
            ;;
    esac
}

strip_dots_colons(){
    echo $(echo "$1" | tr -d .:)
}

log(){
    case $output in
        "logger")
            write_log 7 "$1"
            ;;
        "silent")
            ;;
        *)
            echo "$1" >&2
            ;;
    esac
}

main(){
    case $action_mode in
        "register")
            ;;
        "update")
            if is_dns_updated
            then
                log "Domain already updated."
                return
            fi
            ;;
        *)
            log "Unknown action! Allowed action: register or update"
            return
            ;;
    esac	
    local return_code=$(asus_request)
    local res=$(code_to_string $return_code)
    log "$res"
}

# check input parameters
[ -z "$domain" ] && write_log 14 "config error! domain cannot be empty"
[ -z "$username" ] && write_log 14 "config error! username cannot be empty"
[ -z "$password" ] && write_log 14 "config error! password cannot be empty"

local CURL=$(command -v curl)
[ -z "$CURL" ] && write_log 13 "require cURL , please install"
command -v sed >/dev/null 2>&1 || write_log 13 "require sed, please install"
command -v openssl >/dev/null 2>&1 || write_log 13 "require openssl-util, please install"

output="logger"
action_mode="update"
wanIP=$(get_wan_ip)
local user=$(strip_dots_colons $username)
log "action: $action_mode"
log "output: $output"
log "domename: $domain"
log "user: $user"
log "pin: $password"
log "wan ip: $wanIP"

if [ -n "${wanIP}" ]
then
	main
else
	write_log 14 "No internet connection, cannot check."
fi

return 0
