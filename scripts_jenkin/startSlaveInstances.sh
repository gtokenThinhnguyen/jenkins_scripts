#!/bin/bash
readonly startTime="000000"
readonly endTime="130000"
currentTime=`date +"%H%M%S"`
if [[ "$currentTime" < "$startTime" || "$currentTime" > "$endTime" ]];
then
    readonly region='ap-southeast-1'
    output="$(aws ec2 describe-instances --filters 'Name=instance-state-name,Values=stopped' 'Name=tag:Type,Values=jenkin-slave' --region $region --query '[Reservations[*].Instances[*].InstanceId]' --output text)"
    echo $output | while read line;
    do
    if [ -n "$line" ]; then
      aws ec2 start-instances --region $region --instance-ids $line
    else
      echo "empty"
    fi
    done
else
    echo "Do nothing"
fi