# Latest Ubuntu LTS
FROM ubuntu:14.04

WORKDIR /tmp

# Install etcd
RUN apt-get update && \
	 apt-get install -y curl
RUN curl -L https://github.com/coreos/etcd/releases/download/v2.0.3/etcd-v2.0.3-linux-amd64.tar.gz -o etcd-v2.0.3-linux-amd64.tar.gz
RUN tar xzvf /tmp/etcd-v2.0.3-linux-amd64.tar.gz
RUN cp etcd-v2.0.3-linux-amd64/etcd /usr/bin/etcd

# Cleanup
RUN rm -r ./*

# Entry script
COPY scripts/etcd-wrapper.sh /tmp/etcd-wrapper.sh
RUN chmod -R 0500 /tmp/etcd-wrapper.sh

EXPOSE 4001 7001 2379 2380
ENTRYPOINT ["/tmp/etcd-wrapper.sh"]