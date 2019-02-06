# This Dockerfile enables an iterative development workflow where you can make
# a change and test it out quickly. The majority of commands in this file will
# be cached, making the feedback loop typically quite short. The workflow is
# as follows:
#   1. Set up pre-conditions for the system in puppet code using `deploy.pp`.
#   2. Make a change to the module.
#   3. Run `docker build -f docker/Dockerfile .` or
#      `./docker/bin/upgrade.sh ubuntu` from the project directory. If you would
#      like to test specific version upgrades, you can add run this like so:
#        `docker build -f docker/ubuntu/Dockerfile . \
#           -t pa-dev:ubuntu --build-arg before=1.10.14`
#   4. Upgrade the container by running the image:
#        `docker run -it pa-dev:ubuntu`
#      Specify your upgrade TO version as an argument to the `docker run`
#      command.
#   5. Review the output. Repeat steps 2-5 as needed.
#
# At the end of execution, you will see a line like:
#
# Notice: /Stage[main]/Puppet_agent::Install/Package[puppet-agent]/ensure: ensure changed '1.10.14-1xenial' to '6.2.0-1xenial'
#
# This specifies the versions that were used for upgrade.
#
# Arguments:
# - before: The version to do upgrade FROM. Default: "1.10.14"

FROM ubuntu:xenial

# Install some other dependencies for ease of life.
RUN  apt-get update \
  && apt-get install -y wget git lsb-release apt-utils systemd \
  && rm -rf /var/lib/apt/lists/*

# Use this to force a cache reset (e.g. for output purposes)
COPY $0 /tmp/Dockerfile

# Print out which versions of the puppet-agent package are available (for reference).
#RUN apt-cache madison puppet-agent

ARG before=1.10.14
LABEL before=${before}

# Install proper FROM repo: PC1 (puppet 4), puppet 5, or puppet 6.
RUN if (echo "$before" | grep -Eq  ^1\..*$) ; then \
        echo Installing PC1 repo; \
        wget -O puppet-pc1.deb http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb && \
        dpkg -i puppet-pc1.deb; \
    elif (echo "$before" | grep -Eq  ^5\..*$) ; then \
        echo Installing puppet5 repo; \
        wget -O puppet5.deb http://apt.puppetlabs.com/puppet5-release-xenial.deb && \
        dpkg -i puppet5.deb; \
    elif (echo "$before" | grep -Eq  ^6\..*$) ; then \
        echo Installing puppet6 repo; \
        wget -O puppet6.deb http://apt.puppetlabs.com/puppet6-release-xenial.deb && \
        dpkg -i puppet6.deb; \
    else echo no; \
    fi

# Install FROM version of puppet-agent.
RUN apt-get update && \
    apt-get -f -y install && \
    apt-get install puppet-agent=${before}-1xenial

# This is also duplicated in docker/bin/helpers/run-upgrade.sh.
ENV module_path=/tmp/modules
WORKDIR "${module_path}/puppet_agent"
COPY metadata.json ./

# Dependency installation: Forge or source? The former is what the user will
# have downloaded, but the latter allows testing of version bumps.
# Install module dependencies from the Forge using Puppet Module Tool (PMT).
RUN /opt/puppetlabs/puppet/bin/puppet module install --modulepath $module_path --target-dir .. puppetlabs-stdlib
RUN /opt/puppetlabs/puppet/bin/puppet module install --modulepath $module_path --target-dir .. puppetlabs-inifile
RUN /opt/puppetlabs/puppet/bin/puppet module install --modulepath $module_path --target-dir .. puppetlabs-apt

# Installing dependencies from source. These versions should be within the range
# of `dependencies` in metadata.json. `translate` is a dependency for inifile.
#RUN git clone https://github.com/puppetlabs/puppetlabs-stdlib ../stdlib --branch 5.2.0
#RUN git clone https://github.com/puppetlabs/puppetlabs-inifile ../inifile --branch 2.5.0
#RUN git clone https://github.com/puppetlabs/puppetlabs-translate ../translate --branch 1.2.0
#RUN git clone https://github.com/puppetlabs/puppetlabs-apt ../apt --branch 6.3.0

# Check that all dependencies are installed.
RUN /opt/puppetlabs/puppet/bin/puppet module --modulepath $module_path list --tree
COPY docker/deploy.pp /tmp/deploy.pp
RUN ["sh", "-c", "/opt/puppetlabs/puppet/bin/puppet apply --modulepath $module_path /tmp/deploy.pp"]

# Now move the project directory's files into the image. That way, if these
# files change, caching will skip everything before this.
COPY docker/bin/helpers/run-upgrade.sh /tmp/bin/run-upgrade.sh
COPY files/ ./files/
COPY locales/ ./locales/
COPY spec/ ./spec/
COPY task_spec/  ./task_spec/
COPY tasks/ ./tasks/
COPY templates/ ./templates
COPY types/ ./types/
COPY Gemfile Gemfile.lock Rakefile ./
COPY lib/ ./lib/
COPY manifests/ ./manifests/

COPY docker/upgrade.pp /tmp/upgrade.pp

# Print out which versions of the puppet-agent package are available in this
# repo (for reference).
#RUN apt-cache madison puppet-agent

# Perform the upgrade. Arguments will be appended in `docker run` or use
# defaults in the script.
ENTRYPOINT ["/tmp/bin/run-upgrade.sh"]

