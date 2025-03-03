# This Dockerfile enables an iterative development workflow where you can make
# a change and test it out quickly. The majority of commands in this file will
# be cached, making the feedback loop typically quite short. The workflow is
# as follows:
#   1. Set up pre-conditions for the system in puppet code using `deploy.pp`.
#   2. Make a change to the module.
#   3. Run `docker build -f docker/Dockerfile .` or
#      `./docker/bin/upgrade.sh rocky` from the project directory. If you would
#      like to test specific version upgrades, you can add run this like so:
#        `docker build -f docker/rocky/Dockerfile . \
#           -t pa-dev:rocky --build-arg before=1.10.14`
#   4. Upgrade the container by running the image:
#        `docker run -it pa-dev:rocky`
#      Specify your upgrade TO version as an argument to the `docker run`
#      command.
#   5. Review the output. Repeat steps 2-5 as needed.
#
# At the end of execution, you will see a line like:
#
# Notice: /Stage[main]/Puppet_agent::Install/Package[puppet-agent]/ensure: ensure changed '1.10.14-1.el8' to '6.2.0'
#
# This specifies the versions that were used for upgrade.
#
# Arguments:
# - before: The version to do upgrade FROM. Default: "7.34.0"

ARG BASE_IMAGE=ubuntu:noble
FROM ${BASE_IMAGE}

# Use this to force a cache reset (e.g. for output purposes)
#COPY $0 /tmp/Dockerfile

# Install some other dependencies for ease of life.
RUN  apt-get update \
  && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y wget git lsb-release apt-utils systemd gnupg \
  && rm -rf /var/lib/apt/lists/*

ARG before=7.34.0
LABEL before=${before}

ARG RELEASE_PACKAGE

RUN  apt-get update \
  && apt install -y curl \
  && rm -rf /var/lib/apt/lists/*

# Install proper FROM repo pupet 7
RUN  curl -L -o puppet7.deb ${RELEASE_PACKAGE} \
  && dpkg -i puppet7.deb

# Print out which versions of the puppet-agent package are available (for reference).
#RUN dnf list puppet-agent --showduplicates

# Install FROM version of puppet-agent.
RUN  apt-get update \
  && apt list -a puppet-agent \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y puppet-agent \
  && rm -rf /var/lib/apt/lists/*

# This is also duplicated in the docker/bin/helpers/run-upgrade.sh.
ENV module_path=/tmp/modules
WORKDIR "${module_path}/puppet_agent"
COPY metadata.json ./

# Installing dependencies from source. These versions should be within the range
# of `dependencies` in metadata.json.
RUN git clone --tags https://github.com/puppetlabs/puppetlabs-stdlib ../stdlib && \
    $(cd ../stdlib && git checkout $(git describe --tags $(git rev-list --tags --max-count=1)))
RUN git clone --tags https://github.com/puppetlabs/puppetlabs-inifile ../inifile && \
    $(cd ../inifile && git checkout $(git describe --tags $(git rev-list --tags --max-count=1)))
RUN git clone --tags https://github.com/puppetlabs/puppetlabs-apt ../apt && \
    $(cd ../apt && git checkout $(git describe --tags $(git rev-list --tags --max-count=1)))
RUN git clone --tags https://github.com/puppetlabs/puppetlabs-facts ../facts && \
    $(cd ../facts && git checkout $(git describe --tags $(git rev-list --tags --max-count=1)))

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

# Print out which versions of the puppet-agent package are available (for reference).
#RUN yum list puppet-agent --showduplicates

# Perform the upgrade.
ENTRYPOINT ["/tmp/bin/run-upgrade.sh"]
