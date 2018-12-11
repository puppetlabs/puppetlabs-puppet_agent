# Acceptance tests for puppetlabs-puppet_agent

## Background

### About Beaker

Beaker is a host provisioning and an acceptance testing framework. If you are
unfamiliar with beaker, you can start with these documents:

- [The Beaker DSL document](https://github.com/puppetlabs/beaker/blob/master/docs/how_to/the_beaker_dsl.md) will help you understand the test code in the `tests/` and `pre_suite/` subdirectories.
- [The Beaker Style Guide](https://github.com/puppetlabs/beaker/blob/master/docs/concepts/style_guide.md) will help you write new test code.
- [Argument Processing](https://github.com/puppetlabs/beaker/blob/master/docs/concepts/argument_processing_and_precedence.md) and [Using Subcommands](https://github.com/puppetlabs/beaker/blob/master/docs/tutorials/subcommands.md) have more information on beaker's command line and environmental options.

### About these tests

This module is responsible for upgrading and downgrading puppet-agent.  Testing
this behavior necessarily involves repeatedly installing and uninstalling
puppet-agent. Ideally, the test hosts would be totally destroyed and
reprovisioned before each fresh install of puppet-agent, but beaker does not
support workflows like this. Instead:

- Use the `run_setup` helper method to install puppet-agent, plus this module
  and its dependencies, before the main content of each of your tests.
- Use the `run_teardown` helper method to uninstall puppet-agent and remove
  modules in your tests' teardown steps.

See [helpers.rb](./helpers.rb) for the impelementations of these methods.

#### Environment variables affecting test behavior

When the `run_setup` helper installs puppet-agent, it determines the version to
install as follows:

1. If the `FROM_AGENT_VERSION` environment variable is set, install that version.
2. Otherwise, install the latest agent from the `FROM_PUPPET_COLLECTION`
    environment variable (set this to `pc1`, `puppet5`, or `puppet6` for puppet
    versions 4.x, 5.x, or 6.x respectively).
3. Otherwise, and by default, install the latest agent from the `pc1`
    collection (this would be puppet-agent 1.x with puppet 4.x).

During your tests, you may upgrade or downgrade puppet-agent to different
versions. Unless you're testing a version-specific behavior, any tests that
upgrade or downgrade the version of puppet-agent should use the
`TO_AGENT_VERSION` environment variable as the target version by default.
Similarly, use `TO_PUPPET_COLLECTION` in similar cases where behavior is based
on the collection instead of the agent version.

## How to run the tests

### Install the dependencies

This directory has its own Gemfile, containing gems required only for these
acceptance tests. Ensure that you have [bundler](https://bundler.io/) installed,
and then use it to install the dependencies:

```sh
bundle install --path .bundle
```

This will install [`beaker`](https://github.com/puppetlabs/beaker) and
[`beaker-puppet`](https://github.com/puppetlabs/beaker-puppet) (a beaker
library for working with puppet specifically), plus several hypervisor gems
for working with beaker and vagrant, docker, or vsphere.

### Set up the test hosts

Before running any of the acceptance tests in the `tests/` directory, you must
do the following once:

- configure beaker,
- provision VMs or containers as test hosts, and
- run the setup tasks in the `pre_suite/` directory.

Here's how:

```sh
# Use `beaker-hostgenerator` generate a hosts file that describes the
# types of hosts you want to test. See beaker-hostgenerator's help for more
# information on available host types and roles.
# This example creates a Centos 7 master and a single Debian 9 agent, which will be provisioned with Docker.
bundle exec beaker-hostgenerator -t docker centos7-64mcda-debian9-64a > ./hosts.yaml

# Now run `beaker init` to generate configuration for this beaker run in
# `.beaker/`. Pass it the location of your hosts file and the options file:
bundle exec beaker init -h ./hosts.yaml -o options.rb

# Create the VMs or containers that will act as the test hosts:
bundle exec beaker provision

# Now run the pre-suite setup tasks. This will install puppetserver and the
# puppet_agent module on your master host in preparation for running the tests:
bundle exec beaker exec pre-suite
```

### Run and re-run the tests

Once you've set up beaker, you can run any number of tests any number of times:

```sh
# Run all the tests
bundle exec beaker exec
# Run all the tests in a specific directory
bundle exec beaker exec ./tests/subdir
# Run a commma-separated list of specific tests:
bundle exec beaker exec ./path/to/test.rb,./another/test.rb
```

### Clean up

You can destroy existing test hosts like this:

```sh
bundle exec beaker destroy
```
