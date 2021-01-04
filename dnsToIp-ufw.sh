#!/bin/bash
# dns to ip and check it's in ufw rules
#

HOSTNAME=yourHostname

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

new_ip=$(host $HOSTNAME | grep -oP '(\d+\.){3}\d+')
old_ip=$(/usr/sbin/ufw status | grep -oP '(\d+\.){3}\d+\/tcp' | sed 's/\/tcp.*//g')

if [ "$new_ip" = "$old_ip" ] ; then
    echo IP address has not changed
else
    if [ -n "$old_ip" ] ; then
        /usr/sbin/ufw delete allow from $old_ip to any
        echo iptables cleaned from old ip
    fi
    /usr/sbin/ufw allow from $new_ip to any proto tcp
    echo iptables have been updated with $new_ip
fi
