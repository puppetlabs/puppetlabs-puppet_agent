#puppet_agent

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with puppet_agent](#setup)
    * [What puppet_agent affects](#what-puppet_agent-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet_agent](#beginning-with-puppet_agent)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference](#reference)
    * [Public classes](#public-classes)
    * [Private classes](#private-classes)
    * [Parameters](#parameters)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

A module for upgrading Puppet 3.8 agents to puppet-agent in Puppet Collection 1 (i.e., Puppet 4).

## Module Description

The puppet_agent module installs the Puppet Collection 1 repo (on systems that support repositories); migrates configuration required by Puppet to new locations used by puppet-agent; and installs the puppet-agent package, removing the previous Puppet installation. This module expects Puppet to be installed from packages.

## Setup

### What puppet_agent affects

* Puppet, Facter, Hiera, and MCollective.
* Puppet's SSL directory and puppet.conf.
* MCollective's server.cfg.
* Removes deprecated settings from puppet.conf.
* Updates puppet.conf and server.cfg for behavioral changes in puppet-agent (future parser is the now the default, and MCollective has a new varlog location).

### Setup Requirements

You must be running Puppet 3.8 with `stringify_facts` set to 'false'. Agents should already be pointed at a master running Puppet Server 2.1 or greater, and thus successfully applying catalogs compiled with the Puppet 4 language.

### Beginning with puppet_agent

Install the puppet_agent module with `puppet module install puppetlabs-puppet_agent`.

## Usage

Add the class to agents you want to upgrade:

~~~puppet
include ::puppet_agent
~~~

##Reference

###Public classes
* [`puppet_agent`](#class-puppetagent)

###Private classes
* `puppet_agent::config` : Configures the services.
* `puppet_agent::install`: Installs packages.
* `puppet_agent::prepare`: Prepares the agent for upgrade.
* `puppet_agent::service`: Ensures the services are running.

###Parameters

####Class: puppet_agent

#####`package_name`

The package to upgrade to, i.e., `puppet-agent`. Currently, the default and only accepted value is `puppet-agent`.

#####`service_name`

An array of services to start, normally `puppet` and `mcollective`. If the array is empty, no services are started.

## Limitations

Supports only RPM-based distros: Redhat and Centos 5/6/7.

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

To contribute to the puppet_agent module, see [Contributing.md](https://github.com/puppetlabs/puppetlabs-puppet_agent/blob/master/CONTRIBUTING.md). You can also read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

