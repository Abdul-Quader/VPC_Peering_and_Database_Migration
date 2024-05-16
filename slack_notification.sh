#!/bin/bash

# Replace with your details
SLACK_URL="https://hooks.slack.com/services/YOUR_WORKSPACE/YOUR_CHANNEL/YOUR_BOT_TOKEN"
MESSAGE="Database migration from VPC-A to VPC-B completed successfully!"

# Send notification using curl
curl -X POST -H 'Content-Type: application/json' \
  -d "{\"text\": \"$MESSAGE\"}" $SLACK_URL

if [ $? -eq 0 ]; then
  echo "Successfully sent notification to Slack channel."
else
  echo "Error sending notification to Slack!"
fi
