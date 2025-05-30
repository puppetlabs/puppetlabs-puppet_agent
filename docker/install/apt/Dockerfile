# This Dockerfile enables an iterative development workflow where you can make
# a change and test it out quickly. The majority of commands in this file will
# be cached, making the feedback loop typically quite short. The workflow is
# as follows:
#   1. Set up pre-conditions for the system in puppet code using `deploy.pp`.
#   2. Make a change to the module.
#   3. Run `./docker/bin/install.sh ubuntu` from the project directory.
#   4. Review the output. Repeat steps 2-3 as needed.
#
# At the end of execution, you will see a line like:
#
# REMIND

ARG BASE_IMAGE=ubuntu:noble
FROM ${BASE_IMAGE}

# Use this to force a cache reset (e.g. for output purposes)
#COPY $0 /tmp/Dockerfile

# Install some other dependencies for ease of life.
RUN  apt-get update \
  && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y wget git lsb-release apt-utils systemd \
  && rm -rf /var/lib/apt/lists/*


# This is also duplicated in docker/bin/helpers/run-upgrade.sh.
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

# Now move the project directory's files into the image. That way, if these
# files change, caching will skip everything before this.
COPY docker/bin/helpers/run-install.sh /tmp/bin/run-install.sh
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

# Perform the install.
ENTRYPOINT ["/tmp/bin/run-install.sh"]
