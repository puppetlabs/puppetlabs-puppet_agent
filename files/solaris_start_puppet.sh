#!/bin/bash

puppet_pid=$1
while $(kill -0 ${puppet_pid:?}); do
  sleep 5
done

function start_service() {
  service="${1:?}"
  /opt/puppetlabs/bin/puppet resource service "${service:?}" ensure=running enable=true
}

start_service puppet
start_service mcollective
