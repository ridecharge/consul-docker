# consul-docker
Consul Docker Container

This is a docker container to setup a consul cluster.  It has a few modes avaible.

# Local Mode
This mode starts consul as single node cluster and can be linked against by other apps.

```shell
docker run --name consul -e LOCAL_MODE=true ridecharge/consul
docker run --link consul:consul ridecharge/cf-versions
```

Will run the cfversions app in a docker container linked to consul.  It'll have `CONSUL_PORT_8500_TCP_ADDR` and `CONSUL_PORT_8500_TCP_PORT` variables exposed and consul hostname populated.

# EC2 Mode
This mode will query the ec2 instance meta data to determine a `Environment` and `Role` tags as well as making sure the instances are running to find the other members of the main cluster.

## Server Mode
It is enabled by an EC2 `tag key:Role value:consul`.  This is the main cluster.

We are currently configured to use a 6 server cluster, 3 servers in each AZ which allows for a full AZ down plus a single server failure in the other AZ.

## Proxy Mode
Proxy mode is run on all machines in ec2 that do not have the Role:consul tag.  This is a proxy mode that handles communication to the server cluster via a local docker container.  
