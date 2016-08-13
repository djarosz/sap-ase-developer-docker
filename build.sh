#!/bin/bash

echo "Starting busybox httpd server"
busybox httpd -p 9999
echo -n "busybox httpd server started as pid "
pgrep busybox

echo "Running docker build"
docker build -t sap-ase-developer .
echo "Finished running docker build"

echo "Stopping busybox httpd server"
pkill busybox

echo "All finished"
