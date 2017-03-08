#!/bin/bash
readonly tagName=$1
readonly tagValue=$2
readonly region='ap-southeast-1'
readonly whereCondition="Name=tag:$tagName,Values=$tagValue"

output="$(aws ec2 describe-instances --filters 'Name=instance-state-name,Values=stopped' $whereCondition --region $region --query '[Reservations[*].Instances[*].InstanceId]' --output text)"
echo $output | while read line;
do
if [ -n "$line" ]; then
  aws ec2 stop-instances --region $region --instance-ids $line
else
  echo "empty"
fi
done
