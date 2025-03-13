#!/usr/bin/env bash

set -e

to_version="${1}"
if [[ -z "${to_version}" ]]; then
    echo "$0: The version to install must be passed as an argument"
    exit 1
fi
to_collection="$2"
puppet_version=( ${to_version//./ } )
puppet_major=${puppet_version[0]}
if [[ -z "$to_collection" ]]; then
    case $puppet_major in
        7)
            to_collection=puppetcore7
            ;;
        8)
            to_collection=puppetcore8
            ;;
        *)
            echo "$0: Invalid version supplied" 1>&2
            exit 1
    esac
fi

export PT__installdir=../
export PT_version=${to_version}
export PT_collection=${to_collection}
export PT_password=${PUPPET_FORGE_TOKEN}
chmod u+x tasks/install_shell.sh
tasks/install_shell.sh

echo "puppet $(/opt/puppetlabs/puppet/bin/puppet --version)"
echo "facter $(/opt/puppetlabs/puppet/bin/facter --version)"
/opt/puppetlabs/puppet/bin/puppet apply -e 'notice("puppet apply")'

# Make e.g. `puppet --version` work out of the box.
PATH=/opt/puppetlabs/bin:$PATH \
    read -p "Explore the container? [y/N]: " choice && \
    choice=${choice:-N} && \
    if [ "${choice}" = "y" ]; then \
        bash; \
    else \
        echo "Moving on..."; \
    fi
