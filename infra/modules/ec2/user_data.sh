#!/bin/bash

# Update packages
yum update -y

# Install MySQL client
yum install -y mysql

# Optional: useful debugging tools
yum install -y telnet

# Log success
echo "MySQL client installed successfully" > /home/ec2-user/setup.log