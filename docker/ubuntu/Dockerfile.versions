FROM ubuntu:xenial

# Use this to force a cache reset (e.g. for output purposes)
#COPY docker/Dockerfile /tmp/Dockerfile

# Install some other dependencies for ease of life.
RUN  apt-get update \
  && apt-get install -y wget git lsb-release apt-utils systemd \
  && rm -rf /var/lib/apt/lists/*

# Install several repos: PC1 (puppet 4), puppet 5, and puppet 6.
RUN wget -O puppet-pc1.deb http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb && \
    dpkg -i --force-conflicts puppet-pc1.deb && \
    wget -O puppet5.deb http://apt.puppetlabs.com/puppet5-release-xenial.deb && \
    dpkg -i --force-conflicts puppet5.deb && \
    wget -O puppet6.deb http://apt.puppetlabs.com/puppet6-release-xenial.deb && \
    dpkg -i --force-conflicts puppet6.deb && \
    apt-get update

# Print out available package versions for puppet-agent. If a specific version
# is desired, pass that in with e.g. `--build-arg before=1.1.1`
ENTRYPOINT ["apt-cache", "madison", "puppet-agent"]
