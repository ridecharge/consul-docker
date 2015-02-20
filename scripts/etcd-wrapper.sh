#!/bin/bash

if [ -z "$ETCD_DISCOVERY" ]; then
  echo "Missing \$ETCD_DISCOVERY"
  exit 1
fi

if [ -z "$HOST_IP" ]; then
  echo "Missing \$HOST_IP"
  exit 1
fi

if [ -z "$INSTANCE_ID" ]; then
  INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
fi

echo $HOST_IP
PEER_URLS=http://$HOST_IP:7001,http://$HOST_IP:2380
CLIENT_URLS=http://$HOST_IP:4001,http://$HOST_IP:2379
exec /usr/bin/etcd \
	-name $INSTANCE_ID \
	-initial-advertise-peer-urls $PEER_URLS \
	-advertise-client-urls $CLIENT_URLS \
	-listen-peer-urls http://0.0.0.0:7001,http://0.0.0.0:2380 \
	-listen-client-urls http://0.0.0.0:4001,http://0.0.0.0:2379
