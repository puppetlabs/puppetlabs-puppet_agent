# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0]

### Summary
The addition of several OS support features and a considerable amount of compatibility and bug fixes. 

### Known issues
While this release adds considerable features and bug fixes the following areas are known issues and require more work:
- For Windows, trigger an agent run after upgrade to get Puppet to create the nessesary directory structures.
- There is currently ongoing work to allow for upgrading from 2015.2.x to 2015.3.x.
- Solaris 11 support work is in progess, but currently still buggy.

### Features
- Adds support for SLES 10, Solaris 10, AIX.
- Add OSX 10.9 upgrades.
- Add no-internet Windows upgrade in PE.
- Added puppet_master_server fact.
- Adds `/opt/puppetlabs` to the managed directories.
- Additional test checks for /opt/puppetlabs.

### Bugfixes
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

### Bugfixes
- For Windows PE upgrades, by default install the agent version corresponding to the PE master.
- Reset puppet.conf's classfile setting.

## [0.2.0] - 2015-07-21

### Summary

Added support for most systems with both Puppet 3.8 and Puppet-Agent packages released by Puppet Labs.

### Features
- Support for Debian 6/7, Ubuntu 12.04/14.04, SLES 12, and Windows 2003 through 2012R2.

### Bugfixes
- Fix puppet_agent module doesn't touch puppet.conf settings outside an INI section (PUP-4886)
- Made internal classes private, using stdlib's assert_private helper
- Migrate SSL cert directories individually to account for individual settings (PUP-4690)
- Migrated mcollective configuration should prefer the new plugin location (PUP-4658)
- Fixed updating mcollective configuration files with multiple libdir or plugin.yaml definitions (PUP-4746)

## [0.1.0] - 2015-06-02
### Added
- Initial release of puppetlabs-puppet_agent, supporting Redhat and Centos 5/6/7.
