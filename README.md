# consul-docker
Consul Docker Container

This is a docker container to setup a consul cluster.  It has a few modes avaible.

# Local Mode
This mode starts consul as single node cluster and can be linked against by other apps.

docker run --name consul -e LOCAL_MODE=true ridecharge/consul
docker run --link consul:consul -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY ridecharge/cf-versions

Will run the cf-versions app in a docker container linked to consul.  It'll have CONSUL_PORT_8500_TCP_ADDR and CONSUL_PORT_8500_TCP_PORT variables exposed.

# Server Mode
Server mode is used to setup a production like consul cluster.  It is enabled by an EC2 tag key:Role value:consul.

# Client Mode
Client mode is run on all machines in ec2 that do not have the Role:consul tag.  This is a proxy mode that handles communication to the server cluster via a local docker container.  
