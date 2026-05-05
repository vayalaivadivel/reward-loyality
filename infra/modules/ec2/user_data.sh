#!/bin/bash

set -e

# Log everything
exec > /home/ubuntu/user-data.log 2>&1

echo "Starting setup..."

# Update packages
apt-get update -y

# Install MySQL client properly (covers all Ubuntu versions)
echo "Installing MySQL client..."

apt-get install -y mysql-client || \
apt-get install -y default-mysql-client || \
apt-get install -y mysql-client-core-8.0

# Verify installation
if ! command -v mysql &> /dev/null
then
    echo "MySQL client installation failed!"
    exit 1
fi

echo "MySQL client installed successfully"

# Wait for RDS to be ready
echo "Waiting for RDS..."

until mysql -h ${rds_host} -u ${db_user} -p${db_password} -e "SELECT 1" &> /dev/null
do
  echo "RDS not ready yet..."
  sleep 10
done

echo "RDS is ready"

# Create SQL file
cat <<EOF > /home/ubuntu/init.sql
${init_sql}
EOF

chown ubuntu:ubuntu /home/ubuntu/init.sql
chmod 600 /home/ubuntu/init.sql

echo "Running SQL..."

mysql -h ${rds_host} -u ${db_user} -p${db_password} ${db_name} < /home/ubuntu/init.sql

if [ $? -eq 0 ]; then
  echo "DB initialized successfully" > /home/ubuntu/db_init.log
else
  echo "DB initialization failed" > /home/ubuntu/db_init.log
  exit 1
fi

echo "Setup completed successfully"