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
# INSTALL REQUIRED PACKAGES
#########################################

echo "Installing required packages..."

apt-get install -y \
  openjdk-17-jdk \
  wget \
  unzip \
  nginx \
  curl \
  net-tools

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

mysql --version

#########################################
# VERIFY JAVA
#########################################

if ! command -v java >/dev/null 2>&1; then
    echo "❌ Java installation failed"
    exit 1
fi

echo "✅ Java installed successfully"

java -version

#########################################
# DISPLAY DATABASE INFO
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
# CREATE HOP DIRECTORY
#########################################

echo "Creating Apache Hop directory..."

mkdir -p /opt/hop

cd /opt/hop

#########################################
# DOWNLOAD APACHE HOP
#########################################

echo "Downloading Apache Hop..."

wget -O apache-hop-client.zip \
https://archive.apache.org/dist/hop/2.15.0/apache-hop-client-2.15.0.zip

#########################################
# VERIFY DOWNLOAD
#########################################

if [ ! -s apache-hop-client.zip ]; then
  echo "❌ Apache Hop download failed"
  exit 1
fi

echo "✅ Apache Hop downloaded successfully"

#########################################
# CLEAN OLD INSTALLATION
#########################################

rm -rf /opt/hop/hop || true

#########################################
# EXTRACT APACHE HOP
#########################################

echo "Extracting Apache Hop..."

unzip -o apache-hop-client.zip

#########################################
# DETECT EXTRACTED DIRECTORY
#########################################

HOP_EXTRACTED_DIR=$(find /opt/hop -maxdepth 1 -type d -name "apache-hop*" | head -n 1)

if [ -z "$HOP_EXTRACTED_DIR" ]; then
  echo "❌ Apache Hop extraction directory not found"
  exit 1
fi

echo "Detected Hop directory: $HOP_EXTRACTED_DIR"

#########################################
# RENAME DIRECTORY
#########################################

mv "$HOP_EXTRACTED_DIR" /opt/hop/hop

#########################################
# VERIFY HOP FILES
#########################################

if [ ! -f /opt/hop/hop/hop-server.sh ]; then
  echo "❌ hop-server.sh not found"
  ls -lrt /opt/hop/hop || true
  exit 1
fi

echo "✅ Apache Hop extracted successfully"

#########################################
# FIX PERMISSIONS
#########################################

chown -R ubuntu:ubuntu /opt/hop

chmod +x /opt/hop/hop/*.sh

#########################################
# START APACHE HOP SERVER
#########################################

echo "Starting Apache Hop server..."

nohup /opt/hop/hop/hop-server.sh \
> /var/log/hop-server.log 2>&1 &

#########################################
# WAIT FOR STARTUP
#########################################

echo "Waiting for Apache Hop startup..."

sleep 60

#########################################
# VERIFY HOP SERVER
#########################################

if ss -tulnp | grep 8080 >/dev/null 2>&1; then
    echo "✅ Apache Hop server started successfully"
else
    echo "❌ Apache Hop failed to start"
    cat /var/log/hop-server.log || true
    exit 1
fi

#########################################
# CONFIGURE NGINX REVERSE PROXY
#########################################

echo "Configuring NGINX reverse proxy..."

cat <<EOF > /etc/nginx/sites-available/hop
server {

    listen 8081;

    location / {

        proxy_pass http://127.0.0.1:8080;

        proxy_set_header Host \$host;

        proxy_set_header X-Real-IP \$remote_addr;

        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

#########################################
# ENABLE NGINX CONFIG
#########################################

ln -sf /etc/nginx/sites-available/hop \
/etc/nginx/sites-enabled/hop

rm -f /etc/nginx/sites-enabled/default

#########################################
# VALIDATE NGINX
#########################################

nginx -t

#########################################
# RESTART NGINX
#########################################

systemctl restart nginx

systemctl enable nginx

#########################################
# VERIFY NGINX
#########################################

sleep 10

if ss -tulnp | grep 8081 >/dev/null 2>&1; then
    echo "✅ NGINX reverse proxy started successfully"
else
    echo "❌ NGINX failed to start"
    exit 1
fi

#########################################
# DISPLAY ACTIVE PORTS
#########################################

echo "===== ACTIVE PORTS ====="

ss -tulnp | grep 808 || true

#########################################
# TEST ENDPOINTS
#########################################

curl -I http://localhost:8080 || true

curl -I http://localhost:8081 || true

#########################################
# COMPLETE
#########################################

echo "===== USER DATA SCRIPT COMPLETED SUCCESSFULLY ====="