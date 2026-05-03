#!/bin/bash

# Update system
yum update -y

# Install MySQL client
yum install -y mysql

# Wait for RDS to be ready (simple retry)
sleep 60

# Create SQL file
cat <<EOF > /home/ec2-user/init.sql
${init_sql}
EOF

# Run SQL
mysql -h ${rds_host} -u ${db_user} -p${db_password} ${db_name} < /home/ec2-user/init.sql

echo "DB initialized" > /home/ec2-user/db_init.log