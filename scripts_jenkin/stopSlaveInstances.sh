#!/bin/bash

readonly region='ap-southeast-1'
output="$(aws ec2 describe-instances --filters 'Name=instance-state-name,Values=running' 'Name=tag:Type,Values=jenkin-slave' --region $region --query '[Reservations[*].Instances[*].InstanceId]' --output text)"
echo $output | while read line;
do
if [ -n "$line" ]; then
  aws ec2 stop-instances --region $region --instance-ids $line
else
  echo "empty"
fi
done