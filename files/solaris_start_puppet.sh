#!/bin/bash

puppet_pid=$1
shift
service_names=$*

while $(kill -0 ${puppet_pid:?}); do
  sleep 5
done

for service_name in $service_names; do
  /opt/puppetlabs/bin/puppet resource service "${service_name:?}" ensure=running enable=true
done
