#!/bin/bash

set -euo pipefail

#########################################
# LOGGING
#########################################

exec > >(tee /home/ubuntu/user-data.log) 2>&1

echo "===== STARTING USER DATA SCRIPT ====="

#########################################
# UPDATE SYSTEM
#########################################

echo "Updating system packages..."

apt-get update -y

#########################################
# INSTALL MYSQL CLIENT
#########################################

echo "Installing MySQL client..."

apt-get install -y mysql-client || \
apt-get install -y default-mysql-client || \
apt-get install -y mysql-client-core-8.0

#########################################
# VERIFY MYSQL CLIENT
#########################################

if ! command -v mysql >/dev/null 2>&1; then

    echo "❌ MySQL client installation failed"

    exit 1
fi

echo "✅ MySQL client installed successfully"

#########################################
# DISPLAY DB INFO
#########################################

echo "Using RDS host: ${rds_host}"

echo "Using DB name: ${db_name}"

#########################################
# WAIT FOR RDS
#########################################

echo "Waiting for RDS to become available..."

RETRIES=30
COUNT=0

until mysql \
  -h "${rds_host}" \
  -u "${db_user}" \
  -p"${db_password}" \
  -e "SELECT 1" >/dev/null 2>&1
do

  COUNT=$((COUNT+1))

  echo "⏳ Attempt $COUNT/$RETRIES: RDS not ready yet..."

  if [ $COUNT -ge $RETRIES ]; then

    echo "❌ RDS not reachable after retries"

    exit 1
  fi

  sleep 10
done

echo "✅ RDS is ready"

#########################################
# CREATE SQL FILE
#########################################

echo "Creating SQL initialization file..."

echo "${init_sql_b64}" | base64 -d > /home/ubuntu/init.sql

chown ubuntu:ubuntu /home/ubuntu/init.sql

chmod 600 /home/ubuntu/init.sql

echo "✅ SQL file created"

ls -l /home/ubuntu/init.sql

#########################################
# EXECUTE SQL
#########################################

echo "Running database initialization..."

mysql \
  -h "${rds_host}" \
  -u "${db_user}" \
  -p"${db_password}" \
  "${db_name}" < /home/ubuntu/init.sql

#########################################
# VALIDATE DB INIT
#########################################

if [ $? -eq 0 ]; then

  echo "✅ DB initialized successfully" \
    | tee /home/ubuntu/db_init.log

else

  echo "❌ DB initialization failed" \
    | tee /home/ubuntu/db_init.log

  exit 1
fi

#########################################
# INSTALL JAVA + UTILITIES
#########################################

echo "Installing Java and utilities..."

apt-get install -y \
  openjdk-17-jdk \
  wget \
  unzip

#########################################
# CREATE HOP DIRECTORY
#########################################

mkdir -p /opt/hop

cd /opt/hop

#########################################
# DOWNLOAD APACHE HOP
#########################################

echo "Downloading Apache Hop..."

wget -O apache-hop-client-2.15.0.zip \
https://archive.apache.org/dist/hop/2.15.0/apache-hop-client-2.15.0.zip

#########################################
# VERIFY DOWNLOAD
#########################################

if [ ! -f apache-hop-client-2.15.0.zip ]; then

  echo "❌ Apache Hop download failed"

  exit 1
fi

echo "✅ Apache Hop downloaded successfully"

#########################################
# UNZIP APACHE HOP
#########################################

echo "Extracting Apache Hop..."

unzip apache-hop-client-2.15.0.zip

#########################################
# VERIFY EXTRACTION
#########################################

if [ ! -d /opt/hop/hop ]; then

  echo "❌ Apache Hop extraction failed"

  exit 1
fi

echo "✅ Apache Hop extracted successfully"

#########################################
# CONFIGURE HOP SERVER
#########################################

cd /opt/hop/hop

echo "Configuring Apache Hop server..."

if [ -f config/hop-server-config.xml ]; then

  sed -i \
  's/<hostname>localhost<\/hostname>/<hostname>0.0.0.0<\/hostname>/g' \
  config/hop-server-config.xml

  echo "✅ Hop hostname updated"

else

  echo "❌ hop-server-config.xml not found"

  exit 1
fi

#########################################
# START HOP SERVER
#########################################

echo "Starting Apache Hop server..."

chmod +x hop-server.sh

nohup ./hop-server.sh \
  > /var/log/hop-server.log 2>&1 &

#########################################
# WAIT FOR SERVER
#########################################

sleep 30

#########################################
# VERIFY HOP SERVER
#########################################

if ss -tulnp | grep 8080 >/dev/null 2>&1; then

    echo "✅ Apache Hop Server Started Successfully"

else

    echo "❌ Apache Hop Server Failed To Start"

    echo "===== HOP SERVER LOG ====="

    cat /var/log/hop-server.log || true

    exit 1
fi

#########################################
# DISPLAY LISTENING PORT
#########################################

sudo ss -tulnp | grep 8080 || true

#########################################
# COMPLETE
#########################################

echo "===== USER DATA SCRIPT COMPLETED SUCCESSFULLY ====="