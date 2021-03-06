#!/usr/bin/env python3
import boto.utils
import boto.ec2
import os
import sys
import time


def main():
    # Defaults for local mode
    mode = 'local'
    instance_id = 'local'
    instance_ip = '127.0.0.1'
    region = 'local'
    joins = None

    # Only do this if we are running in non local mode, IE on an ec2 server
    if not os.getenv("LOCAL_MODE"):
        region = boto.utils.get_instance_identity()['document']['region']
        ec2_conn = boto.ec2.connect_to_region(region)

        # This instances info
        instance_metadata = boto.utils.get_instance_metadata()
        instance_id = instance_metadata['instance-id']
        instance_ip = instance_metadata['local-ipv4']
        instance_tags = ec2_conn.get_only_instances(instance_id)[0].tags

        # Determine if we are a server or client base on instance tags
        mode = 'server' if instance_tags['Role'] == 'consul' else 'client'

        # make sure instances are starting up before querying ec2
        instances = []
        while(not instances):
            time.sleep(10)
            # Get all the instances with the same Role and Environment as ours
            instances = ec2_conn.get_only_instances(
                filters={
                    'tag:Role': 'consul',
                    'tag:Environment': instance_tags['Environment'],
                    'instance-state-name': 'running'
                })

        # Build join args using the other instances private ip address
        joins = ["-retry-join={}".format(inst.private_ip_address)
                 for inst in instances
                 if inst.id != instance_id]

    # Build consul command and arguments
    cmd = '/usr/bin/consul'
    args = [
        cmd,
        "agent",
        "-node={}".format(instance_id),
        "-advertise={}".format(instance_ip),
        '-bind=0.0.0.0',
        '-client=0.0.0.0',
        '-data-dir=/var/consul',
        '-config-file=/etc/consul',
        "-dc={}".format(region)
    ]

    if mode == 'server':
        args += ['-bootstrap-expect=6', '-server']

    # Defining -bootstrap allows this node to become a leader 
    # of a single node cluster for local dev
    if mode == 'local':
        args += ['-bootstrap', '-server']

    if joins:
        args += joins

    # Execute consul and replace this process
    print(args)
    os.execl(cmd, *args)

if __name__ == '__main__':
    main()
