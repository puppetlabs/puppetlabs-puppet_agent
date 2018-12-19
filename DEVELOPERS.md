# Development on puppet-agent module

Welcome to the `puppet-agent` module! This is a document which will help
guide you to getting started on development. The key sections here are:

1. [Iterative code changes](#iterative)
1. [Important files to understand repo](#files)
1. [Other tools for development](#tools)
1. [Testing](#testing)

## Iterative code changes<a name="iterative"/>

### Docker workflow

Iterative development is the practice of reducing the amount of time
between making a code change and seeing the result of that change.
Below are a few methods to do this style of development.

For iterative development using Docker, see:
- docker/bin/upgrade.sh
- docker/bin/versions.sh
*Ubuntu*
- docker/ubuntu/Dockerfile
*CentOS*
- docker/centos/Dockerfile

*Note*: This will not start systemd services due to a limitation in
Docker. It will upgrade packages properly, and should be useful for the
majority of development on the module.

### VMPooler workflow

1. Forward your ssh key to do github operations.
1. Ensure editor supports editing remote files.
1. Checkout a vmpooler machine.
1. Clone the module.
1. Run `puppet apply` to test it as you work.

### Development for Puppet Enterprise exclusive platforms

#### Manual testing workflow
1. Install an "old" PE on a master (typically RHEL).
1. Declare the pe_repo classes for each agent you're testing upgrades for (e.g. like Windows, Fedora, etc.) using the PE Console.
1. Install a "new" PE on the same master.
1. Run puppet agent so that the pe_repo platforms have the new agent package.
1. Copy local puppetlabs-puppet_agent module over to the /etc/puppetlabs/code/environment/production/modules directory.
1. Install any module dependencies on the master via puppet module install (which you can get from the metadata.json file).
1. Grab a VM to use as the agent, either in a local hypervisor or in VCloud.
1. Test an upgrade scenario by installing the "old" agent by curling the old PE's install.bash script onto the agent VM and running puppet agent -t to link up with the master. Make sure to sign the agent’s CSR on the master.
1. Declare the puppet_agent class in the site manifest (site.pp) declaring the master's agent as the puppet agent version for the agent node. Use the version returned by the master’s aio_agent_version fact.
1. On the agent node, run `puppet agent -t`.
1. To check that the upgrade was performed successfully, check the aio_agent_version fact on the agent to see if it matches what's reported on the master.

## Important files to understand repo<a name="files"/>

These are a few key files to look at to understand the basic flow of how the repository works:

- manifests/init.pp -- This is the entrypoint for the module. This file
 describes the module's parameters, includes other classes(e.g.
 `prepare` and `install`), and adds some exception cases for a variety
 of platforms.
- templates/do_install.sh.erb -- This calls the other scripts in the same directory.

## Other tools for development<a name="tools"/>

This ad-hoc job can be used to run CI against a branch
[here](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/puppet-agent/view/puppetlabs-puppet_agent%20module/view/ad-hoc/).

This link/job may be updated with a new workflow in the near future.

## Testing<a name="testing"/>

Prior to committing any changes, ensure the tests pass locally.

### Getting Started

Our Puppet modules provide [`Gemfile`](./Gemfile)s, which can tell a Ruby package manager such as [bundler](http://bundler.io/) what Ruby packages,
or Gems, are required to build, develop, and test this software.

Please make sure you have [bundler installed](http://bundler.io/#getting-started) on your system, and then use it to
install all dependencies needed for this project in the project root by running

```shell
% bundle install --path .bundle/gems
Fetching gem metadata from https://rubygems.org/........
Fetching gem metadata from https://rubygems.org/..
Using rake (10.1.0)
Using builder (3.2.2)
-- 8><-- many more --><8 --
Using rspec-system-puppet (2.2.0)
Using serverspec (0.6.3)
Using rspec-system-serverspec (1.0.0)
Using bundler (1.3.5)
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

NOTE: some systems may require you to run this command with sudo.

If you already have those gems installed, make sure they are up-to-date:

```shell
% bundle update
```

### Running Tests

With all dependencies in place and up-to-date, run the tests:

#### Unit Tests

```shell
% bundle exec rake spec
```

This executes all the [rspec tests](http://rspec-puppet.com/) in the directories defined [here](https://github.com/puppetlabs/puppetlabs_spec_helper/blob/699d9fbca1d2489bff1736bb254bb7b7edb32c74/lib/puppetlabs_spec_helper/rake_tasks.rb#L17) and so on.
rspec tests may have the same kind of dependencies as the module they are testing. Although the module defines these dependencies in its [metadata.json](./metadata.json),
rspec tests define them in [.fixtures.yml](./fixtures.yml).

#### Acceptance Tests

Some Puppet modules also come with acceptance tests, which use [beaker][]. These tests spin up a virtual machine under
[VirtualBox](https://www.virtualbox.org/), controlled with [Vagrant](http://www.vagrantup.com/), to simulate scripted test
scenarios. In order to run these, you need both Virtualbox and Vagrant installed on your system.

Run the tests by issuing the following command

```shell
% bundle exec rake spec_clean
% bundle exec rspec spec/acceptance
```

This will now download a pre-fabricated image configured in the [default node-set](./spec/acceptance/nodesets/default.yml),
install Puppet, copy this module, and install its dependencies per [spec/spec_helper_acceptance.rb](./spec/spec_helper_acceptance.rb)
and then run all the tests under [spec/acceptance](./spec/acceptance).

### Writing Tests

#### Unit Tests

When writing unit tests for Puppet, [rspec-puppet][] is your best friend. It provides tons of helper methods for testing your manifests against a
catalog (e.g. contain_file, contain_package, with_params, etc). It would be ridiculous to try and top rspec-puppet's [documentation][rspec-puppet_docs]
but here's a tiny sample:

Sample manifest:

```puppet
file { "a test file":
  ensure => present,
  path   => "/etc/sample",
}
```

Sample test:

```ruby
it 'does a thing' do
  expect(subject).to contain_file("a test file").with({:path => "/etc/sample"})
end
```

#### Acceptance Tests

Writing acceptance tests for Puppet involves [beaker][] and its cousin [beaker-rspec][]. A common pattern for acceptance tests is to create a test manifest, apply it
twice to check for idempotency or errors, then run expectations.

More information about beaker and beaker-puppet is [here][https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/master/acceptance].

```ruby
it 'does an end-to-end thing' do
  pp = <<-EOF
    file { 'a test file':
      ensure  => present,
      path    => "/etc/sample",
      content => "test string",
    }

  apply_manifest(pp, :catch_failures => true)
  apply_manifest(pp, :catch_changes => true)

end

describe file("/etc/sample") do
  it { is_expected.to contain "test string" }
end

```

## If you have commit access to the repository

Even if you have commit access to the repository, you still need to go through the process above, and have someone else review and merge
in your changes.  The rule is that **all changes must be reviewed by a project developer that did not write the code to ensure that
all changes go through a code review process.**

The record of someone performing the merge is the record that they performed the code review. Again, this should be someone other than the author of the topic branch.

## Get Help

### On the web
* [Puppet help messageboard](http://puppet.com/community/get-help)
* [Writing tests](https://docs.puppet.com/guides/module_guides/bgtm.html#step-three-module-testing)
* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)

### On chat
* Slack (slack.puppet.com) #forge-modules, #puppet-dev, #windows, #voxpupuli


[rspec-puppet]: http://rspec-puppet.com/
[rspec-puppet_docs]: http://rspec-puppet.com/documentation/
[beaker]: https://github.com/puppetlabs/beaker
[beaker-rspec]: https://github.com/puppetlabs/beaker-rspec
