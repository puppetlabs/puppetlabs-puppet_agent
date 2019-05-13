# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [2.1.2] - 2019-05-13

### Summary
Update for the URLs used to retrieve Puppet Agent. Fix for using the modules in a non PE Environment

### Bug fixes
- The Puppet Agent artifacts are now retrieved from *.puppet.com instead of *.puppetlabs.com ([RE-12326](https://tickets.puppetlabs.com/browse/RE-12326))
- set PC1 as the default Puppet Agent repository

## [2.1.1] - 2019-03-28

### Summary
Quick fix release for windows environment issue

### Bug fixes
- Update installation .ps1 script to force environment to production when executing "puppet config" ([MODULES-8821](https://tickets.puppetlabs.com/browse/MODULES-8821))

## [2.1.0] - 2019-03-26

### Summary
New parameters for managing package sources to allow for targeting mirrors. SLES and MacOS support for open-source installs. Better service management for windows installations

### Features
- Added SLES support for open-source installations ([MODULES-8598](https://tickets.puppetlabs.com/browse/MODULES-8598))
- Added MacOS support for open-source installations ([MODULES-8599](https://tickets.puppetlabs.com/browse/MODULES-8599))
- Error reporting for windows background upgrades ([MODULES-8554](https://tickets.puppetlabs.com/browse/MODULES-8554))
- New source parameters for managing alternate sources (like mirrors) ([MODULES-6604](https://tickets.puppetlabs.com/browse/MODULES-6604))

### Bug fixes
- Fix inherited permissions exec resource on windows ([MODULES-8406](https://tickets.puppetlabs.com/browse/MODULES-8406))
- Fix service management for puppet > 6 ([MODULES-8319](https://tickets.puppetlabs.com/browse/MODULES-8319))
- No longer passing environment for windows installations ([MODULES-4730](https://tickets.puppetlabs.com/browse/MODULES-4730))
- Fix rpm import of gpg keys for newer SLES ([MODULES-8583](https://tickets.puppetlabs.com/browse/MODULES-8583))
- Wait on any hanging pxp-agent processes in windows installations ([FM-7628](https://tickets.puppetlabs.com/browse/FM-7628))
- Update parameters to use 'server_list' when provided rather than the 'server' setting
- Update windows installations to always run service management outside of the initial puppet run (i.e. restart any services after the upgrade without using puppet)

## [2.0.1] - 2019-01-17

### Summary
New Installation tasks using [Bolt](https://github.com/puppetlabs/bolt), Updated module deps, Migration from
batch to powershell for windows upgrades

### Features
- Bolt task installations
- Updated module dependencies
- Powershell scripts for Windows upgrades

### Bug fixes
- Windows installations now recover service state on failed upgrades

## [1.7.0] - 2018-09-18

### Summary
Bugfix and compatibility update for Puppet 6

### Features
- Support for changes to Fedora package naming in Puppet 5 and 6
- Refactor OSX upgrades to be like Solaris and Windows, using an external script

## [1.6.2] - 2018-07-26

### Summary
Compatibility update for PE packaging changes

### Features
- Support for new pe_repo tarballs that use repo names matching open source.

## [1.6.1] - 2018-06-29

### Summary
Minor bugfix release

### Features
- Add Ubuntu 18.04 support
- Add skip_if_unavailable to yumrepo resource ([MODULES-4424](https://tickets.puppetlabs.com/browse/MODULES-4424))

### Bug fixes
- Do not manage PA version on PE infra nodes ([MODULES-5230](https://tickets.puppetlabs.com/browse/MODULES-5230))
- Fix update failure for FIPS ([MODULES-7329](https://tickets.puppetlabs.com/browse/MODULES-7329))

## [1.6.0] - 2018-03-21

### Summary
This is the last release that will support Puppet 3.x

### Features
- Make management of /etc/pki directory optional ([MODULES-6068](https://tickets.puppetlabs.com/browse/MODULES-6068))
- OSX 10.13 is now supported
- RHEL 7 AArch64 is now supported

### Bug fixes
- Fix version tag on Amazon Linux ([MODULES-5637](https://tickets.puppetlabs.com/browse/MODULES-5637))
- Stop all services prior to upgrading on Windows ([PE-23563](https://tickets.puppetlabs.com/browse/PE-23563))
- Output token privileges for current user on Windows
- Update testing matrix
- Pin resources for Puppet 3.x compatibility ([MODULES-6708](https://tickets.puppetlabs.com/browse/MODULES-6708), [MODULES-6717](https://tickets.puppetlabs.com/browse/MODULES-6717))
- Pin rspec-puppet to 2.6 due to bug in rspec-puppet ([MODULES-6717](https://tickets.puppetlabs.com/browse/MODULES-6717))

## [1.5.0] - 2017-11-29

### Summary
This is a feature and bug-fix release

### Features
- Add ability to manage the `stringify_facts` setting ([MODULES-5953](https://tickets.puppetlabs.com/browse/MODULES-5953))
- Upgrades to Puppet 5 are now supported on RPM-based platform ([MODULES-5633](https://tickets.puppetlabs.com/browse/MODULES-5633))
- Debian 9 is now supported

### Bug fixes
- Solaris 10 upgrades now work for Puppet Enterprise 2017.3 ([MODULES-5942](https://tickets.puppetlabs.com/browse/MODULES-5942)) and ([MODULES-3787](https://tickets.puppetlabs.com/browse/MODULES-3787))
- AIX upgrades now work for Puppet Enterprise 2017.3 ([MODULES-5979](https://tickets.puppetlabs.com/browse/MODULES-5979))
- Downgrading the agent on Windows no longer breaks the installation ([MODULES-5622](https://tickets.puppetlabs.com/browse/MODULES-5622))

## [1.4.1] - 2017-07-27

### Summary
This is a bug-fix release

### Bug fixes
- The system package provider is explicitly selected on Solaris 10 for installing puppet-agent ([MODULES-4547](https://tickets.puppetlabs.com/browse/MODULES-4547))
- `puppet lookup` and other operations with `strict_variables` enabled will now work with this module ([MODULES-5168](https://tickets.puppetlabs.com/browse/MODULES-5168))
- Use HTTP instead of HTTPS for RedHat repositories. This is consistent with Puppet's repo packages, and continues to use GPG signing for security.

## [1.4.0] - 2017-06-12

### Summary
This is a feature and bug-fix release

## Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Mac OS X Open Source package upgrades are not yet implemented.

### Features
- AIX 7.2 agents can now be upgraded ([PA-1160](https://tickets.puppetlabs.com/browse/PA-1160))

### Bug fixes
- Fix a race condition when upgrading agents on certain platforms ([MODULES-4732](https://tickets.puppetlabs.com/browse/MODULES-4732))
- Avoid duplicate GPG imports on RPM-based systems ([MODULE-4478](https://tickets.puppetlabs.com/browse/MODULES-4478))
- Silence some redundant notices on Debian-based systems ([MODULES-4171](https://tickets.puppetlabs.com/browse/MODULES-4171))
- Avoid the new to fetch GPG keys from the internet ([MODULES-4521](https://tickets.puppetlabs.com/browse/MODULES-4521))

## [1.3.2] - 2017-02-09

### Summary
This is a bug-fix release

### Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Mac OS X Open Source package upgrades are not yet implemented.

### Bug fixes
- Service management wasn't always applied when intended ([MODULES-3994](https://tickets.puppetlabs.com/browse/MODULES-3994))
- Allow setting MSI installation parameters on Windows ([MODULES-4214](https://tickets.puppetlabs.com/browse/MODULES-4214))
- Ensure all variables are populated to prevent failures when STRICT_VARIABLES='yes'
- Only update server.cfg if not already managed by PE
- Enable the puppet service on Windows if service param includes it ([MODULES-4243](https://tickets.puppetlabs.com/browse/MODULES-4243))
- Add custom fact puppet_agent_appdata, as common_appdata was only defined in PE ([MODULES-4241](https://tickets.puppetlabs.com/browse/MODULES-4241))
- Use getvar to fix facts to work with the strict_variables setting ([MODULES-3710](https://tickets.puppetlabs.com/browse/MODULES-3710))
- Optionally move puppetres.dll on Windows upgrade ([MODULES-4207](https://tickets.puppetlabs.com/browse/MODULES-4207))
- Allow disabling proxy settings for yum repo ([MODULES-4236](https://tickets.puppetlabs.com/browse/MODULES-4236))

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
