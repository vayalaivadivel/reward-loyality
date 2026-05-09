#!/bin/bash

set -euo pipefail

echo "===== INSTALLING APACHE HOP ====="

#########################################
# INSTALL JAVA + UTILITIES
#########################################

apt-get update -y

apt-get install -y \
  openjdk-17-jdk \
  wget \
  unzip

#########################################
# CREATE DIRECTORY
#########################################

mkdir -p /opt/hop

cd /opt/hop

#########################################
# DOWNLOAD APACHE HOP
#########################################

wget https://downloads.apache.org/hop/2.15.0/apache-hop-client-2.15.0.zip

#########################################
# UNZIP
#########################################

unzip apache-hop-client-2.15.0.zip

#########################################
# START HOP SERVER
#########################################

cd hop

nohup ./hop-server.sh \
  -u admin \
  -p admin \
  8080 > /var/log/hop-server.log 2>&1 &

echo "✅ Apache Hop Server Started"