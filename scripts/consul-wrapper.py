#!/usr/bin/env python3
import boto.utils
import boto.ec2
import os
import time


def main():
	# API Connections
    region = boto.utils.get_instance_identity()['document']['region']
    ec2_conn = boto.ec2.connect_to_region(region)

    # This instances info
    instance_metadata = boto.utils.get_instance_metadata()
    instance_id = instance_metadata['instance-id']
    instance_ip = instance_metadata['local-ipv4']
    instance_tags = ec2_conn.get_only_instances(instance_id)[0].tags
	
	# make sure instances are starting up before querying ec2
    time.sleep(10) 
    # Get all the instances with the same Role and Environment as ours
    instances = ec2_conn.get_only_instances(
        filters={
            'tag:Role': instance_tags['Role'],
            'tag:Environment': instance_tags['Environment']
        })

    # Build join args using the other instances private ip address
    joins = ["-retry-join {}".format(inst.private_ip_address)
             for inst in instances
             if inst.id != instance_id]

    # Build consul command and arguments
    cmd = '/usr/bin/consul'
    args = [
    	cmd,
        "agent",
        "-node={}".format(instance_id),
        "-bind={}".format(instance_ip),
        '-data-dir=/var/consul',
        '-bootstrap-expect=6',
        '-syslog',
        '-server',
        "-dc={}".format(region)
    ]
    args.extend(joins)

    # Execute consul and replace this process
    os.execl(cmd, *args)

if __name__ == '__main__':
    main()
