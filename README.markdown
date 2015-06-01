#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with puppet_agent](#setup)
    * [What puppet_agent affects](#what-puppet_agent-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet_agent](#beginning-with-puppet_agent)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A module for upgrading Puppet 3.8 to Puppet-Agent from Puppet Collection 1 (Puppet 4).

## Module Description

Installs the Puppet Collection 1 repo (on systems that support repositories); migrates configuration required by Puppet to new locations used by Puppet-Agent; and installs Puppet-Agent, removing the previous Puppet installation. Expects Puppet to be installed from packages.

## Setup

### What puppet_agent affects

* Puppet, Facter, Hiera, and MCollective
* Puppet's SSL directory and puppet.conf
* MCollective's server.cfg
* Removes deprecated settings from puppet.conf
* Updates puppet.conf and server.cfg for behavioral changes in Puppet-Agent (future parser is the default, MCollective has a new varlog location).

### Setup Requirements

Must be running Puppet 3.8 with `stringify_facts` set to `false`. Agents should already be pointed at a master running `Puppet Server 2.1` or greater, and thus successfully applying catalogs compiled with the Puppet 4 language.

### Beginning with puppet_agent

Install the puppet_agent module with `puppet module install puppetlabs-puppet_agent`.

## Usage

Add the class to agents you wish to upgrade.

## Limitations

Only supports RPM-based distros: Redhat and Centos 5/6/7, Fedora 20/21.

## Development

See CONTRIBUTING.md
