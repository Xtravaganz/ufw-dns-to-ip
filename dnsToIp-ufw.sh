#!/bin/bash
# dns to ip and check it's in ufw rules

# Hostnames separated by space
# Ports separated by: , (comma)

HOSTNAMES='host1.duckdns.org host2.duckdns.org'
PORTS='1234, 4567'

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

for HOST in ${HOSTNAMES}
do
  new_ip=$(host $HOST | grep -oP '(\d+\.){3}\d+')
  old_ip=$(/usr/sbin/ufw status | grep $HOST | grep -oP '(\d+\.){3}\d+')
  #echo debug $old_ip, $new_ip
  if [ "$new_ip" != "$old_ip" ] ; then
    if [ -n "$old_ip" ] ; then
      echo /usr/sbin/ufw delete allow proto tcp from $new_ip to any port $PORTS comment "$HOST"
    fi
      echo /usr/sbin/ufw allow proto tcp from $new_ip to any port $PORTS comment "$HOST"
    echo "ufw $HOST has been updated with $new_ip (was $old_ip) for ports: $PORTS"
  #else
  #  echo IP address has not changed
  fi
done
