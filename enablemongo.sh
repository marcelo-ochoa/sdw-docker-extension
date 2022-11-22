#!/bin/bash
killall java
/opt/ords/bin/ords --config /home/sdw/config config set mongo.enabled true
echo "Starting ORDS..." >> /tmp/ords.out
/opt/ords/bin/ords --config /home/sdw/config serve >> /tmp/ords.out 2>> /tmp/ords.err &
