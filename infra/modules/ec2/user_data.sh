#!/bin/bash

set -e

# Log everything
exec > /home/ubuntu/user-data.log 2>&1

echo "Starting setup..."

# Update
apt-get update -y

# Install MySQL client
apt-get install -y mysql-client

echo "MySQL client installed"

# Wait for RDS
until mysql -h ${rds_host} -u ${db_user} -p${db_password} -e "SELECT 1"; do
  echo "Waiting for RDS..."
  sleep 10
done

echo "RDS is ready"

# Create SQL file
cat <<EOF > /home/ubuntu/init.sql
${init_sql}
EOF

chown ubuntu:ubuntu /home/ubuntu/init.sql

echo "Running SQL..."

mysql -h ${rds_host} -u ${db_user} -p${db_password} ${db_name} < /home/ubuntu/init.sql

echo "DB initialized successfully" > /home/ubuntu/db_init.log