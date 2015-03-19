#!/bin/sh
./bin/install_roles.sh
docker build -t ridecharge/consul .
