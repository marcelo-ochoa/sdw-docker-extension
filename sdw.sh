#!/bin/bash

killall java

set -ue

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "usage: "
    echo '      /home/sdw.sh -t theme={"background":"#F4F4F6","foreground":"#27343B","cursor":"#17191E","selection":"#6BC3F3"}'
    exit 1
fi


if [ -f /home/sdw/config/databases/default/pool.xml ]; then
   cd /home/sdw;
   echo "ORDS already installed..." >> /tmp/ords.out;
   echo "Starting ORDS..." >> /tmp/ords.out;
   /opt/ords/bin/ords serve >> /tmp/ords.out 2>> /tmp/ords.err;
else
   cd /home/sdw;
   echo "ORDS was not installed yet..." >> /tmp/ords.out;
   echo "Installing ORDS..." >> /tmp/ords.out;
   /opt/ords/bin/ords install --admin-user SYS --db-hostname host.docker.internal --db-port 1521 --db-servicename xepdb1 --feature-db-api true --feature-rest-enabled-sql true --feature-sdw true --proxy-user --password-stdin < /home/sdw/default.pwd >> /tmp/ords.out 2>> /tmp/ords.err;
   echo "Starting ORDS..." >> /tmp/ords.out;
   /opt/ords/bin/ords serve >> /tmp/ords.out 2>> /tmp/ords.err;
fi
