'use strict';
const AWS = require('aws-sdk');
const ec2 = new AWS.EC2({
	region: 'ap-southeast-1'
});

exports.handler = (event, context, callback) => {
    let params = {
		Filters: [
			{
				Name: 'instance-state-name',
				Values: [
					'stopped'
				],
			},
			{
				Name: 'tag:Type',
				Values: [
					'jenkin-slave'
				]
			}
		]
	}
	ec2.describeInstances(params, function(err, data) {
		let instanceIds = [];
		if(err) {
			//handle errors here
			console.log(err, err.stack);
			callback(err, null);
		} else {
			data.Reservations.forEach(function(reservation) {
				reservation.Instances.forEach(function(instance) {
					instanceIds.push(instance.InstanceId);
				});
			});
			if(instanceIds.length > 0) {
				ec2.startInstances({
					InstanceIds: instanceIds
				}, function(err, data) {
					if(err) {
						console.log(err, err.stack);
					} else {
						callback(null, "Sucess to start instances: " + instanceIds);
					}
				});	
			} else {
				callback(null, "There is no instances to start by request");
			}
		}
	});
    
};