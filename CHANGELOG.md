# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.3.1] - 2016-11-17

### Summary
This is a bug-fix release

### Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Mac OS X Open Source package upgrades are not yet implemented.

### Bug fixes
- Fix upgrading a global Solaris zone would break upgrading other zones ([MODULES-4092](https://tickets.puppetlabs.com/browse/MODULES-4092))
- Fix line endings of `install_puppet.bat`
- Fix upgrading between releases of the same package version ([MODULES-4030](https://tickets.puppetlabs.com/browse/MODULES-4030))

## [1.3.0] - 2016-10-19

### Summary
The addition of several OS support features and a considerable amount of compatibility and bug fixes. 

### Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Mac OS X Open Source package upgrades are not yet implemented.

### Features
- Add support for Ubuntu 16.04 and Fedora 23
- Allow MSI install path to be defined on Windows ([MODULES-3571](https://tickets.puppetlabs.com/browse/MODULES-3571))
- Allow agent upgrade on non-English versions for Windows ([MODULES-3636](https://tickets.puppetlabs.com/browse/MODULES-3636))
- Allow the use of a hosted repository for packages ([MODULES-3872](https://tickets.puppetlabs.com/browse/MODULES-3872))
- Remove POWER8 restriction for AIX ([MODULES-3912](https://tickets.puppetlabs.com/browse/MODULES-3912))

### Bug fixes
- Fix upgrade process on Windows using a PID file ([MODULES-3433](https://tickets.puppetlabs.com/browse/MODULES-3433))
- Fix metadata to indicate support for Puppet 3.7
- Fix upgrade process on Windows by stopping PXP service ([MODULES-3449](https://tickets.puppetlabs.com/browse/MODULES-3449))
- Add extra logging during upgrade process on Windows
- Disable SSL verification on Xenial ([PE-16317](https://tickets.puppetlabs.com/browse/PE-16317))
- Fix preserving the environment name when upgrading on Windows ([MODULES-3517](https://tickets.puppetlabs.com/browse/MODULES-3517))
- Puppet run will fail if `stringify_facts` is set to `true` ([MODULES-3591](https://tickets.puppetlabs.com/browse/MODULES-3591) [MODULES-3951](https://tickets.puppetlabs.com/browse/MODULES-3951))
- Fix infinite loop scenario on Windows during upgrade ([MODULES-3434](https://tickets.puppetlabs.com/browse/MODULES-3434))
- Fix the waiting process on Windows during an upgrade ([MODULES-3657](https://tickets.puppetlabs.com/browse/MODULES-3657))
- Fix duplicate resource error on AIX with PE ([MODULES-3893](https://tickets.puppetlabs.com/browse/MODULES-3893))
- Fix minor errors in `RakeFile` and `spec_helper_acceptance`
- Fix setting permissions on Windows package
- Update GPG Keys ([RE-7976](https://tickets.puppetlabs.com/browse/RE-7976))
- Fix puppet-agent suffix on Fedora ([PE-16317](https://tickets.puppetlabs.com/browse/PE-16317))
- Fix `unless` condition on SUSE and RedHat GPG key imports ([MODULES-3894](https://tickets.puppetlabs.com/browse/MODULES-3894))
- Avoid `Unknown variable` errors in Puppet 4 ([MODULES-3896](https://tickets.puppetlabs.com/browse/MODULES-3896))
- Fix logic for detecting Solaris 11 package name ([PE-17663](https://tickets.puppetlabs.com/browse/PE-17663))
- Fix spec test fixtures to use the Forge
- Add Windows examples to README
- Fix acceptance tests ignoring resource errors ([MODULES-3953](https://tickets.puppetlabs.com/browse/MODULES-3953))
- Add acceptance tests for `manage_repo` parameter ([MODULES-3872](https://tickets.puppetlabs.com/browse/MODULES-3872))
- Fix Windows package download URL ([MODULES-3970](https://tickets.puppetlabs.com/browse/MODULES-3970))

## [1.2.0] - 2016-05-04

### Summary
Supports upgrades from puppet-agent packages! Applies to both PE and FOSS, for example upgrades from
PE 2015.3.2 to 2015.3.3 and puppet-agent 1.3.0 to 1.4.0 are supported. Upgrading from older Puppet 3
versions is also no longer explicitly prevented. Adds support for Solaris 11.

### Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Upgrades on Fedora systems are not supported.

Newly identified issues:
- Mac OS X Open Source package upgrades are not yet implemented.
- AIX package names are based on PowerPC architecture version. PowerPC 8 is not yet supported.

### Features
- Upgrades between puppet-agent packages, such as 2015.2.x to 2015.3.x.
- Adds support for Solaris 11.
- The `pluginsync` setting was deprecated in `puppet-agent 1.4.0`. This module removes it when upgrading to
that version or later unless otherwise managed.
- Remove the lower-version requirement. All Puppet 3 versions potentially can be upgraded, although
testing is only performed starting with Puppet/PE 3.8. Earlier versions likely work back to 3.5, as long as
the manifest is compiled using 3.7+ with future parser enabled.

### Bug fixes
- Fixes the release identification for Amazon Linux distributions to use EL 6 packages.
- Fix Debian upgrades for PE.
- Support upgrades of 32-bit Windows packages for PE (via pe_repo).
- Fixed an issue that would cause compilation to fail with `Unknown function: 'pe_compiling_server_aio_build'`
in some environments.

## [1.1.0] - 2016-03-01

### Summary
The addition of several OS support features and a considerable amount of compatibility and bug fixes. 

### Known issues
While this release adds considerable features and bug fixes the following areas are known issues and require more work:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- There is currently ongoing work to allow for upgrading from 2015.2.x to 2015.3.x.
- Solaris 11 support work is in progess, but currently still buggy.

### Features
- Adds support for SLES 10, Solaris 10, AIX.
- Add OSX 10.9 upgrades.
- Add no-internet Windows upgrade in PE.
- Added puppet_master_server fact.
- Adds `/opt/puppetlabs` to the managed directories.
- Additional test checks for /opt/puppetlabs.

### Bug fixes
- Use rspec expect syntax for catching errors.
- Base master_agent_version on pe_compiling_server_aio_build().
- Update in metadata to include support for SLES 10 and 11.
- Ensure pe-puppet/mcollective services stopped after removing the PUPpuppet and PUPmcollective packages.
- Small readme typo fix.
- Pass in Puppet agent PID as command line parameter to avoid recreating install_puppet.bat at every agent run.
- Allow using the internal mirror when resolving gems.
- Add Solaris 10 sparc to supported arch.
- No longer converts Windows file resource to RAL catalog.
- Create/use local_package_dir in params.pp.
- Fix behavior for non-PE.
- Fix specs for Windows changes.
- Remove check for null $service_names.
- Fix linter errors on Windows PR 66.
- Use common_appdata on Windows.
- Removes management of the puppet/mco services on Windows systems.
- Add start/wait to Windows upgrade.
- Pass in configured server to Windows MSI.
- Fixes SLES11 GPG key import issue.
- Fixed regex for SLES compatibility.
- Ensures local MSI package resource defined on Windows.

## [1.0.0] - 2015-07-28

### Summary

Fixed minor bugs and improved documentation. Now a Puppet Supported module.

### Features
- Improved documentation of upgrade process.

### Bug fixes
- For Windows PE upgrades, by default install the agent version corresponding to the PE master.
- Reset puppet.conf's classfile setting.

## [0.2.0] - 2015-07-21

### Summary

Added support for most systems with both Puppet 3.8 and Puppet-Agent packages released by Puppet Labs.

### Features
- Support for Debian 6/7, Ubuntu 12.04/14.04, SLES 12, and Windows 2003 through 2012R2.

### Bug fixes
- Fix puppet_agent module doesn't touch puppet.conf settings outside an INI section (PUP-4886)
- Made internal classes private, using stdlib's assert_private helper
- Migrate SSL cert directories individually to account for individual settings (PUP-4690)
- Migrated mcollective configuration should prefer the new plugin location (PUP-4658)
- Fixed updating mcollective configuration files with multiple libdir or plugin.yaml definitions (PUP-4746)

## [0.1.0] - 2015-06-02
### Added
- Initial release of puppetlabs-puppet_agent, supporting Redhat and Centos 5/6/7.
