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
    * [Known issues](#known-issues)
7. [Development - Guide for contributing to the module](#development)

## Overview

A module for upgrading Puppet 3.8 agents to puppet-agent in Puppet Collection 1 (i.e., Puppet 4).

## Module Description

The puppet_agent module installs the Puppet Collection 1 repo (on systems that support repositories); migrates configuration required by Puppet to new locations used by puppet-agent; and installs the puppet-agent package, removing the previous Puppet installation. This module expects Puppet to be installed from packages.

## Setup

### What puppet_agent affects

* Puppet, Facter, Hiera, and MCollective.
* Puppet's SSL directory and puppet.conf.
* MCollective's server.cfg and client.cfg.
* Removes deprecated settings from puppet.conf.
* Updates puppet.conf and server.cfg for behavioral changes in puppet-agent (future parser is now the default, and MCollective has a new varlog location).

### Setup Requirements

Your agents must be running Puppet 3.8 with `stringify_facts` set to 'false'. Agents should already be pointed at a master running Puppet Server 2.1 or greater, and thus successfully applying catalogs compiled with the Puppet 4 language.

### Beginning with puppet_agent

Install the puppet_agent module with `puppet module install puppetlabs-puppet_agent`.

## Usage

Add the class to agents you want to upgrade:

~~~puppet
include ::puppet_agent
~~~

This installs the latest released version of Puppet from Puppet Collection 1.

To upgrade with this module, first stand up a Puppet Server 2.1 master---which supports backward compatibility with Puppet 3 agents---and point the agent you want to upgrade at that master. Once you've confirmed the agent runs successfully against the new master, and thus the Puppet 4 language, apply the class to the agent and confirm that it checks back in after a successful upgrade. Further details on upgrading are available [here](http://docs.puppetlabs.com/puppet/4.2/reference/upgrade_major_pre.html).

As part of preparing the agent for Puppet 4, the module performs several significant steps:
* Copies SSL files (based on their location settings: ssldir, certdir, privatedir, privatekeydir, publickeydir, requestdir) to new Puppet 4 defaults, and restore those settings to default in puppet.conf.
* Resets non-deprecated settings to defaults: disable_warnings, vardir, rundir, libdir, confdir, ssldir, and classfile.
* Resets logfile in MCollective's server.cfg and client.cfg.
* Adds new libdir and plugin.yaml locations to MCollective's server.cfg and client.cfg.

##Reference

###Public classes
* [`puppet_agent`](#class-puppetagent)

###Private classes
* `puppet_agent::install`: Installs packages.
* `puppet_agent::prepare`: Prepares the agent for upgrade.
* `puppet_agent::service`: Ensures the services are running.

###Parameters

####Class: puppet_agent

#####`arch`

The architecture version you wish to install. Defaults to `$::architecture`. This parameter is [ignored](#known-issues) in Windows Server 2003.

#####`package_name`

The package to upgrade to, i.e., `puppet-agent`. Currently, the default and only accepted value is `puppet-agent`.

#####`service_names`

An array of services to start, normally `puppet` and `mcollective`. If the array is empty, no services are started.

#####`source`

Alternate source from which you wish to download the latest version of Puppet.

## Limitations

This module supports:

* RHEL 5, 6, 7
* Centos 5, 6, 7
* Debian 6, 7
* Ubuntu 12.04, 14.04
* Windows Server 2003 or later

###Known issues

* In masterless environments, modules installed manually on individual agents cannot be found after upgrading to Puppet 4.x. You should reinstall these modules on the agents with `puppet module install`.

In addition, there are several known issues with Windows:

* To upgrade the agent by executing `puppet agent -t` interactively in a console, you must close the console and wait for the upgrade to finish before attempting to use the `puppet` command again.
* MSI installation failures do not produce any error. If the install fails, puppet_agent continues to be applied to the agent. If this happens, you'll need to examine the MSI log file to determine the failure's cause. You can find the location of the log file in the debug output from either a puppet apply or an agent run; the log file name follows the pattern `puppet-<timestamp>-installer.log`.
* On Windows Server 2003, only x86 is supported, and the `arch` parameter is ignored. If you try to force an upgrade to x64, Puppet installs the x86 version with no error message.
* On Windows Server 2003 with Puppet Enterprise, the default download location is unreachable. You can work around this issue by specifying an alternate download URL in the `source` parameter.
 
Specifically in the 1.1.0 Release:
* For Windows, you must trigger an agent run after upgrading so that Puppet can create the necessary directory structures.
* Upgrading from 2015.2.x to 2015.3.x is not yet supported.
* Solaris 11 is not yet supported.

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

To contribute to the puppet_agent module, see [Contributing.md](https://github.com/puppetlabs/puppetlabs-puppet_agent/blob/master/CONTRIBUTING.md). You can also read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

