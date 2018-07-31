#!/bin/sh

loc=/opt/puppetlabs/puppet/VERSION
if test -f $loc; then
  echo "{\"version\":\"$(cat $loc)\",\"source\":\"${loc}\"}"
else
  echo '{"version":null,"source":null}'
fi
