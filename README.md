# VPC_Peering_and_Database_Migration
Creating VPC peering, migrating data between databases, and sending a Slack notification upon success.
**PROJECT 2: VPC peering and Database migration**

**Project Description:**

Create VPC peering between Two VPCs and migrate data between two Databases

**Goals:**

1\. VPC Peering will help you learn more about networking concepts and

databases.

2\. Database migration helps you how to handle large amount of data

**Technologies Used:**

1\. AWS Cloud

2\. Shell Scripting

3\. Debugging database issues

4\. Peering VPC

5\. AWS Database Service

6\. Networking

**Steps:**

1\. Create VPC Peering between two VPCs

2\. Bastion Host \[ec2 instance\] need to be created

3\. Access the RDS Instance from the Bastion Machine

4\. Migrate data from 10.x database to 12.x database

5\. Once data migration is completed status should be posted to slack channel

**Implementation: VPC Peering and Database Migration with Slack Notification (AWS)**

Create VPC peering, migrating data between databases, and sending a Slack notification upon success.

**Prerequisites:**

- An AWS account with access to VPC, EC2, RDS, and IAM services.
- Basic understanding of AWS CLI and shell scripting.
- Existing databases in VPC-A (source: 10.x.x.x) and VPC-B (target: 12.x.x.x).

**Tools:**

- AWS CLI
- Text Editor
- Database Migration Tool (AWS Database Migration Service or custom script)
- Slack API Integration for sending notifications

1. **VPC Peering:**

**a. Configure AWS CLI:**

- **Explanation:** Set up your AWS CLI by running aws configure command in your terminal and entering your access key and secret key.
  - 1. **VPC peering:**

~~~aws ec2 create-vpc-peering-connection --vpc-id vpc-aid --peer-vpc-id vpc-bid --peer-region region~~~

- - ~~~aws ec2 create-vpc-peering-connection~~~: This command initiates a VPC peering request.
    - \~~~--vpc-id vpc-aid~~~: Replace vpc-aid with the ID of your VPC-A (source VPC). You can find the VPC ID in the AWS Management Console under the VPC service.
    - \~~~--peer-vpc-id vpc-bid~~~: Replace vpc-bid with the ID of your VPC-B (target VPC).
    - \~~~--peer-region region~~~: Replace region with the AWS region where both VPCs reside (e.g., us-east-1).

**Initiate and Accept Peering Request:**

We'll initiate the peering request from VPC-A and then accept it from VPC-B.

- **Steps:**
    1. Run the above command in your terminal to initiate the peering request from VPC-A.
    2. Log in to the AWS Management Console and navigate to the VPC service for VPC-B.
    3. Go to "Peering Connections" and select the pending request from VPC-A.
    4. Click "Accept peering connection."

1. **Bastion Host Creation:**
2. **Launch Bastion Host:**

- **Explanation:** A bastion host is a secure entry point into a private network (VPC-B in this case). We'll launch an EC2 instance in the public subnet of VPC-A to access resources in VPC-B.
- **Command Breakdown:**
~~~
aws ec2 run-instances \\

\--image-id ami-0f3fed4b01e78e8c0 \\

\--count 1 \\

\--instance-type t2.micro \\

\--key-name your-key-pair \\

\--security-group-ids sg-aid \\

\--subnet-id subnet-aid
~~~
- - ~~~aws ec2 run-instances~~~: This command launches an EC2 instance.
    - \~~~--image-id ami-0f3fed4b01e78e8c0~~~: Replace this with an AMI ID suitable for your database migration tool. Search the AWS Marketplace for AMIs with pre-installed tools like mysqldump or pg_dump.
    - \~~~--count 1~~~: This specifies launching one instance.
    - \~~~--instance-type t2.micro~~~: This defines the instance type (you can choose a different type based on your needs).
    - \~~~--key-name your-key-pair~~~: Replace this with the name of your existing key pair that allows SSH access.
    - \~~~--security-group-ids sg-aid~~~: Replace this with the security group ID that allows SSH access from your IP address (configured later).
    - \~~~--subnet-id subnet-aid~~~: Replace this with the ID of the public subnet within VPC-A.

1. **Accessing the Bastion Host:**

- **Explanation:** Once the instance launches, you'll need its public IP address to connect via SSH.
- **Steps:**
    1. In the AWS Management Console, navigate to the EC2 service.
    2. Go to "Instances" and locate your newly launched bastion host.
    3. Note down the public IPv4 address associated with the instance.
    4. Use an SSH client (like MobaXterm) to the bastion host's public IP using your key pair.

1. **RDS Access:**

**Configure Security Group:**

- **Explanation:** We need to modify the security group associated with the bastion host to allow access to the source database and SSH access from your IP.
- **Steps:**
    1. In the AWS Management Console, navigate to the EC2 service.
    2. Go to "Security Groups" and select the security group assigned to your bastion host.
    3. Click on "Edit inbound rules."

Add Security Group Rules

- **Rule 1: SSH Access**
  - **Type:** SSH
  - **Port Range:** 22
  - **Source:** Custom (enter your public IP address)
- **Rule 2: Database Access**
  - **Type:** Custom TCP
  - **Port Range:** (3306 for MySQL)
  - **Source:** Security Group ID of the source database security group

1. **Modify Bastion Host Route Table:**

- **Explanation:** We need to ensure traffic destined for the target database subnet (VPC-B) gets routed through the VPC peering connection.
- **Steps:**
    1. In the AWS Management Console, navigate to the VPC service.
    2. Go to "Route Tables" and select the route table associated with the subnet where your bastion host resides (public subnet in VPC-A).
    3. Click on "Create route."
    4. In the "Destination" field, enter the CIDR block of the target database subnet (find this in the subnet details within VPC-B).
    5. In the "Target" field, select the VPC peering connection ID created earlier.
    6. Click "Create route."

1. **Database Migration:**

**Choose a Database Migration Tool:**

There are two options for database migration:

**Option 1: AWS Database Migration Service (DMS):**

- **Explanation:** AWS DMS is a managed service for database migrations. It simplifies the process and offers features like ongoing replication and schema conversion.
- **Steps:**
    1. Log in to the AWS Management Console and navigate to the DMS service.
    2. Follow the DMS documentation (<https://docs.aws.amazon.com/dms/>) to set up a migration task. The configuration involves specifying source and target database details, endpoints (including the bastion host as an intermediate jump-off point), and migration settings.

**Option 2: Custom Script:**

- **Explanation:** You can develop a script using tools like mysqldump (MySQL) or pg_dump (PostgreSQL) to dump data from the source database and import it into the target database.
- **Steps (Example using mysqldump for MySQL):**
    1. **On the Bastion Host:**
        - Install mysqldump using the package manager (e.g., sudo apt install mysql-client on Ubuntu/Debian).
        - Develop a script with the following logic:
            - Connect to the source database using its hostname/IP, username, and password.
            - Use mysqldump to dump the database schema and data to a file (e.g., mysqldump -u username -p database_name > database_dump.sql).
            - Connect to the target database using the bastion host as an intermediate jump-off point (details on establishing SSH tunnel connection can be found online).
            - Use mysql to create the database on the target if it doesn't exist.
            - Use mysql to import the dumped data from the file (e.g., mysql -u username -p database_name < database_dump.sql).
    2. **Run the Script:**
        - Schedule the script to run using cron jobs on the bastion host.

1. **Slack Notification**

**a. Setting Up Slack Notification:**

- **Explanation:** This involves integrating your script with the Slack API to send a notification upon successful migration.
- **Steps:**
    1. **Create a Slack App:**
        - Visit the Slack API documentation (<https://api.slack.com/web>) and create a new app for your integration.
    2. **Enable the "chat:write" permission** for your app to allow sending messages.
    3. **Obtain a Bot User OAuth Token:** This token will be used in your script to authenticate with the Slack API. You can find instructions for generating a token in the Slack API documentation.
    4. **Develop a Script Extension:**
        - Modify your migration script (or create a separate script) to check for successful migration (e.g., by verifying data count in the target database).
        - Use the Slack API libraries available

**Script for Slack Notification**

**Requirements:**

- Using a shell script and the curl command-line tool
- A Slack App with the "chat:write" permission and a Bot User OAuth Token (<https://api.slack.com/>)

**Shell Script (slack_notification.sh):**
~~~
# !/bin/bash

\# Replace with your details

SLACK_URL="<https://hooks.slack.com/services/YOUR_WORKSPACE/YOUR_CHANNEL/YOUR_BOT_TOKEN>"

MESSAGE="Database migration from VPC-A to VPC-B completed successfully!"

\# Send notification using curl

curl -X POST -H 'Content-Type: application/json' \\

\-d "{\\"text\\": \\"$MESSAGE\\"}" $SLACK_URL

if \[ $? -eq 0 \]; then

echo "Successfully sent notification to Slack channel."

else

echo "Error sending notification to Slack!"

fi
~~~
**Explanation:**

- The script defines variables for the Slack notification URL and the message.
- It uses curl with the -X POST flag to perform a POST request.
- The -H 'Content-Type: application/json' sets the content type header for the JSON payload.
- The -d flag specifies the JSON data to be sent in the request body. Double quotes are used to escape the message string within the single-quoted command.
- Similar to the Python script, it includes error handling to check the exit code of the curl command.

**Usage:**

- Save the script as slack_notification.sh.
- Replace placeholders with your actual details (Slack URL, message, and Bot User OAuth Token).
- Ensure the script has execute permissions (chmod +x slack_notification.sh).
- Execute the script after successful database migration (e.g., call it from your main migration script after the echo "Database migration complete!" line).

Syntax:

~~~ bash slack_notification.sh ~~~

OR

~~~ Source slack_notification.sh ~~~

**Sample Database and Custom Script for Database Migration**

**1\. Sample Database (source database in VPC-A):**

Simple MySQL database named "my_database" with two tables: "users" and "posts".

**a. Create Database:**

Connect to your MySQL server in VPC-A and execute the following command to create the database:

~~~ CREATE DATABASE my_database; ~~~ 

**b. Create Tables:**

Connect to database "my_database" and execute the following commands to create tables:
~~~
USE my_database;

CREATE TABLE users (

id INT AUTO_INCREMENT PRIMARY KEY,

username VARCHAR(255) NOT NULL,

email VARCHAR(255) NOT NULL UNIQUE

);

CREATE TABLE posts (

id INT AUTO_INCREMENT PRIMARY KEY,

user_id INT NOT NULL,

title VARCHAR(255) NOT NULL,

content TEXT,

FOREIGN KEY (user_id) REFERENCES users(id)

);
~~~
**c. Populate Sample Data:**
~~~
Insert sample data into the tables using INSERT statements.

INSERT INTO users (username, email) VALUES ("john_doe", "<john.doe@example.com>");

INSERT INTO users (username, email) VALUES ("jane_smith", "<jane.smith@example.com>");

INSERT INTO posts (user_id, title, content) VALUES (1, "My First Post", "This is the content of my first post.");

INSERT INTO posts (user_id, title, content) VALUES (2, "Another Post", "Here's some more content.");
~~~
**2\. Custom Script for Database Migration (using mysqldump):**

**a. Script on Bastion Host (mysqldump_migration.sh):**
~~~
# !/bin/bash

\# Replace with your actual values

SOURCE_HOST="10.x.x.x" # Source database hostname/IP

SOURCE_USER="source_user"

SOURCE_PASSWORD="source_password"

SOURCE_DATABASE="my_database"

TARGET_HOST="12.x.x.x" # Target database hostname/IP (reachable via bastion host)

TARGET_USER="target_user"

TARGET_PASSWORD="target_password"

TARGET_DATABASE="my_database" # Same name for target database

\# Dump source database

mysqldump -h $SOURCE_HOST -u $SOURCE_USER -p$SOURCE_PASSWORD $SOURCE_DATABASE > source_dump.sql

\# Connect to target database via SSH tunnel (modify SSH details as needed)

ssh -o ProxyCommand="ssh -p 22 bastion_user@bastion_host" -i ~/.ssh/key_pair.pem $TARGET_USER@$TARGET_HOST "mysql -u $TARGET_USER -p$TARGET_PASSWORD"

\# Check connection (optional)

if \[ $? -eq 0 \]; then

echo "Connected to target database successfully."

else

echo "Error connecting to target database!"

exit 1

fi

\# Create database on target if it doesn't exist

mysql -u $TARGET_USER -p$TARGET_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $TARGET_DATABASE;"

\# Import data into target database

mysql -u $TARGET_USER -p$TARGET_PASSWORD $TARGET_DATABASE < source_dump.sql

echo "Database migration complete!"

\# Clean up (optional)

rm -f source_dump.sql

exit 0
~~~
**b. Explanation:**

- The script defines variables for source and target database connection details.
- It uses mysqldump to dump the source database schema and data to a file named source_dump.sql.
- It establishes an SSH tunnel connection to the target database using the bastion host as an intermediary.
- The script attempts to connect to the target database and creates the database if it doesn't exist.
- Finally, it imports the dumped data into the target database and cleans up the temporary dump file (optional).

**Important Notes:**

- Replace all placeholders with your actual values (database details, usernames, passwords, SSH information).
- Ensure the script has proper permissions to execute (chmod +x mysqldump_migration.sh).
- Consider implementing additional error handling and logging in your script for robustness.
- This script provides a basic example. You might need to modify it based on your specific database technology and security requirements.
