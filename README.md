# puppet_agent


[![Modules Status](https://github.com/puppetlabs/puppetlabs-puppet_agent/actions/workflows/daily_unit_tests_with_nightly_puppet_gem.yaml/badge.svg?branch=main)](https://github.com/puppetlabs/puppetlabs-puppet_agent/actions/workflows/daily_unit_tests_with_nightly_puppet_gem.yaml)
[![Modules Status](https://github.com/puppetlabs/puppetlabs-puppet_agent/workflows/Static%20Code%20Analysis/badge.svg?branch=main)](https://github.com/puppetlabs/puppetlabs-puppet_agent/actions)
[![Modules Status](https://github.com/puppetlabs/puppetlabs-puppet_agent/workflows/Unit%20Tests%20with%20nightly%20Puppet%20gem/badge.svg?branch=main)](https://github.com/puppetlabs/puppetlabs-puppet_agent/actions)
[![Modules Status](https://github.com/puppetlabs/puppetlabs-puppet_agent/workflows/Unit%20Tests%20with%20released%20Puppet%20gem/badge.svg?branch=main)](https://github.com/puppetlabs/puppetlabs-puppet_agent/actions)
[![Modules Status](https://github.com/puppetlabs/puppetlabs-puppet_agent/workflows/Task%20Acceptance%20Tests/badge.svg?branch=main)](https://github.com/puppetlabs/puppetlabs-puppet_agent/actions)


#### Table of Contents
- [puppet_agent](#puppet_agent)
      - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Module Description](#module-description)
  - [Setup](#setup)
    - [What puppet_agent affects](#what-puppet_agent-affects)
    - [Setup requirements](#setup-requirements)
    - [Beginning with puppet_agent](#beginning-with-puppet_agent)
  - [Usage](#usage)
  - [Using alternate sources](#using-alternate-sources)
    - [Public downloads mirrors](#public-downloads-mirrors)
    - [Absolute paths to packages](#absolute-paths-to-packages)
    - [Alternate PE master location](#alternate-pe-master-location)
  - [Reference](#reference)
    - [Public classes](#public-classes)
    - [Private classes](#private-classes)
    - [Parameters](#parameters)
      - [Class: puppet_agent](#class-puppet_agent)
        - [`arch`](#arch)
        - [`collection`](#collection)
        - [`is_pe`](#is_pe)
        - [`manage_repo`](#manage_repo)
        - [`package_version`](#package_version)
        - [`service_names`](#service_names)
        - [`source`](#source)
        - [`absolute_source`](#absolute_source)
        - [`yum_source`](#yum_source)
        - [`apt_source`](#apt_source)
        - [`mac_source`](#mac_source)
        - [`windows_source`](#windows_source)
        - [`solaris_source`](#solaris_source)
        - [`aix_source`](#aix_source)
        - [`use_alternate_sources`](#use_alternate_sources)
        - [`alternate_pe_source`](#alternate_pe_source)
        - [`install_dir`](#install_dir)
        - [`disable_proxy`](#disable_proxy)
        - [`proxy`](#proxy)
        - [`install_options`](#install_options)
        - [`msi_move_locked_files`](#msi_move_locked_files)
        - [`wait_for_pxp_agent_exit`](#wait_for_pxp_agent_exit)
        - [`wait_for_puppet_run`](#wait_for_puppet_run)
        - [`config`](#config)
    - [Plans](#plans)
      - [`puppet_agent::run`](#puppet_agentrun)
    - [Tasks](#tasks)
      - [`puppet_agent::version`](#puppet_agentversion)
      - [`puppet_agent::install`](#puppet_agentinstall)
      - [`puppet_agent::facts_diff`](#puppet_agentfacts_diff)
      - [`puppet_agent::delete_local_filebucket`](#puppet_agentdelete_local_filebucket)
  - [Limitations](#limitations)
    - [Known issues](#known-issues)
  - [Development](#development)
  - [Codeowners](#codeowners)

## Overview

A module for installing, running, upgrading, and managing the configuration of Puppet agents. Supports upgrading from Puppet 6 puppet-agent packages to later versions including Puppet 7 and Puppet 8.

## Module Description

The puppet_agent module installs the appropriate official Puppet package repository (on systems that support repositories); migrates configuration required by Puppet to new locations used by puppet-agent; and installs the puppet-agent package, removing the previous Puppet installation.

If a package_version parameter is provided, it will ensure that puppet-agent version is installed. The package_version parameter is required to perform upgrades starting from a puppet-agent package, also this parameter can be set to "auto", ensuring that agent version matches the version on the master without having to manually update package_version after upgrading the master(s). On platforms that install packages through repos (EL, Fedora, Debian, Ubuntu, SLES), the parameter can be set to "latest" in order to install the latest available package. To only ensure the presence of the package, the parameter can be set to "present".

If a config parameter is provided, it will manage the defined agent configuration settings.

## Setup

### What puppet_agent affects

* Puppet, Facter, and Hiera.
* Puppet's SSL directory and puppet.conf.
* Removes deprecated settings from puppet.conf.

### Setup requirements

Your agents must be running a minimum version of Puppet 6. They should already be pointed at a master running Puppet Server 6 or greater, and thus successfully applying catalogs compiled with the Puppet 6 or newer language.

### Beginning with puppet_agent

Install the puppet_agent module with `puppet module install puppetlabs-puppet_agent`.

## Usage

Add the class to agents you want to upgrade, specifying the desired puppet-agent version:

``` puppet
class {'::puppet_agent':
  package_version => '7.23.0',
}
```

This will ensure the version `7.23.0` of the puppet-agent package is installed.

## Using alternate sources

In cases where you wish to download agents from sources other than the defaults you can use source parameters to change the location to grab packages from.

### Public downloads mirrors

If you wish to mirror the Puppet public downloads sites (yum.puppet.com, apt.puppet.com, downloads.puppet.com) you can provide the following parameters to change the location of downloads:

* `yum_source`
* `apt_source`
* `mac_source`
* `windows_source`
* `solaris_source`
* `aix_source`

For AIX and Solaris packages: because AIX and Solaris are PE only you must use puppetlabs-pe_repo to create repos for these platforms on the PE master, then mirror the PE master package serve.

When working with a PE installation: if you set `use_alternate_sources` to `true` you can force agent downloads to come from downloads sites (or a mirror if you set the source parameters) rather than the PE master. **WARNING** This parameter will override the default settings in PE installations to download packages from the PE master. If you wish to continue to download from the PE master _do not_ set this parameter.

### Absolute paths to packages

If your packages are already available on the target system (for example if you are using a network share) you can provide `absolute_source` the path to the packages to use during installation.

**WARNING** You must provide the full path, including the package name, for this parameter to work. This also means you cannot provide the same `absolute_source` for two different types of packages.

### Alternate PE master location

If you are using puppetlabs-pe_repo to serve packages, but want to provide a location other than the current master to serve packages: use `alternate_pe_source` to specify a seperate location where packages are located in the same structure that would be on a PE master.

## Reference

### Public classes
* [`puppet_agent`](#class-puppetagent)

### Private classes
* `puppet_agent::install`: Installs packages.
* `puppet_agent::osfamily::*`: Platform-specific preparation performed before upgrades.
* `puppet_agent::prepare`: Prepares the agent for upgrade.
* `puppet_agent::prepare::package`: Stages packages locally for install, on platforms that can't install from remote packages.
* `puppet_agent::prepare::*`: Prepare various file configurations.
* `puppet_agent::service`: Ensures the services are running.
* `puppet_agent::windows::install`: Handles Windows package installation.

### Parameters

#### Class: puppet_agent

##### `arch`

The architecture version you wish to install. Defaults to `$facts['os']['architecture']`.
``` puppet
  arch => 'x86_64'
```

##### `collection`

The Puppet Collection to track, should be a supported collection  (e.g. `puppet7` or `puppet8`).  Puppet collections contain the latest agents included in the collection's series, so `puppet7` will pull in the most recent Puppet 5 release (for example: 7.23.0).  **This parameter is required for installations not connected to Puppet Enterprise**
``` puppet
  collection => 'puppet7'
```

##### `is_pe`

Install from Puppet Enterprise (PE) repos. Enabled if communicating with a PE master.
``` puppet
  is_pe => true
```

##### `manage_repo`

Boolean to determine whether to configure zypper/yum/apt/solaris repositories. Defaults to `true`.
If set to false, it is assumed an internally hosted repository will be used for the installation,
and the native package providers will be used to query pre-configured repos on the host being upgraded.
``` puppet
  manage_repo => true
```

##### `package_version`

The package version to upgrade to. This must be explicitly specified.
``` puppet
  package_version => '7.23.0'
```
or
``` puppet
  package_version => 'auto'
```
or
``` puppet
  package_version => 'latest'
```
or
``` puppet
  package_version => 'present'
```

##### `service_names`

An array of services to start, normally `puppet`. If the array is empty, no services are started.
``` puppet
  service_names => ['puppet']
```


##### `source`

INCLUDED FOR COMPATIBILITY WITH MODULE VERSIONS 1.0/2.0. PREFER USE OF "absolute\_source", "(yum/apt/mac etc.)\_source", "alternate\_pe\_source" OVER USE OF "source".

The location to find packages. Replaces base URL for unix/MacOS agents, used as fully qualified path in windows.

Unix/MacOS
``` puppet
  source => 'https://alternate-pe-master.com:8140'
```

Windows
``` puppet
  source => 'C:/packages/puppet-agent-7.23.0-x64.msi'
```

##### `absolute_source`

Absolute ("fully qualified") source path from which you wish to download the latest version of Puppet. No path structure or package name is assumed: the fully qualified path to the package itself must be provided.
``` puppet
  absolute_source => 'C:/packages/puppet-agent-7.23.0-x64.msi'
```

##### `yum_source`

Base URL of a location or mirrors of yum.puppet.com downloads sites. Directories under the URL should match the structure of yum.puppet.com
``` puppet
  yum_source => 'https://my-puppet-yum-mirror.com'
```

##### `apt_source`

Base URL of a location or mirrors of apt.puppet.com downloads sites. Directories under the URL should match the structure of apt.puppet.com
``` puppet
  apt_source => 'https://my-puppet-apt-mirror.com'
```

##### `mac_source`

Base URL of a location or mirrors of downloads.puppet.com downloads site that serves MacOS packages. Directories under the URL should match the structure of the downloads.puppet.com site
``` puppet
  mac_source => 'https://my-puppet-downloads-mirror.com'
```

##### `windows_source`

URL of a location or mirrors of downloads.puppet.com downloads site that serves packages. Directories under the URL should match the structure of downloads.puppet.com site
``` puppet
  windows_source => 'https://my-puppet-downloads-mirror.com'
```

##### `solaris_source`

Base URL of the location of a mirror for Solaris packages. Currently, solaris packages can only be made available by using puppetlabs-pe\_repo. This means the mirror must be of a PE master package serve.
``` puppet
  solaris_source => 'https://my-pe_master-mirror.com'
```

##### `aix_source`

Base URL of the location of a mirror for AIX packages. Currently, AIX packages can only be made available by using puppetlabs-pe\_repo. This means the mirror must be of a PE master package serve.
``` puppet
  aix_source => 'https://my-pe_master-mirror.com'
```


##### `use_alternate_sources`

**ONLY APPLICABLE WHEN WORKING WITH PE INSTALLTIONS**

When set to true will force downloads to come from the values of $apt\_source, $deb\_source $mac\_source etc. rather than from the default PE master package serve. Note that this will also force downloads to ignore alternate\_pe\_source.
``` puppet
  use_alternate_sources => true
```

##### `alternate_pe_source`

Base URL of a location where packages are located in the same structure that's served by a PE master (the directory structure in PE for serving packages is created by the puppetlabs-pe\_repo module). The general structure served by PE is: `/packages/${pe_server_version}/${platform_tag}/${package_name}`
``` puppet
  alternate_pe_source => 'https://my-alternate-pe-master.com:8140'
```

##### `install_dir`

The directory the puppet agent should be installed to. This is only applicable for Windows operating systems and when upgrading the agent to a new version; it will not cause re-installation of the same version to a new location. This must use backslashes for the path separator, and be an absolute path, for example:
``` puppet
  install_dir => 'D:\Program Files\Puppet Labs'
```

##### `disable_proxy`

This setting controls whether or not the Puppet repositories are configured with proxies. Currently this is only supported on RedHat-based OSes.
``` puppet
  disable_proxy => true
```

##### `proxy`

This setting specifies the proxy with which to configure the Puppet repos. Currently this is only supported on RedHat-based OSes.
``` puppet
  proxy => 'http://myrepo-proxy.example.com'
```

##### `install_options`

An array of additional options to pass when installing puppet-agent. Each option in the array can be either a string or a hash. Each option is automatically quoted when passed to the install command.

With Windows packages, note that file paths in `install_options` must use backslashes. (Since install options are passed directly to the installation command, forward slashes aren't automatically converted like they are in `file` resources.) Backslashes in double-quoted strings _must_ be escaped, while backslashes in single-quoted strings _can_ be escaped. The default value for Windows packages is `REINSTALLMODE="amus"`.

The full list of supported MSI properties can be found [here](https://puppet.com/docs/puppet/latest/install_agents.html#msi_properties).

The Puppet installer can disable the [Windows path length limit](https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation) (260 character `MAX_PATH` limitation, requires Windows 10 1607 or later). This behavior is opt-in and can be controlled by the presence of the `ENABLE_LONG_PATHS` install option (the value does not matter). (*requires Puppet >= 6.25.0/7.10.0*)

``` puppet
  install_options => ['PUPPET_AGENT_ACCOUNT_DOMAIN=ExampleCorp', 'PUPPET_AGENT_ACCOUNT_USER=bob', 'PUPPET_AGENT_ACCOUNT_PASSWORD=password', 'ENABLE_LONG_PATHS=true']
```

For [gMSAs](https://docs.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview), you must specify the domain and gMSA user, such as:

``` puppet
  install_options => ['PUPPET_AGENT_ACCOUNT_DOMAIN=<AGENT_DOMAIN_NAME>', 'PUPPET_AGENT_ACCOUNT_USER=<gMSA_USER>']
```  

##### `msi_move_locked_files`

This is only applicable for Windows operating systems and for Puppet 5 prior to 5.5.17 or Puppet 6 prior to 6.8.0. There may be instances where file locks cause unnecessary service restarts.  By setting to true, the module will move files prior to installation that are known to cause file locks. By default this is set to false.

``` puppet
  msi_move_locked_files => true
```

In case `msi_move_locked_files` is set to `true` while upgrading to Puppet 5 following 5.5.17 or Puppet 6 following 6.8.0, Puppet can get into a state where `puppet --version` reports the older version(5.5.16) while the package reported by Windows is the new version(5.5.17). To recover from this case `ADDLOCAL=ALL` must be added to install_options
``` puppet
  install_options => ['REINSTALLMODE="amus"', 'ADDLOCAL=ALL']
```

#### `wait_for_pxp_agent_exit`

This is only applicable for Windows operating systems and pertains to /files/install_puppet.ps1 script. This parameterizes the module to define the wait time for the PXP agent to end successfully. The default value is 2 minutes and the timeout value must be defined in milliseconds. Example below, 8 minutes is equal to 480000.

``` puppet
  wait_for_pxp_agent_exit => 480000
```

#### `wait_for_puppet_run`

This is only applicable for Windows operating systems and pertains to /files/install_puppet.ps1 script. This parameterizes the module to define the wait time for the current puppet agent run to end successfully. The default value is 2 minutes and the timeout value must be defined in milliseconds. Example below, 8 minutes is equal to 480000.

``` puppet
  wait_for_puppet_run => 480000
```

#### `config`

An array of configuration data to enforce. Each configuration data item must be a Puppet\_agent::Config hash, which has keys for puppet.conf section, setting, and value.  This parameter is constrained to managing only a predetermined set of configuration settings. E.g. runinterval. The optional "ensure" key in a Puppet\_agent::Config hash can be used to ensure a setting is absent. In the example below, the runinterval setting in the main section is set to 1 hour, and a local environment setting is ensured absent.

``` puppet
  config => [{section => main, setting => runinterval, value => '1h'},
             {section => main, setting => environment, ensure => absent}]
```

Valid agent settings are defined by the [`Puppet_agent::Config_setting`](types/config_setting.pp) type alias.

### Plans

#### `puppet_agent::run`

Starts a Puppet agent run on the specified targets.

**Parameters**

- `targets`: A list of targets to start the Puppet agent run on.

**Return value**

Returns a `ResultSet` object. Targets that do not have an agent installed will have a failing
`Result` object. For targets that have an agent installed and successfully ran the agent,
the `Result` object will include the output of the agent run, the detailed exit code, and the
contents of the run report.

```
{
  "_output": <output>,
  "exitcode": <exitcode>,
  "report": <report>
}
```

### Tasks

#### `puppet_agent::version`

Checks for the version of puppet-agent package installed.

**Return value**

The `puppet_agent::version` task returns a Result on success specifying the version of the agent installed and how it was detected.

```
{
  "version": <version>,
  "source": <source>
}
```

#### `puppet_agent::install`

Installs the puppet-agent package.  This task should not be used for upgrading agents particularly Windows agents which have requirements other than just installing the puppet-agent msi.
For upgrading Windows agents please use the `puppet_agent` class through your standard Puppet deployment or via [Bolt with Puppet apply](https://puppet.com/docs/bolt/latest/applying_manifest_blocks.html).    

> **Note:** The `puppet_agent::install_shell` task requires the `facts::bash` implementation from the [facts](https://forge.puppet.com/puppetlabs/facts) module. Both the `puppet_agent` and `facts` modules are packaged with Bolt. For use outside of Bolt make sure the `facts` module is installed to the same `modules` directory as `puppet_agent`.

**Return value**

The task returns the output of the installation script.


#### `puppet_agent::facts_diff`

Executes `puppet facts diff` action to check if there are differences between Facter 3 and Facter 4 outputs. (*requires Puppet >= 6.21.0*)

**Parameters**

- `exclude`: Regex used to exclude specific facts from diff. (*requires Puppet >= 6.22.0*)

**Return value**

Returns a `ResultSet` object containing the differences.

```
{
  "foo": {
    "new_value": "bar",
    "old_value": "baz"
  }
}
```

#### `puppet_agent::delete_local_filebucket`

Removes the local filebucket cache. The location of the filebucket is determined using the `clientbucketdir` puppet config.

**Parameters**

- `force`: ignore nonexistent files and errors.

**Return value**

Returns a `ResultSet` object.

```
{:success=>true}
```

## Limitations

Mac OS X/macOS open source packages are not supported in puppet_agent module releases prior to v2.1.0.

### Known issues

Windows platforms:

* To upgrade the agent by executing `puppet agent -t` interactively in a console, you must leave the console open and wait for the upgrade to finish before attempting to use the `puppet` command again. During upgrades the upgrade scripts use a 'pid file' located at Drive:\ProgramData\PuppetLabs\puppet\cache\state\puppet_agent_upgrade.pid to indicate there is an upgrade in progress. The 'pid file' also contains the process ID of the upgrade, if you wish to track the process itself.

* MSI installation failures do not produce any error. If the install fails, puppet_agent continues to be applied to the agent. If this happens, you'll need to examine the MSI log file to determine the failure's cause. You can find the location of the log file in the debug output from either a puppet apply or an agent run; the log file name follows the pattern `puppet-<timestamp>-installer.log`.

* If the upgrade is from Puppet 5 prior to 5.5.17 or Puppet 6 prior to 6.8.0 to newer version and `msi_move_locked_files` is set to `true`, Puppet can get into a state where `puppet --version` reports the older version(5.5.16) while the package reported by Windows is the new version(5.5.17). To recover from this case `ADDLOCAL=ALL` must be added to install_options
``` puppet
  install_options => ['REINSTALLMODE="amus"', 'ADDLOCAL=ALL']
```

\*NIX platforms:

* Upgrading on most \*NIX platforms (Linux, AIX, Solaris 11) will end the run after the puppet-agent upgrade finishes. This is to avoid unexpected behavior if already loaded Ruby code happens to interact with newer code that came with the upgrade, or viceversa. If run as a daemon, Puppet will automatically start a new agent run after the upgrade finishes.

## Development

Puppet, Inc. modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our [module contribution guide.](https://puppet.com/docs/puppet/latest/contributing.html)

## Codeowners

See [CODEOWNERS](CODEOWNERS)

Tickets: https://tickets.puppetlabs.com/browse/MODULES
