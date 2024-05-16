#!/bin/bash

# Replace with your actual values
SOURCE_HOST="10.x.x.x"  # Source database hostname/IP
SOURCE_USER="source_user"
SOURCE_PASSWORD="source_password"
SOURCE_DATABASE="my_database"

TARGET_HOST="12.x.x.x"  # Target database hostname/IP (reachable via bastion host)
TARGET_USER="target_user"
TARGET_PASSWORD="target_password"
TARGET_DATABASE="my_database"  # Same name for target database

# Dump source database
mysqldump -h $SOURCE_HOST -u $SOURCE_USER -p$SOURCE_PASSWORD $SOURCE_DATABASE > source_dump.sql

# Connect to target database via SSH tunnel (modify SSH details as needed)
ssh -o ProxyCommand="ssh -p 22 bastion_user@bastion_host" -i ~/.ssh/key_pair.pem $TARGET_USER@$TARGET_HOST "mysql -u $TARGET_USER -p$TARGET_PASSWORD"

# Check connection (optional)
if [ $? -eq 0 ]; then
  echo "Connected to target database successfully."
else
  echo "Error connecting to target database!"
  exit 1
fi

# Create database on target if it doesn't exist
mysql -u $TARGET_USER -p $TARGET_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $TARGET_DATABASE;"

# Import data into target database
mysql -u $TARGET_USER -p $TARGET_PASSWORD $TARGET_DATABASE < source_dump.sql

echo "Database migration complete!"

# Clean up (optional)
rm -f source_dump.sql

exit 0
