#!/bin/bash

# Update system
apt-get update -y

# Install MySQL client
apt-get install -y mysql-client

# Wait for RDS to be ready
sleep 60

# Create SQL file
cat <<EOF > /home/ubuntu/init.sql
${init_sql}
EOF

# Set permissions
chown ubuntu:ubuntu /home/ubuntu/init.sql

# Run SQL
mysql -h ${rds_host} -u ${db_user} -p${db_password} ${db_name} < /home/ubuntu/init.sql

echo "DB initialized" > /home/ubuntu/db_init.log