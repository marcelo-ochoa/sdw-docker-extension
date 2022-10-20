#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "usage: "
    echo '      /home/sdw/sdw.sh -t theme={"background":"#F4F4F6","foreground":"#27343B","cursor":"#17191E","selection":"#6BC3F3"}'
    exit 1
fi

if [ $(cat /tmp/sdw.theme) <> $2  ]; then
   killall java
fi

echo "$2" >/tmp/sdw.theme

set -ue

if [ -f /home/sdw/mongodb/databases/default/pool.xml ]; then
   cd /home/sdw
   export ORDS_CONFIG=/home/sdw/mongodb
   echo "MongoDB API already installed..." >> /tmp/ords.out
   echo "Starting MongoDB API..." >> /tmp/ords.out
   nohup /opt/ords/bin/ords serve >> /tmp/ords.out 2>> /tmp/ords.err &
else
   cd /home/sdw
   if [ -d /home/sdw/mongodb/ ]; then
      export ORDS_CONFIG=/home/sdw/mongodb
      echo "MongoDB API was not installed yet..." >> /tmp/ords.out
      echo "Installing MongoDB API..." >> /tmp/ords.out
      /opt/ords/bin/ords install --admin-user SYS --db-hostname host.docker.internal --db-port 1521 --db-servicename xepdb1 --feature-db-api true --feature-rest-enabled-sql true --feature-sdw true --proxy-user --password-stdin < /home/sdw/default.pwd >> /tmp/ords.out 2>> /tmp/ords.err
      /opt/ords/bin/ords config set mongo.enabled true 
      echo "Starting MongoDB API..." >> /tmp/ords.out
      nohup /opt/ords/bin/ords serve >> /tmp/ords.out 2>> /tmp/ords.err &
   fi
fi

if [ -f /home/sdw/config/databases/default/pool.xml ]; then
   cd /home/sdw
   export ORDS_CONFIG=/home/sdw/config
   echo "ORDS already installed..." >> /tmp/ords.out
   echo "Starting ORDS..." >> /tmp/ords.out
   /opt/ords/bin/ords serve >> /tmp/ords.out 2>> /tmp/ords.err
else
   cd /home/sdw
   export ORDS_CONFIG=/home/sdw/config
   echo "ORDS was not installed yet..." >> /tmp/ords.out
   echo "Installing ORDS..." >> /tmp/ords.out
   /opt/ords/bin/ords install --admin-user SYS --db-hostname host.docker.internal --db-port 1521 --db-servicename xepdb1 --feature-db-api true --feature-rest-enabled-sql true --feature-sdw true --proxy-user --password-stdin < /home/sdw/default.pwd >> /tmp/ords.out 2>> /tmp/ords.err
   echo "Starting ORDS..." >> /tmp/ords.out
   /opt/ords/bin/ords serve >> /tmp/ords.out 2>> /tmp/ords.err
fi
