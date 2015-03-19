# Latest Ubuntu LTS
FROM ubuntu:14.04

# Setup the user
RUN useradd -U consul

# Install Ansible
RUN apt-get update && \
    apt-get install --no-install-recommends -y software-properties-common && \
    apt-add-repository ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y ansible

# Make sure only ansible host is localhost
RUN echo '[local]\nlocalhost\n' > /etc/ansible/hosts

# Copy our ansible files
COPY playbook.yml /tmp/playbook.yml
COPY roles /tmp/roles/

# Provision the image
RUN ansible-playbook --connection=local /tmp/playbook.yml

# Remove ansible
RUN apt-get purge -y --auto-remove ansible software-properties-common

# Packages to help install consul
RUN apt-get install -y unzip

# Install Consul
ADD https://dl.bintray.com/mitchellh/consul/0.5.0_linux_amd64.zip /tmp/0.5.0_linux_amd64.zip

RUN unzip /tmp/0.5.0_linux_amd64.zip
RUN cp consul /usr/bin/consul
RUN mkdir /var/consul/
COPY files/config.json /etc/consul
RUN chmod 0400 /etc/consul
RUN chown consul:consul /etc/consul
RUN chown consul:consul /usr/bin/consul
RUN chown -R consul:consul /var/consul

# Cleanup files
RUN rm -r /tmp/*
# Cleanup packages
RUN apt-get purge -y --auto-remove unzip

# Entry script
COPY scripts/consul-wrapper.py /tmp/consul-wrapper.py
RUN chmod 0500 /tmp/consul-wrapper.py
RUN chown consul:consul /tmp/consul-wrapper.py

USER consul
EXPOSE 8300 8301/tcp 8301/udp 8500
ENTRYPOINT ["/tmp/consul-wrapper.py"]
