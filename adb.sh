#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "usage: "
    echo '      /home/sdw/adb.sh -t theme={"background":"#F4F4F6","foreground":"#27343B","cursor":"#17191E","selection":"#6BC3F3"}'
    exit 1
fi

if [ $(cat /tmp/sdw.theme) <> $2  ]; then
   killall java
fi

echo "$2" >/tmp/sdw.theme

set -ue

if [ -f /home/sdw/config/databases/default/pool.xml ]; then
   cd /home/sdw;
   echo "ORDS already installed..." >> /tmp/ords.out;
   echo "Starting ORDS..." >> /tmp/ords.out;
   /opt/ords/bin/ords serve >> /tmp/ords.out 2>> /tmp/ords.err;
else
   cd /home/sdw;
   echo "ORDS was not installed yet..." >> /tmp/ords.out;
   echo "Installing ORDS..." >> /tmp/ords.out;
   /opt/ords/bin/ords install adb --admin-user ADMIN --db-user ORDS_PUBLIC_USER2 --gateway-user ORDS_PUBLIC_GWUSER --wallet /home/sdw/Wallet.zip --log-folder /tmp --feature-db-api true --feature-rest-enabled-sql true --feature-sdw true --password-stdin < /home/sdw/adb.pwd >> /tmp/ords.out 2>> /tmp/ords.err;
   echo "Starting ORDS..." >> /tmp/ords.out;
   /opt/ords/bin/ords serve >> /tmp/ords.out 2>> /tmp/ords.err;
fi
