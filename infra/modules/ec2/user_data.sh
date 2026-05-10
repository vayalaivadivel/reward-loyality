#!/bin/bash

set -euo pipefail

# Log everything (both stdout + stderr)
exec > >(tee /home/ubuntu/user-data.log) 2>&1

echo "===== STARTING USER DATA SCRIPT ====="

# Update packages
echo "Updating system..."
apt-get update -y

# Install MySQL client (fallback-safe)
echo "Installing MySQL client..."

apt-get install -y mysql-client || \
apt-get install -y default-mysql-client || \
apt-get install -y mysql-client-core-8.0

# Verify installation
if ! command -v mysql >/dev/null 2>&1; then
    echo "❌ MySQL client installation failed!"
    exit 1
fi

echo "✅ MySQL client installed successfully"

# Extract host (already passed clean, but log it)
echo "Using RDS host: ${rds_host}"
echo "Using DB name: ${db_name}"

# Wait for RDS to be ready
echo "Waiting for RDS to be ready..."

RETRIES=30
COUNT=0

until mysql -h "${rds_host}" -u "${db_user}" -p"${db_password}" -e "SELECT 1" >/dev/null 2>&1
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

# Decode SQL safely (base64 from Terraform)
echo "Creating SQL file..."

echo "${init_sql_b64}" | base64 -d > /home/ubuntu/init.sql

chown ubuntu:ubuntu /home/ubuntu/init.sql
chmod 600 /home/ubuntu/init.sql

echo "SQL file created:"
ls -l /home/ubuntu/init.sql

# Execute SQL
echo "Running SQL script..."

mysql -h "${rds_host}" -u "${db_user}" -p"${db_password}" "${db_name}" < /home/ubuntu/init.sql

# Validate execution
if [ $? -eq 0 ]; then
  echo "✅ DB initialized successfully" | tee /home/ubuntu/db_init.log
else
  echo "❌ DB initialization failed" | tee /home/ubuntu/db_init.log
  exit 1
fi


#########################################
# INSTALL APACHE HOP SERVER
#########################################

echo "Installing Apache Hop Server..."

apt-get install -y openjdk-17-jdk wget unzip

mkdir -p /opt/hop

cd /opt/hop

#########################################
# DOWNLOAD HOP
#########################################

wget https://downloads.apache.org/hop/2.15.0/apache-hop-client-2.15.0.zip

#########################################
# UNZIP
#########################################

unzip apache-hop-client-2.15.0.zip

#########################################
# CONFIGURE HOP SERVER
#########################################

cd /opt/hop/hop

# Expose Hop server externally
sed -i \
's/<hostname>localhost<\/hostname>/<hostname>0.0.0.0<\/hostname>/g' \
hop-config/hop-server-config.xml

#########################################
# START HOP SERVER
#########################################

chmod +x hop-server.sh

nohup ./hop-server.sh \
  > /var/log/hop-server.log 2>&1 &

#########################################
# VERIFY STARTUP
#########################################

sleep 20

if ss -tulnp | grep 8080 >/dev/null 2>&1; then
    echo "✅ Apache Hop Server Started Successfully"
else
    echo "❌ Apache Hop Server Failed To Start"
    cat /var/log/hop-server.log
    exit 1
fi


echo "===== USER DATA SCRIPT COMPLETED SUCCESSFULLY ====="