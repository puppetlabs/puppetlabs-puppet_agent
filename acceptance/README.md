# Acceptance tests for puppetlabs-puppet_agent

These integration tests use the [beaker](https://github.com/puppetlabs/beaker)
acceptance test framework to test puppet-agent installation and upgrades with
the puppetlabs-puppet_agent module.

## Quick start

If you are already familiar with beaker, you can get started like this:

```sh
# Install the dependencies
bundle install
# Create a hosts.yml file in this directory with at least one master and one agent
bundle exec beaker-hostgenerator -t docker centos7-64mcda-debian8-64a > hosts.yml
# Use the `prepare` rake task to provision your hosts and set up the master with the latest puppet 5 agent and server:
MASTER_COLLECTION=puppet5 bundle exec rake prepare
# Run the tests
bundle exec beaker exec ./tests/
# Destroy your test hosts
bundle exec beaker destroy
```

See "How to run the tests", below, for more detail.

## Background

### About Beaker

Beaker is a host provisioning and an acceptance testing framework. If you are
unfamiliar with beaker, you can start with these documents:

- [The Beaker DSL document](https://github.com/puppetlabs/beaker/blob/master/docs/how_to/the_beaker_dsl.md) will help you understand the test code in the `tests/` and `pre_suite/` subdirectories.
- [The Beaker Style Guide](https://github.com/puppetlabs/beaker/blob/master/docs/concepts/style_guide.md) will help you write new test code.
- [Argument Processing](https://github.com/puppetlabs/beaker/blob/master/docs/concepts/argument_processing_and_precedence.md) and [Using Subcommands](https://github.com/puppetlabs/beaker/blob/master/docs/tutorials/subcommands.md) have more information on beaker's command line and environmental options.

### About these tests

This module is responsible for upgrading and downgrading puppet-agent. Testing
this behavior necessarily involves repeatedly installing and uninstalling
puppet-agent. Ideally, the test hosts would be totally destroyed and
reprovisioned before each fresh install of puppet-agent, but beaker does not
support workflows like this. Instead, helper methods are used to install
puppet-agent on agent hosts at the beginning of each test and to uninstall it
during teardown. See [helpers.rb](./helpers.rb) for more.

#### Environment variables and the `prepare` rake task

The `prepare` rake task runs `beaker init`, `beaker provision`, and `beaker
pre-suite` all at once to provision your test hosts and prepare you to run
`beaker exec` on the tests you care about.

The pre-suite installs a puppet-agent package and a compatible puppetserver
package on the master host in preparation for running tests on the agent hosts.
It also installs this module (from your local checkout) and its dependencies.

The versions of puppet-agent and puppetserver installed on the master during
the pre-suite can be controlled in two ways:

- set `MASTER_COLLECTION` to 'pc1' (for puppet 4), 'puppet5', or 'puppet6' to
  install the latest releases from those streams, or
- set `MASTER_PACKAGE_VERSION` to a specific version of puppet-agent (like
  '5.5.10') to install that agent package and a compatible puppetserver

You may also set `DEBUG` to run beaker in debug mode.

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
library for working with puppet specifically), plus several hypervisor gems for
working with beaker and vagrant, docker, or vsphere.

### Set up the test hosts

Use `beaker-hostgenerator` generate a hosts file that describes the types of
hosts you want to test. See beaker-hostgenerator's help for more information on
available host OSes, types and roles.

Make sure your set of test hosts has at least one host with the master role and
one host with the agent role. This example creates a Centos 7 master and a
single Debian 9 agent, which will be provisioned with Docker:

```sh
bundle exec beaker-hostgenerator -t docker centos7-64mcda-debian9-64a > ./hosts.yaml
```

Decide on a collection or version of puppet-agent to use on your master, and
run the `prepare` rake task to set it up. This example installs the latest
puppet-agent and puppetserver in the puppet 5 series on the master:

```sh
MASTER_COLLECTION=puppet5 bundle exec rake prepare
````

### Run and re-run the tests

Once you've set up beaker, you can run any number of tests any number of times:

```sh
# Run all the tests
bundle exec beaker exec ./tests/
# Run all the tests in a specific directory
bundle exec beaker exec ./tests/subdir
# Run a commma-separated list of specific tests:
bundle exec beaker exec ./path/to/test.rb,./another/test.rb
```

### Clean up

To destroy the provisioned test hosts:

```sh
bundle exec beaker destroy
```
