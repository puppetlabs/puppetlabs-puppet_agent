#!/usr/bin/env bash
# Usage: `./install.sh [<PLATFORM>] [<VERSION>]`
#
# Builds an upgrade process for the puppet-agent module and tags as
# "pa-dev:<PLATFORM>".
#
# Parameters:
# - PLATFORM: The platform on which the upgrade should occur. This also
#             supports comma-separated lists. Available:
#             - `amazon`
#             - `fedora`
#             - `rocky`
#             - `sles`
#             - `ubuntu`
#             Default: `ubuntu`
# - BEFORE: The puppet-agent package version that is installed prior to upgrade.
#           Default: 7.34.0
# - AFTER: The puppet-agent package version that should exist after upgrade.
#          Default: 8.1.0
set -e

if [[ -z "${PUPPET_FORGE_TOKEN}" ]]; then
    echo "$0: Environment variable PUPPET_FORGE_TOKEN must be set"
    exit 1
fi

cd "$(dirname "$0")/../.."
platforms=${1:-rocky}
version=${2:-8.11.0}
collection=${3:-puppetcore8}
for platform in ${platforms//,/ }
do
    case $platform in
        amazon*|fedora*|rocky*)
            dockerfile='docker/install/dnf/Dockerfile'
            ;;
        sles*)
            dockerfile='docker/install/sles/Dockerfile'
            ;;
        debian*|ubuntu*)
            dockerfile='docker/install/apt/Dockerfile'
            ;;
        *)
            echo "$0: platform ${platform} is not supported"
            exit 1
            ;;
    esac

    # Default to the latest OS version for each distro
    case $platform in
        amazon*)    base_image='amazonlinux:2023';;
        fedora36)   base_image='fedora:36';;
        fedora40)   base_image='fedora:40';;
        fedora*)    base_image='fedora:41';;
        rocky8)     base_image='rockylinux/rockylinux:8';;
        rocky*)     base_image='rockylinux/rockylinux:9';;
        sles*)      base_image='registry.suse.com/suse/sle15:15.6';;
        debian10)   base_image='debian:buster';;
        debian11)   base_image='debian:bullseye';;
        debian*)    base_image='debian:bookworm';;
        ubuntu1804) base_image='ubuntu:bionic';;
        ubuntu2004) base_image='ubuntu:focal';;
        ubuntu2204) base_image='ubuntu:jammy';;
        ubuntu*)    base_image='ubuntu:noble';;
        *)
            echo "$0: Usage install.sh [amazon|debian|fedora|rocky|sles|ubuntu]"
            exit 1
            ;;
    esac

    # Add "--progress plain" for complete build output
    docker build --rm -f "${dockerfile}" . -t pa-dev:$platform.install \
           --build-arg BASE_IMAGE="${base_image}"
    docker run -e PUPPET_FORGE_TOKEN --rm -ti pa-dev:$platform.install "${version}" "${collection}"
done
echo Complete
