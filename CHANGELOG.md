<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v4.16.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/v4.16.0) - 2023-11-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/v4.15.0...v4.16.0)

### Added

- (PA-5065) Add Ubuntu 22.04 (ARM64) to the puppet_agent module [#676](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/676) ([imaqsood](https://github.com/imaqsood))
- (PA-5013) Add Red Hat 9 (ARM64) to the puppet_agent module task [#675](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/675) ([skyamgarp](https://github.com/skyamgarp))
- (PA-5266) Change checksum algorithm to SHA256  [#670](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/670) ([mhashizume](https://github.com/mhashizume))

### Fixed

- (PA-5826) Only read Windows VERSION file during puppet apply [#677](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/677) ([joshcooper](https://github.com/joshcooper))
- (PA-5820) Correct parameter types [#673](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/673) ([mhashizume](https://github.com/mhashizume))
- Match allowed datatypes to yumrepo skip_if_unavailable support [#672](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/672) ([seanmil](https://github.com/seanmil))
- (maint) Update optional parameters [#671](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/671) ([mhashizume](https://github.com/mhashizume))

## [v4.15.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/v4.15.0) - 2023-09-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/v4.14.0...v4.15.0)

### Added

- (PA-5721) Add puppet8 and drop puppet5 support from AIX [#666](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/666) ([joshcooper](https://github.com/joshcooper))
- (maint) PDK Update 2.7.5 [#663](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/663) ([AriaXLi](https://github.com/AriaXLi))
- (PA-5309) Add macOS 13 (ARM) to the puppet_agent module task [#659](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/659) ([skyamgarp](https://github.com/skyamgarp))
- Implement stdlib 9 compatibility [#657](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/657) ([bastelfreak](https://github.com/bastelfreak))
- (PA-5337) PE integration [#654](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/654) ([mhashizume](https://github.com/mhashizume))

## [v4.14.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/v4.14.0) - 2023-04-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/v4.13.0...v4.14.0)

### Added

- (PA-5336) Update tests and tasks for puppet8 [#650](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/650) ([mhashizume](https://github.com/mhashizume))

## [v4.13.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/v4.13.0) - 2023-03-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/v4.12.1...v4.13.0)

### Added

- (PA-5242) Updates install tasks for puppet8 [#642](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/642) ([mhashizume](https://github.com/mhashizume))
- (MODULES-11365) Enable rspec tests on Ruby 3.2 [#641](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/641) ([mhashizume](https://github.com/mhashizume))
- (MODULES-11392) Add Puppet 7 to 8 upgrade test [#639](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/639) ([mhashizume](https://github.com/mhashizume))
- (MODULES-11361) Updates legacy facts [#637](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/637) ([mhashizume](https://github.com/mhashizume))
- (MODULES-11361) Puppet 8 compatibility work [#636](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/636) ([mhashizume](https://github.com/mhashizume))
- (MODULES-11348) Replace lsbdistcodename with os.distro.codename [#634](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/634) ([AriaXLi](https://github.com/AriaXLi))
- run task/plan: Allow noop and environment option [#632](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/632) ([bastelfreak](https://github.com/bastelfreak))
- (maint) replace legacy validate function with datatype [#628](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/628) ([bastelfreak](https://github.com/bastelfreak))
- (MODULES-11346) Update dependency for APT module [#624](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/624) ([MartyEwings](https://github.com/MartyEwings))
- (FM-8983) Add Fedora 36 [#619](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/619) ([joshcooper](https://github.com/joshcooper))
- Support for Linux Mint 21 [#616](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/616) ([luckyraul](https://github.com/luckyraul))
- (FM-8969) Add support for macOS 12 ARM [#615](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/615) ([joshcooper](https://github.com/joshcooper))
- Add support for absolute_source in puppet_agent::install task [#484](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/484) ([scbjans](https://github.com/scbjans))

## [v4.12.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/v4.12.1) - 2022-07-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/v4.12.0...v4.12.1)

### Fixed

- (maint) Unnest module and class names in Ruby tasks [#613](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/613) ([beechtom](https://github.com/beechtom))

## [v4.12.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/v4.12.0) - 2022-07-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/v4.11.0...v4.12.0)

### Added

- (FM-8943) Add Ubuntu 22.04 to puppet_agent module [#610](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/610) ([AriaXLi](https://github.com/AriaXLi))
- (FM-8943) Enable to install from nightly repo for Ubuntu 22.04 for task beaker tests [#609](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/609) ([AriaXLi](https://github.com/AriaXLi))
- (FM-8943) Enable to install from nightly repo for Ubuntu 22.04 for task beaker tests [#608](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/608) ([AriaXLi](https://github.com/AriaXLi))
- (maint) Adds cases for newly-supported OSes [#607](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/607) ([mhashizume](https://github.com/mhashizume))

### Fixed

- (MODULES-11334) Handle TLS 1.2 on older Windows systems [#611](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/611) ([chelnak](https://github.com/chelnak))

## [v4.11.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/v4.11.0) - 2022-05-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/v4.10.0...v4.11.0)

### Added

- (maint) Add macOS 12 [#602](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/602) ([joshcooper](https://github.com/joshcooper))

### Fixed

- (MODULES-11315) Updates AIO auto version logic [#604](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/604) ([mhashizume](https://github.com/mhashizume))
- DOC-5213 install_options for gMSAs [#601](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/601) ([aimurphy](https://github.com/aimurphy))

## [v4.10.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/v4.10.0) - 2022-01-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.9.0...v4.10.0)

### Added

- (maint). Add fact-limit configuration options to list. [#584](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/584) ([Heidistein](https://github.com/Heidistein))
- (MODULES-11192)(MODULES-11168) Add AlmaLinux and Rocky to the puppet-agent module [#583](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/583) ([BobosilaVictor](https://github.com/BobosilaVictor))
- (IAC-1751/IAC-1753) Add Rocky and AlmaLinux support to the install agent task [#582](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/582) ([david22swan](https://github.com/david22swan))
- Allow detection of non-AIO Puppet [#581](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/581) ([smortex](https://github.com/smortex))

### Fixed

- (MODULES-11214) Wrong url generated for darwin 11 [#586](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/586) ([BobosilaVictor](https://github.com/BobosilaVictor))

## [4.9.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.9.0) - 2021-09-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.8.0...4.9.0)

### Other

- (MODULES-11175) Release prep for 4.9.0 [#580](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/580) ([GabrielNagy](https://github.com/GabrielNagy))
- (maint) Update GPG-KEY-puppet [#579](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/579) ([GabrielNagy](https://github.com/GabrielNagy))
- (maint) set `aio_agent_version` for consistency [#578](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/578) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-11123) Avoid loading puppet facts in `install/windows.pp` [#577](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/577) ([luchihoratiu](https://github.com/luchihoratiu))
- (maint) Allow stdlib 8.0.0 [#576](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/576) ([smortex](https://github.com/smortex))
- (MODULES-11060) Add Debian 11 to puppet_agent module [#575](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/575) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (MODULES-11148) Document Windows long paths support [#573](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/573) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-11060) Add Debian 11 testing support to install task [#572](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/572) ([ciprianbadescu](https://github.com/ciprianbadescu))
- (MODULES-11135) puppet_agent : Add task support for Rocky Linux 8.4 Green Obsidian [#571](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/571) ([Guillaume001](https://github.com/Guillaume001))
- (maint) set `BEAKER_BOLT_VERSION` in `task_acceptance` rake task [#570](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/570) ([ciprianbadescu](https://github.com/ciprianbadescu))
- (MODULES-11077) Allow all settings to be managed [#569](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/569) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-11112) Add parameter puppet_agent::proxy [#567](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/567) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-11078) Bump Bolt to 3.x [#566](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/566) ([beechtom](https://github.com/beechtom))
- (MODULES-11113) Allow present and latest as package version [#565](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/565) ([relearnshuffle](https://github.com/relearnshuffle))
- (maint) Update readme for clarification on Windows agent updates [#502](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/502) ([murdok5](https://github.com/murdok5))

## [4.8.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.8.0) - 2021-06-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.7.0...4.8.0)

### Other

- (maint) 4.8.0 release prep [#568](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/568) ([beechtom](https://github.com/beechtom))
- (MODULES-11085) Add Fedora 34 x86_64 to puppet_agent module [#564](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/564) ([BobosilaVictor](https://github.com/BobosilaVictor))
- (maint) increase winrm connection timeout [#563](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/563) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-11074) Fix `facts_diff` task argument parsing on Windows [#561](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/561) ([luchihoratiu](https://github.com/luchihoratiu))
- (PE-31118) add MacOS 11 support [#560](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/560) ([ciprianbadescu](https://github.com/ciprianbadescu))

## [4.7.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.7.0) - 2021-05-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.6.1...4.7.0)

### Other

- (MODULES-11066) Add support for running puppet_agent::install in noop mode [#559](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/559) ([beechtom](https://github.com/beechtom))

## [4.6.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.6.1) - 2021-04-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.6.0...4.6.1)

### Other

- (maint) 4.6.1 release preparation [#558](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/558) ([ciprianbadescu](https://github.com/ciprianbadescu))
- (MODULES-11057) avoid temporary file execution [#557](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/557) ([ciprianbadescu](https://github.com/ciprianbadescu))
- (maint) Update table of contents with new tasks/params [#556](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/556) ([GabrielNagy](https://github.com/GabrielNagy))

## [4.6.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.6.0) - 2021-04-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.5.0...4.6.0)

### Other

- (MODULES-11046) Release prep for 4.6.0 [#555](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/555) ([GabrielNagy](https://github.com/GabrielNagy))
- (maint) lock to ruby 2.5.8 to avoid segmentation fault [#554](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/554) ([gimmyxd](https://github.com/gimmyxd))
- (maint) update tasks documentation [#553](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/553) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-11045) add `exclude` parameter to `facts_diff` task [#552](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/552) ([ciprianbadescu](https://github.com/ciprianbadescu))
- (MODULES-10996) Fix SLES 11 PE upgrades [#551](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/551) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-11048) task to remove local filebucket [#550](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/550) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-10989) Remove puppet5 collection [#549](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/549) ([lucywyman](https://github.com/lucywyman))
- (MODULES-10987) Add Fedora 32 to puppet_agent module [#548](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/548) ([BobosilaVictor](https://github.com/BobosilaVictor))

## [4.5.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.5.0) - 2021-03-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.4.0...4.5.0)

### Other

- (MODULES-10979) Release prep for 4.5.0 [#547](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/547) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10925) Added facts_diff task [#542](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/542) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-10945) Module spring cleaning 2021 [#541](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/541) ([GabrielNagy](https://github.com/GabrielNagy))
- Do not include the .git directory in module packages [#540](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/540) ([smortex](https://github.com/smortex))
- Fix upgrading Puppet on windows [#539](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/539) ([smortex](https://github.com/smortex))
- (maint) Update puppet6 branch name for acceptance tests [#538](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/538) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-9798) Add Timeout Parameter for the Current Puppet Run [#537](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/537) ([phil4business](https://github.com/phil4business))
- (MODULES-10909) Commands retry on network connectivity failures  [#536](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/536) ([adrianiurca](https://github.com/adrianiurca))
- (maint) Add code of conduct [#535](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/535) ([beechtom](https://github.com/beechtom))
- (MODULES-10879) Implement configuration management [#525](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/525) ([reidmv](https://github.com/reidmv))

## [4.4.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.4.0) - 2021-01-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.3.0...4.4.0)

### Other

- (MODULES-10919) Release prep for 4.4.0 [#534](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/534) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10897) Fix GPG key typo [#532](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/532) ([GabrielNagy](https://github.com/GabrielNagy))
- (maint) update apt to 7.4.2 for unit tests [#531](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/531) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-10897) Add new GPG signing key and remove the old one [#530](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/530) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10910) Default to puppet 7 for PE 2021.0 [#529](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/529) ([genebean](https://github.com/genebean))

## [4.3.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.3.0) - 2020-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.2.0...4.3.0)

### Other

- (MODULES-10890) Release prep for 4.3.0 [#528](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/528) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10878) Use correct packages when upgrading AIX [#527](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/527) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10873) Add support for puppet7 collection [#524](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/524) ([joshcooper](https://github.com/joshcooper))
- (maint) Allow git to use long paths in GitHub Actions [#523](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/523) ([luchihoratiu](https://github.com/luchihoratiu))
- (maint) use rspec-expectations < 3.10 [#522](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/522) ([gimmyxd](https://github.com/gimmyxd))

## [4.2.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.2.0) - 2020-10-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.1.1...4.2.0)

### Other

- (MODULES-10840) Release prep for 4.2.0 [#521](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/521) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10851) Fix Windows nightly prerequisites check [#520](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/520) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10850) determine PSScriptRoot if it does not exist [#519](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/519) ([mihaibuzgau](https://github.com/mihaibuzgau))
- (MODULES-10815) Add Slack notification job [#518](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/518) ([luchihoratiu](https://github.com/luchihoratiu))
- (MODULES-10818) update README with msi_move_locked_files updates/details [#517](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/517) ([ciprianbadescu](https://github.com/ciprianbadescu))
- (MODULES-10822) Rework acceptance tests [#516](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/516) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10818) ignore `msi_move_locked_files` on newer puppet versions [#515](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/515) ([ciprianbadescu](https://github.com/ciprianbadescu))
- (maint) Fix commits rake task and speed up unit tests run on Windows GitHub Actions [#514](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/514) ([luchihoratiu](https://github.com/luchihoratiu))
- (maint) Bump puppet agent version used in acceptance tests and fix them [#513](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/513) ([luchihoratiu](https://github.com/luchihoratiu))
- (MODULES-10813) Mismatched versions stops install [#512](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/512) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (MODULES-10799) Ensure upgradability from puppet 6 to 7 when remote filebuckets are enabled [#511](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/511) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10780) PA 6 to PA 7 upgrade tests [#510](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/510) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (MODULES-10806) Add Github Actions workflows [#509](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/509) ([luchihoratiu](https://github.com/luchihoratiu))

## [4.1.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.1.1) - 2020-08-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.1.0...4.1.1)

### Other

- (maint) Bump version to 4.1.1 [#508](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/508) ([lucywyman](https://github.com/lucywyman))
- (maint) Add PDK as a dependency [#507](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/507) ([lucywyman](https://github.com/lucywyman))

## [4.1.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.1.0) - 2020-08-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/4.0.0...4.1.0)

### Other

- (maint) Release prep for 4.1.0 [#506](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/506) ([lucywyman](https://github.com/lucywyman))
- (MODULES-10768) Add task and plan for running Puppet agent [#503](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/503) ([beechtom](https://github.com/beechtom))
- (MODULES-10739) add task support for puppet7-nightly [#501](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/501) ([gimmyxd](https://github.com/gimmyxd))
- Support for Linux Mint 20, LDME 4 [#500](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/500) ([luckyraul](https://github.com/luckyraul))
- (MODULES-10713) Fix agent upgrade on Solaris 11 [#499](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/499) ([GabrielNagy](https://github.com/GabrielNagy))
- (maint) update CODEOWNERS [#490](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/490) ([gimmyxd](https://github.com/gimmyxd))

## [4.0.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/4.0.0) - 2020-06-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/3.2.0...4.0.0)

### Other

- (MODULES-10695) Release prep for 4.0.0 [#498](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/498) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10666) Stop agent run after an upgrade [#496](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/496) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10673) Update dependency for puppetlabs-facts [#495](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/495) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (MODULES-10653) Failed to upgrade agent using puppet task [#494](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/494) ([luchihoratiu](https://github.com/luchihoratiu))
- (maint) bump agent version in tests [#493](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/493) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-10655) Fix up/downgrade of agent to specified version [#488](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/488) ([hajee](https://github.com/hajee))

## [3.2.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/3.2.0) - 2020-05-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/3.1.0...3.2.0)

### Other

- (MODULES-10668) Release prep for 3.2.0 [#492](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/492) ([beechtom](https://github.com/beechtom))
- (MODULE-10662) Add Ubuntu 20.04 to puppet_agent::install task [#491](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/491) ([beechtom](https://github.com/beechtom))
- (MODULES-10651) Add ubuntu 20.04 support [#489](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/489) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-10661) Add OS X 10.15 support [#487](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/487) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10633) Don't use the install task for upgrades [#486](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/486) ([npwalker](https://github.com/npwalker))
- (MODULES-10636) Fixed mcollective being included as a default service to manage, in clientversion >= 6.0.0 [#485](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/485) ([LinkMJB](https://github.com/LinkMJB))

## [3.1.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/3.1.0) - 2020-04-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/3.0.2...3.1.0)

### Other

- (maint) Fix mco acceptance testing [#482](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/482) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10607) Release prep for 3.1.0 [#481](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/481) ([GabrielNagy](https://github.com/GabrielNagy))
- (maint) Fix task acceptance for osx 10.14 & 10.15 [#480](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/480) ([GabrielNagy](https://github.com/GabrielNagy))
- (MODULES-10606) fix windowsfips upgrades [#479](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/479) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-10594) Remove pidlock if service states cannot be restored [#478](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/478) ([mihaibuzgau](https://github.com/mihaibuzgau))
- (packaging) Update inifile dependency to allow all 4.x versions [#477](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/477) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-10110) Handle Amazon Linux 2 as el-7 [#476](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/476) ([mihaibuzgau](https://github.com/mihaibuzgau))
- Check that user is root only if installation is required [#475](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/475) ([faucct](https://github.com/faucct))
- (MODULES-10589) Exit early when puppet.list config file has been modified [#472](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/472) ([beechtom](https://github.com/beechtom))
- (maint) Allow install task to downlad macos 10.15 [#471](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/471) ([donoghuc](https://github.com/donoghuc))

## [3.0.2](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/3.0.2) - 2020-02-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/3.0.1...3.0.2)

### Other

- (maint) Prep 3.0.2 [#470](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/470) ([beechtom](https://github.com/beechtom))
- (maint) Remove config field from bolt_plugin.json [#469](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/469) ([beechtom](https://github.com/beechtom))

## [3.0.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/3.0.1) - 2020-01-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/3.0.0...3.0.1)

### Other

- (maint) Prepare 3.0.1 release [#468](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/468) ([beechtom](https://github.com/beechtom))
- (MODULES-10514) Remove use of version_powershell task in install task [#467](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/467) ([beechtom](https://github.com/beechtom))

## [3.0.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/3.0.0) - 2020-01-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.2.3...3.0.0)

### Other

- (maint) Prepare 3.0.0 release [#466](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/466) ([beechtom](https://github.com/beechtom))
- (MODULES-10477) Update task documentation [#465](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/465) ([beechtom](https://github.com/beechtom))
- (maint) fix Solaris tests [#464](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/464) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-10454) Install 'latest' only when no agent is present [#463](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/463) ([beechtom](https://github.com/beechtom))

## [2.2.3](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.2.3) - 2019-12-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.2.2...2.2.3)

### Other

- Revert "(MODULES-10308) Allow downgrades when using apt" [#459](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/459) ([gimmyxd](https://github.com/gimmyxd))
- (maint) Prepare 2.2.3 release [#458](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/458) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (MODULES-10308) Allow downgrades when using apt [#457](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/457) ([beechtom](https://github.com/beechtom))
- (MODULES-10238) Add Fedora 31 to puppet_agent module [#456](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/456) ([luchihoratiu](https://github.com/luchihoratiu))
- (MODULES-10067) enhance perl download check [#455](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/455) ([ciprianbadescu](https://github.com/ciprianbadescu))
- (maint) Merge release to master [#453](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/453) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (MODULES-10055) fix linter-errors in puppetlabs/puppet_agent [#451](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/451) ([atarax](https://github.com/atarax))
- (maint) Updated metadata.json with support for Windows Server 2019 [#449](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/449) ([sootysec](https://github.com/sootysec))
- (MODULES-27043) Puppet agent upgrade for windows FIPS [#448](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/448) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (MODULES-10052) parameterize WaitForExit timeout in puppet_agent install script [#436](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/436) ([lucaswyoung](https://github.com/lucaswyoung))

## [2.2.2](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.2.2) - 2019-11-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.2.1...2.2.2)

### Other

- (maint) Prepare 2.2.2 release [#452](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/452) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (MODULES-10038) nightly build download location fix [#450](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/450) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (maint) Pin puppet-lint to 2.3.6 [#447](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/447) ([Dorin-Pleava](https://github.com/Dorin-Pleava))

## [2.2.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.2.1) - 2019-10-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.2.0...2.2.1)

### Other

- (maint) Release prep for 2.2.1 [#446](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/446) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- (maint) Make the puppet_agent task available as a plugin [#445](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/445) ([adreyer](https://github.com/adreyer))
- (MODULES-9981) Add Amazon Linux 2 support [#444](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/444) ([alexharv074](https://github.com/alexharv074))
- (maint) fix failing tests due to rspec changes [#443](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/443) ([gimmyxd](https://github.com/gimmyxd))
- (maint) Add task to check commit messages [#442](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/442) ([gimmyxd](https://github.com/gimmyxd))
- (maint) Add bolt team as codeowners for task content [#440](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/440) ([donoghuc](https://github.com/donoghuc))
- (maint) Update bash implementation metadata to require facts implemen… [#439](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/439) ([donoghuc](https://github.com/donoghuc))
- (GH-1204) Add option to stop the puppet agent service after install [#438](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/438) ([lucywyman](https://github.com/lucywyman))
- (MODULES-9846) fix install using cached catalog [#437](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/437) ([ciprianbadescu](https://github.com/ciprianbadescu))
- Linux Mint Support [#434](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/434) ([luckyraul](https://github.com/luckyraul))
- (MODULES-9698) Update facts module used for testing install task [#433](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/433) ([donoghuc](https://github.com/donoghuc))
- (PE-25814) Add Debian 10 Buster amd64 to puppet agent module [#431](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/431) ([GeorgeMrejea](https://github.com/GeorgeMrejea))
- (MODULES-9497) install_puppet.ps1 stale .pid file [#430](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/430) ([Dorin-Pleava](https://github.com/Dorin-Pleava))
- Update metadata versions [#428](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/428) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [2.2.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.2.0) - 2019-08-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.1.2...2.2.0)

### Other

- (maint) Release prep for 2.2.0 [#429](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/429) ([loopinu](https://github.com/loopinu))
- (MODULES-7760) relax agent versions on redhat [#426](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/426) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-9575) fix solaris 10 tests [#425](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/425) ([gimmyxd](https://github.com/gimmyxd))
- (PE-26530) Update spec and task acceptance tests with Fedora 30 [#424](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/424) ([GabrielNagy](https://github.com/GabrielNagy))
- (PE-26530) Update metadata to add Fedora 30 [#423](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/423) ([GabrielNagy](https://github.com/GabrielNagy))
- (maint) Add CODEOWNERS [#422](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/422) ([mihaibuzgau](https://github.com/mihaibuzgau))
- (MODULES-9444) Migrate puppet_agent module to Beaker 4 [#421](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/421) ([oanatmaria](https://github.com/oanatmaria))
- (maint) Allow stdlib 6.x [#418](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/418) ([rnelson0](https://github.com/rnelson0))
- (MODULES-9173) Mcollective service restarting when PA upgrade is done. [#417](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/417) ([loopinu](https://github.com/loopinu))
- (MODULES-8923) puppet_agent : could autodetect package_version based … [#416](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/416) ([oanatmaria](https://github.com/oanatmaria))
- (maint) Use newer puppet versions for class_spec [#413](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/413) ([oanatmaria](https://github.com/oanatmaria))
- (maint) Fix tests on SLES [#412](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/412) ([oanatmaria](https://github.com/oanatmaria))
- (maint) Fix task acceptance tests for fedora 29 [#411](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/411) ([donoghuc](https://github.com/donoghuc))
- (MODULES-8923) autodetect package_version based upon the master [#401](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/401) ([tkishel](https://github.com/tkishel))
- (docs) Revise macOS limitations note. [#398](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/398) ([gguillotte](https://github.com/gguillotte))
- Readme naming consistency [#396](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/396) ([hpcprofessional](https://github.com/hpcprofessional))
- (MODULES-8665) Add missing puppetlabs-facts dependency [#388](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/388) ([Sharpie](https://github.com/Sharpie))

## [2.1.2](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.1.2) - 2019-05-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.1.1...2.1.2)

### Other

- (packaging) Update changelog/metadata for 2.1.2 [#410](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/410) ([mihaibuzgau](https://github.com/mihaibuzgau))
- (maint) update apt url [#409](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/409) ([mihaibuzgau](https://github.com/mihaibuzgau))
- (maint) Puppet agent on Windows has manual startup, debian spec fix [#408](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/408) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (maint) use PC1 as default [#407](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/407) ([mihaibuzgau](https://github.com/mihaibuzgau))
- (maint) Changes to windows public release package links [#405](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/405) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (packaging) Update changelog/metadata for 2.1.2 [#404](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/404) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (docs) Fix bad aix_source example. [#403](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/403) ([gguillotte](https://github.com/gguillotte))
- (RE-12326) Changes to public release package links [#402](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/402) ([eimlav](https://github.com/eimlav))
- Fix Yum URL path for RedHat systems still using the PC1 collection [#400](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/400) ([coreone](https://github.com/coreone))

## [2.1.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.1.1) - 2019-03-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.1.0...2.1.1)

### Other

- (MODULES-8821) Update win install to use production environment [#397](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/397) ([mcdonaldseanp](https://github.com/mcdonaldseanp))

## [2.1.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.1.0) - 2019-03-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.0.1...2.1.0)

### Other

- (MODULES-6604) Add new source parameters [#395](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/395) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (MODULES-8720) Update source calculation to prefer source user param [#394](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/394) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (MODULES-8554) Add error reporting for background upgrades [#393](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/393) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- Fix unnecessary changes in load balanced envs due to pkg source [#392](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/392) ([ragnarkon](https://github.com/ragnarkon))
-  (PA-2385) Update service management to run always for windows [#391](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/391) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (FM-7628) Update install_puppet.ps1 to catch hanging pxp-agent processes [#390](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/390) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (BOLT-1057) Pass required args to run_task [#389](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/389) ([nicklewis](https://github.com/nicklewis))
- (MODULES-4780) README improvements [#387](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/387) ([ScottGarman](https://github.com/ScottGarman))
- (MODULES-8583) Improve rpm importing of the puppet GPG key [#386](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/386) ([ScottGarman](https://github.com/ScottGarman))
- (MODULES-8599) Refactor sources and enable Darwin FOSS installs [#385](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/385) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (MODULES-4986) Remove deprecated puppet 4 settings on upgrading to puppet 5+ [#384](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/384) ([caseywilliams](https://github.com/caseywilliams))
- (MODULES-8598) Enable SLES upgrades outside of Puppet Enterprise [#383](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/383) ([caseywilliams](https://github.com/caseywilliams))
- (FM-7732) Download puppet-agent packages over https [#382](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/382) ([donoghuc](https://github.com/donoghuc))
- (MODULES-5535) Update test matrix to work with MacOS/Solaris/Windows [#381](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/381) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (MODULES-8320) Remove old platforms [#380](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/380) ([ekinanp](https://github.com/ekinanp))
- (PE-25542) add RHEL8 to puppet agent module [#379](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/379) ([loopinu](https://github.com/loopinu))
- (MODULES-4730) Do not pass the agent environment during MSI installs [#378](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/378) ([ScottGarman](https://github.com/ScottGarman))
- (maint) Update minimum acceptance beaker-puppet version [#377](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/377) ([caseywilliams](https://github.com/caseywilliams))
- (MODULES-8348) Refactor the acceptance test scaffold [#376](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/376) ([ekinanp](https://github.com/ekinanp))
- (MODULES-8406) fix the broken unless check for inherited permissions [#375](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/375) ([speedofdark](https://github.com/speedofdark))
- (MODULES-8523) Remove legacy Puppet 3 code [#374](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/374) ([ekinanp](https://github.com/ekinanp))
- (MODULES-8319) Update service to exclude MCO for puppet > 6 [#373](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/373) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (MODULES-7840) Update docs with better parameter descriptions [#372](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/372) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (MODULES-8348) Acceptance scaffold with beaker-puppet [#371](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/371) ([caseywilliams](https://github.com/caseywilliams))
- (MODULES-8432) refresh PA repo if the version is not in the local cache [#366](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/366) ([mihaibuzgau](https://github.com/mihaibuzgau))
- (PA-2282) Add developer documentation [#357](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/357) ([smcclellan](https://github.com/smcclellan))
- (PE-25223) Add OSX 10.14 to the puppet_agent_module [#355](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/355) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (PA-2282) Add Docker workflow for iterative development [#352](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/352) ([smcclellan](https://github.com/smcclellan))

## [2.0.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.0.1) - 2019-01-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/2.0.0...2.0.1)

### Other

- (packaging) Changelog/Metadata updates for 2.0.1 [#370](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/370) ([mcdonaldseanp](https://github.com/mcdonaldseanp))

## [2.0.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/2.0.0) - 2019-01-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.7.0...2.0.0)

### Added

- (MODULES-8446) Improve error messages for PE-only platforms [#359](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/359) ([caseywilliams](https://github.com/caseywilliams))

### Fixed

- (MODULES-8443) Don't restart mco for FOSS puppet6 upgrades [#361](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/361) ([caseywilliams](https://github.com/caseywilliams))

### Other

- (maint) make pid file name consistent on windows [#369](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/369) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (maint) Fix some errors in windows upgrade script [#368](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/368) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (MODULES-8398) Update windows upgrade script to recover services on fail [#367](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/367) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (FM-7656) Use the HTTPS endpoint to fetch puppet-agent MSI files. [#365](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/365) ([speedofdark](https://github.com/speedofdark))
- (maint) Update task_acceptance tests to use updated dependencies [#363](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/363) ([donoghuc](https://github.com/donoghuc))
- (MODULES-8431) Update windows installation to use powershell [#362](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/362) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
- (MODULES-8317) Update module dependencies [#356](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/356) ([caseywilliams](https://github.com/caseywilliams))
- (MODULES-8393) Add task required metadata, hide extra implementations [#353](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/353) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-25228) Add Fedora 29 (x86_64) to the puppet_agent module [#351](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/351) ([gimmyxd](https://github.com/gimmyxd))
- (MODULES-8318) Remove spec tests for puppet < 4 [#350](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/350) ([caseywilliams](https://github.com/caseywilliams))
- (MODULES-8318) Update rspec-puppet, add yumrepo_core fixtures for puppet 6 [#348](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/348) ([caseywilliams](https://github.com/caseywilliams))
- (feature) add scientific support to install task [#347](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/347) ([tphoney](https://github.com/tphoney))
- Merge 1.x to master [#346](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/346) ([MikaelSmith](https://github.com/MikaelSmith))
- Add support for Oracle Linux Server [#345](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/345) ([aadamovich](https://github.com/aadamovich))
- (MODULES-8198) Use beaker ~> 3 [#344](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/344) ([caseywilliams](https://github.com/caseywilliams))
- (maint) Use legacy dependencies repo for activemq [#343](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/343) ([geoffnichols](https://github.com/geoffnichols))
- (maint) Use legacy dependencies repo for activemq [#342](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/342) ([geoffnichols](https://github.com/geoffnichols))
- (PE-25425) Add SLES 15 support [#340](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/340) ([mcdonaldseanp](https://github.com/mcdonaldseanp))
-  (MODULES-7760) Remove dist_tag in install.pp for RHEL platforms [#335](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/335) ([ekinanp](https://github.com/ekinanp))
- (MODULES-8086) Puppet 5 and 6: wrong urls for windows msi [#334](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/334) ([fculpo](https://github.com/fculpo))
- (MODULES-7791) Remove deprecated source_permissions [#332](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/332) ([caseywilliams](https://github.com/caseywilliams))
- (BOLT-915) Use facts module to query for target platform [#331](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/331) ([donoghuc](https://github.com/donoghuc))
-  (BOLT-878) Fail fast when run as non-root [#330](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/330) ([adreyer](https://github.com/adreyer))
- (maint) Explicitly upgrade when version is not specified for yum [#328](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/328) ([donoghuc](https://github.com/donoghuc))
- description of the task said puppet 5 [#326](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/326) ([yasminrajabi](https://github.com/yasminrajabi))
- (BOLT-834) Allow upgrade from puppet5 to puppet6 for install task [#325](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/325) ([donoghuc](https://github.com/donoghuc))
- (PE-24213) Add support for SLES 15 [#324](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/324) ([ScottGarman](https://github.com/ScottGarman))

## [1.7.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.7.0) - 2018-09-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.6.2...1.7.0)

### Other

- (packaging) Prepare for 1.7.0 release [#322](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/322) ([branan](https://github.com/branan))
- (MODULES-7758) Properly handle distro tag for Fedora platforms [#321](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/321) ([ekinanp](https://github.com/ekinanp))
- (MODULES-7698) Fix OSX agent upgrades [#320](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/320) ([ekinanp](https://github.com/ekinanp))
- (maint) Update to Bolt 0.21.8 [#319](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/319) ([donoghuc](https://github.com/donoghuc))
- (MOD-7655) SLES support for install_agent tasks [#318](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/318) ([donoghuc](https://github.com/donoghuc))
- (maint) Bump beaker-task_helper version [#316](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/316) ([donoghuc](https://github.com/donoghuc))
- (maint) Revert to beaker 3.x.x [#315](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/315) ([donoghuc](https://github.com/donoghuc))
- (maint) Require beaker-puppet for beaker 4.0 update [#314](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/314) ([donoghuc](https://github.com/donoghuc))
- (BOLT-742) Add support for collections to install task [#312](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/312) ([MikaelSmith](https://github.com/MikaelSmith))
- (BOLT-229) update to use new test helpers in BoltSpec and task_helpers [#311](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/311) ([adreyer](https://github.com/adreyer))
- (maint) Restore correct dependencies with Beaker 4 [#310](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/310) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-7580) Fix PowerShell task for puppet version on 32bit [#309](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/309) ([glennsarti](https://github.com/glennsarti))
- (BOLT-703) Install puppet agent on windows [#308](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/308) ([donoghuc](https://github.com/donoghuc))
- (BOLT-702) Install puppet agent on osx [#307](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/307) ([donoghuc](https://github.com/donoghuc))
- (BOLT-641) Add version task [#306](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/306) ([MikaelSmith](https://github.com/MikaelSmith))
- (PDK-1036) Unpin rspec-puppet from 2.6.9 [#305](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/305) ([rodjek](https://github.com/rodjek))
- Merge 1.6.2 release back to 1.x [#304](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/304) ([branan](https://github.com/branan))
- (BOLT-701) Add task to install agent package on linux [#302](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/302) ([adreyer](https://github.com/adreyer))
- (CPR-409) Ensure PL projects can handle fedora without the f prefix [#232](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/232) ([mwaggett](https://github.com/mwaggett))

## [1.6.2](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.6.2) - 2018-07-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.6.1...1.6.2)

### Other

- (MODULES-7535) Prep for 1.6.2 release [#303](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/303) ([branan](https://github.com/branan))
- (MODULES-7480) Set default collection in params.pp using PE version [#301](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/301) ([ekinanp](https://github.com/ekinanp))
- (maint) Mergeback 1.x into master [#300](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/300) ([glennsarti](https://github.com/glennsarti))
- (MAINT) Mergeback Release of 1.6.1 [#299](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/299) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [1.6.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.6.1) - 2018-06-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.6.0...1.6.1)

### Other

- (MODULES-7167) Prepare module for 1.6.1 release [#298](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/298) ([glennsarti](https://github.com/glennsarti))
- (MODULES-5230) Use legacy fact variables [#297](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/297) ([glennsarti](https://github.com/glennsarti))
- (MODULES-4424) Add skip_if_unavailable to yumrepo resource [#296](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/296) ([speedofdark](https://github.com/speedofdark))
- (MODULES-7329) Fix update failure for FIPS [#295](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/295) ([smcclellan](https://github.com/smcclellan))
- (PE-23722) Update metadata to add Ubuntu 18.04 [#294](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/294) ([caseywilliams](https://github.com/caseywilliams))
- [MODULES-4195] Install AIX 6.1 RPMs on all AIX versions for puppet6 [#292](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/292) ([caseywilliams](https://github.com/caseywilliams))
- (MODULES-7167) Prepare for 1.6.1 release [#290](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/290) ([glennsarti](https://github.com/glennsarti))
- (MODULES-6915) Remove check for PE when calculating whether to upgrade [#289](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/289) ([smcclellan](https://github.com/smcclellan))
- (MODULES-4271) Update Windows OSes in metadata [#288](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/288) ([glennsarti](https://github.com/glennsarti))
- Merge 1.x into master [#287](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/287) ([branan](https://github.com/branan))
- (MODULES-5230) Do not manage PA version on PE infra nodes [#286](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/286) ([npwalker](https://github.com/npwalker))
- (MODULES-6708) fix tests for windows agent to agent upgrades [#285](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/285) ([speedofdark](https://github.com/speedofdark))
- (maint) Update Stdlib dependency [#284](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/284) ([glennsarti](https://github.com/glennsarti))
- (MODULES-6717) Mergeback 1.x to Master and remove Puppet 3.8 [#283](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/283) ([glennsarti](https://github.com/glennsarti))

## [1.6.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.6.0) - 2018-03-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.5.0...1.6.0)

### Other

- (MODULES-6832) Prepare for v1.6.0 release [#282](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/282) ([glennsarti](https://github.com/glennsarti))
- (MODULES-6717) Configure 1.x branch for last 3.8 compatible release [#281](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/281) ([glennsarti](https://github.com/glennsarti))
- (PA-1887) Fix osfamily::darwin OSX version regex [#278](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/278) ([ekinanp](https://github.com/ekinanp))
- (MODULES-6688) Use travis for CI testing, instead of Jenkins [#276](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/276) ([glennsarti](https://github.com/glennsarti))
- (MODULES-6686) Fix puppet_agent_spec tests for Windows [#275](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/275) ([glennsarti](https://github.com/glennsarti))
-  (PE-23563) Stop MCO and Puppet prior to MSI install  [#274](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/274) ([glennsarti](https://github.com/glennsarti))
- (PE-23558) Add RHEL 7 AARCH64 [#273](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/273) ([ekinanp](https://github.com/ekinanp))
- (PE-23542) Add OSX 10.13 [#272](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/272) ([ekinanp](https://github.com/ekinanp))
- (maint) modulesync cd884db Remove AppVeyor OpenSSL update on Ruby 2.4 [#270](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/270) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (maint) - modulesync 384f4c1 [#269](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/269) ([tphoney](https://github.com/tphoney))
- ensure compatibility to puppetlabs/apt > 3.0.0 [#268](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/268) ([juckerf](https://github.com/juckerf))
- Merge 1.5.0 release back into master [#267](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/267) ([branan](https://github.com/branan))

## [1.5.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.5.0) - 2017-11-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.4.1...1.5.0)

### Other

- (maint) Fix release date for 1.5.0 release [#266](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/266) ([branan](https://github.com/branan))
- (MODULES-6095) Review docs for release. [#265](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/265) ([gguillotte](https://github.com/gguillotte))
- (maint) Disable PuppetLint i18n check [#264](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/264) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) - modulesync 1d81b6a [#263](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/263) ([pmcmaw](https://github.com/pmcmaw))
- (MODULES-6041) Prepare for 1.5.0 release [#262](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/262) ([branan](https://github.com/branan))
- (MODULES-5979) Use rpm upgrade for puppet-agent upgrades [#261](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/261) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-22810) Removed _client_cert_verification [#260](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/260) ([barleyj-puppet](https://github.com/barleyj-puppet))
- (MODULES-5953) Adds ability to set stringify_facts [#259](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/259) ([petems](https://github.com/petems))
- (maint) Test on Trusty for Travis [#257](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/257) ([glennsarti](https://github.com/glennsarti))
- (maint) Add Travis badge to README [#256](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/256) ([petems](https://github.com/petems))
- (MODULES-5944) Fixes failure for stringify_facts [#255](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/255) ([petems](https://github.com/petems))
- (MODULES-5942) Always use upgrade script on Solaris 10 [#254](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/254) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-5622) Add REINSTALLMODE for win install [#253](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/253) ([jcoconnor](https://github.com/jcoconnor))
- Make management of /etc/pki directory optional [#252](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/252) ([danpatdav](https://github.com/danpatdav))
- (PE-22505) Add ppc64le to the list of valid architecture regexes [#251](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/251) ([ekinanp](https://github.com/ekinanp))
- fix dist tag on Amazon Linux (avoids issue when ensuring package version) [#249](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/249) ([wyardley](https://github.com/wyardley))
- (maint) modulesync 892c4cf [#248](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/248) ([HAIL9000](https://github.com/HAIL9000))
- (MODULES-5633) Add support for Puppet 5 on Redhat osfamily [#247](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/247) ([branan](https://github.com/branan))
- (maint) Add pid file to Solaris upgrade [#246](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/246) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fix Travis CI [#244](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/244) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) modulesync 915cde70e20 [#243](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/243) ([glennsarti](https://github.com/glennsarti))
- (MODULES-3787) Fix upgrades on Solaris 10 when initiated from service [#242](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/242) ([MikaelSmith](https://github.com/MikaelSmith))

## [1.4.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.4.1) - 2017-07-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.4.0...1.4.1)

### Other

- (maint) bump inifile dependency [#240](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/240) ([eputnam](https://github.com/eputnam))
- (maint) Use http for RedHat repos [#239](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/239) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-5235) Prepare 1.4.1 release [#238](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/238) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Include spec_helper so parallel specs succeed [#237](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/237) ([MikaelSmith](https://github.com/MikaelSmith))
- puppet_stringify_facts fixes for Puppet 4 [#236](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/236) ([lukebigum](https://github.com/lukebigum))
- (MODULES-4547) setting the package provider to sun for Solaris 10 hosts in case the … [#220](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/220) ([sirinek](https://github.com/sirinek))

## [1.4.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.4.0) - 2017-06-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.3.2...1.4.0)

### Other

- (packaging) Prepare for 1.4.0 release [#235](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/235) ([branan](https://github.com/branan))
- (PA-1160) Add support for AIX 7.2 [#234](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/234) ([branan](https://github.com/branan))
- (maint) Pin fixtures to puppetlabs-apt 2.3.0 [#227](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/227) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-4732) Bump transition dependency to 0.1.1 [#226](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/226) ([natemccurdy](https://github.com/natemccurdy))
- [msync] 786266 Implement puppet-module-gems, a45803 Remove metadata.json from locales config [#223](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/223) ([wilson208](https://github.com/wilson208))
- (MODULES-4521) Update suse GPG file location [#218](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/218) ([johnduarte](https://github.com/johnduarte))
- (Issue #132) Change Notify resource to Exec [#217](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/217) ([jghward](https://github.com/jghward))
- (MODULES-4521) Use local copy of Puppet GPG keys [#216](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/216) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-4478) Fix `tr` invocation for some versions of RedHat [#215](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/215) ([MikaelSmith](https://github.com/MikaelSmith))

## [1.3.2](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.3.2) - 2017-02-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.3.1...1.3.2)

### Added

- (maint)(MODULES-3710) Apply module sync configs to puppet_agent module and fix strict variable tests [#207](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/207) ([glennsarti](https://github.com/glennsarti))

### Other

- (MODULES-4241) Fix Windows acceptance [#212](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/212) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) remove Moses as a maintainer [#210](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/210) ([MosesMendoza](https://github.com/MosesMendoza))
- (MODULES-3994) Manage services on Puppet 4 [#209](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/209) ([MikaelSmith](https://github.com/MikaelSmith))
- (packaging) Prepare for 1.3.2 release [#208](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/208) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-4214) Add additional installation parameters during upgrade [#204](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/204) ([glennsarti](https://github.com/glennsarti))
- Ensure all variables are populated [#203](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/203) ([rnelson0](https://github.com/rnelson0))
- (maint) Only update server.cfg if not already managed [#202](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/202) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-4241) Enable Windows acceptance testing [#201](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/201) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-4241) Add custom fact puppet_agent_appdata [#200](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/200) ([MikaelSmith](https://github.com/MikaelSmith))
- Use getvar for facts that doesn't exist in my environment [#199](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/199) ([TomaszUrugOlszewski](https://github.com/TomaszUrugOlszewski))
- (MODULES-4207) Optionally move puppetres.dll on Windows upgrade [#198](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/198) ([glennsarti](https://github.com/glennsarti))
- (FM-5839) Ensure server is set for all actions [#194](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/194) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-4236) Disable proxy for yum repo as it will not pass through to Puppet Server and will not hand over the certs. [#153](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/153) ([cyberious](https://github.com/cyberious))

## [1.3.1](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.3.1) - 2016-11-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.3.0...1.3.1)

### Other

- (maint) Bump release data in CHANGELOG [#191](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/191) ([branan](https://github.com/branan))
- (maint) Only use sha256lite when we are already on AIO [#190](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/190) ([branan](https://github.com/branan))
- (FM-5815) Prep for 1.3.1 release [#189](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/189) ([branan](https://github.com/branan))
- (maint) Fix config for Jenkins [#188](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/188) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-4092) Install solaris 10 package per-zone [#187](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/187) ([branan](https://github.com/branan))
- (MODULES-4030) Always prepare package [#185](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/185) ([highb](https://github.com/highb))
- (maint) Add internal_list key to MAINTAINERS [#184](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/184) ([theshanx](https://github.com/theshanx))
- (maint) convert install_puppet.bat to CRLF [#183](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/183) ([ferventcoder](https://github.com/ferventcoder))

## [1.3.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.3.0) - 2016-10-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.2.0...1.3.0)

### Other

- (FM-5320) Docs edits [#181](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/181) ([jtappa](https://github.com/jtappa))
- (maint) Update supported platforms based on available packages [#180](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/180) ([MikaelSmith](https://github.com/MikaelSmith))
- (FM-5317) Prep for 1.3.0 release [#179](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/179) ([glennsarti](https://github.com/glennsarti))
- (Modules-3970) Update puppet windows agent download url schema [#178](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/178) ([spacepants](https://github.com/spacepants))
- (MODULES-3962) Pin stdlib module to 4.12 [#177](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/177) ([Magisus](https://github.com/Magisus))
- (maint) Add Moses and Glenn as maintainers [#175](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/175) ([MosesMendoza](https://github.com/MosesMendoza))
- (maint) Add MAINTAINERS file [#174](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/174) ([MosesMendoza](https://github.com/MosesMendoza))
- (MODULES-3872) add acceptance test for manage_repo param [#173](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/173) ([MosesMendoza](https://github.com/MosesMendoza))
- (MODULES-3912) Remove POWER8 hardware constraint from README [#172](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/172) ([geoffnichols](https://github.com/geoffnichols))
- (MODULES-3953) avoid applying settings catalog in acceptance [#171](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/171) ([MosesMendoza](https://github.com/MosesMendoza))
- (MODULES-3951) Add explicit check for stringify_facts [#170](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/170) ([binford2k](https://github.com/binford2k))
- (maint) add task for generating nodesets for testing [#169](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/169) ([MosesMendoza](https://github.com/MosesMendoza))
- (maint) Use the forge for test fixtures [#167](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/167) ([glennsarti](https://github.com/glennsarti))
- (doc) Update documentation for Windows [#165](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/165) ([glennsarti](https://github.com/glennsarti))
- (maint) correct spelling error in README.markdown [#164](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/164) ([MosesMendoza](https://github.com/MosesMendoza))
- (PE-17663) update logic for solaris 11 package name [#163](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/163) ([johnduarte](https://github.com/johnduarte))
- (FM-4989) Remove POWER version constraint for AIX [#162](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/162) ([geoffnichols](https://github.com/geoffnichols))
- (MODULES-3896) Avoid unknown variables [#160](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/160) ([MikaelSmith](https://github.com/MikaelSmith))
- (docs) Note unchanged config options [#159](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/159) ([MikaelSmith](https://github.com/MikaelSmith))
- updated unless condition on Suse/Redhat GPG key imports to ensure downcasing [#158](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/158) ([exodusftw](https://github.com/exodusftw))
- (PE-17508) Fix puppet-agent suffix on fedora [#154](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/154) ([johnduarte](https://github.com/johnduarte))
- (MODULES-3872) Updated to provide the ability to disable configuration of PE/FOSS repositories [#152](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/152) ([exodusftw](https://github.com/exodusftw))
- (RE-7976) Update to use the new GPG key [#151](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/151) ([underscorgan](https://github.com/underscorgan))
- (maint) Fix linting [#148](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/148) ([MikaelSmith](https://github.com/MikaelSmith))
- Set perms for Windows package differently than for Linux [#147](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/147) ([esalberg](https://github.com/esalberg))
- (maint) Fix CI, where host['ip'] is nil [#144](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/144) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fixes typo in Rakefile [#143](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/143) ([bmjen](https://github.com/bmjen))
- (PE-17012) Do not manage puppet symlink [#139](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/139) ([highb](https://github.com/highb))
- (maint) Add puppet-lint workarounds for CI, use valid certnames [#138](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/138) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-3657) Fix waiting on Windows during upgrade [#137](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/137) ([glennsarti](https://github.com/glennsarti))
- (MODULES-3434) Wait 120 seconds for Windows agent [#136](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/136) ([Iristyle](https://github.com/Iristyle))
- (MODULES-3636) Upgrade on non-English Windows [#135](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/135) ([Iristyle](https://github.com/Iristyle))
- Test if stringify_facts = true on agent [#131](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/131) ([hpcprofessional](https://github.com/hpcprofessional))
- (MODULES-3571) Allow setting install_path for MSI [#130](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/130) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fix up tests [#129](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/129) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-16317) Disable client SSL verification on Xenial [#128](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/128) ([highb](https://github.com/highb))
- Explicitly setting environment to nodes current environment [#127](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/127) ([james-powis](https://github.com/james-powis))
- (MODULES-3449) Stop Windows pxp-agent service [#124](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/124) ([Iristyle](https://github.com/Iristyle))
- (MODULES-3433) Write Windows PID file on upgrade [#122](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/122) ([Iristyle](https://github.com/Iristyle))
- (maint) Update metadata.json for Puppet 3.7 [#119](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/119) ([Iristyle](https://github.com/Iristyle))

## [1.2.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.2.0) - 2016-05-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.1.0...1.2.0)

### Other

- Update CHANGELOG.md [#117](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/117) ([highb](https://github.com/highb))
- (MODULES-3304/PE-15256) Fix Windows 2008 upgrades [#116](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/116) ([highb](https://github.com/highb))
- (maint) Add maintainers [#115](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/115) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-11531) Fix upgrade issue with dev builds [#113](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/113) ([highb](https://github.com/highb))
- (PE-15036) Fix Windows permission inheritance [#112](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/112) ([highb](https://github.com/highb))
- (RE-7037) Use updated gpg key [#111](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/111) ([underscorgan](https://github.com/underscorgan))
- (PE-11531) Stop OSX from forgetting packages [#110](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/110) ([highb](https://github.com/highb))
- (PE-11531) Centralize check for aio upgrade [#108](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/108) ([highb](https://github.com/highb))
- (maint) Fix handling dev versions on Solaris 11 [#107](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/107) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-11531) Don't remove packages if package_version undef [#106](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/106) ([highb](https://github.com/highb))
- (maint) Update metadata to remove pe requirement. [#104](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/104) ([bmjen](https://github.com/bmjen))
- (maint) Fix spec that should've skipped Solaris [#103](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/103) ([MikaelSmith](https://github.com/MikaelSmith))
- (packaging) Prepare for puppetlabs-puppet_agent 1.2.0 [#102](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/102) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-14495) Remove pluginsync setting if upgrading to 1.4.x [#101](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/101) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fix issue #98, don't require `pe_compiling_server_aio_build` [#100](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/100) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fix a dependency cycle introduced on Windows by Sol11 work [#99](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/99) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Re-enable open-source upgrades from 3.x [#96](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/96) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-11531) Fix Debian ensure => version [#95](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/95) ([highb](https://github.com/highb))
- (PE-14463) Support 32-bit Windows via pe_repo [#94](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/94) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-12299) Add Solaris 11 support [#93](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/93) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Update supported platforms [#92](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/92) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fix acceptance using Vagrant configs, allow flexible starting Puppet version [#91](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/91) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fix typo breaking Debian upgrade for PE [#89](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/89) ([purplexa](https://github.com/purplexa))
- (PE-11531) Allow upgrades from Puppet 4+ [#86](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/86) ([highb](https://github.com/highb))
- add support for Amazon Linux to puppet_agent::osfamily::redhat [#85](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/85) ([oshaughnessy](https://github.com/oshaughnessy))
- (PE-13179) remove lower version requirement in code [#81](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/81) ([mwbutcher](https://github.com/mwbutcher))

## [1.1.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.1.0) - 2016-03-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1.0.0...1.1.0)

### Other

- README update [#88](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/88) ([bmjen](https://github.com/bmjen))
- Release Prep for 1.1.0 [#87](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/87) ([HelenCampbell](https://github.com/HelenCampbell))
- (PE-10956) Ensure local package resource defined on Windows [#84](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/84) ([highb](https://github.com/highb))
- (PE-10956) Manage /opt/puppetlabs [#83](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/83) ([jpartlow](https://github.com/jpartlow))
- (PE-10956) Manage /opt/puppetlabs [#82](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/82) ([highb](https://github.com/highb))
- Use slashes for regex [#80](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/80) ([glarizza](https://github.com/glarizza))
- (MODULES-3015) Fix SLES11 GPG key import issue [#79](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/79) ([glarizza](https://github.com/glarizza))
- (PE-13608) Do not convert windows file resource to RAL catalog [#76](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/76) ([demophoon](https://github.com/demophoon))
- (PE-12002) Add AIX support [#74](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/74) ([mwbutcher](https://github.com/mwbutcher))
- (PE-12001) Add Solaris 10 sparc to supported arch [#72](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/72) ([highb](https://github.com/highb))
- (PE-13179) Puppet Agent Module: Update metadata.json to include Anken… [#71](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/71) ([mwbutcher](https://github.com/mwbutcher))
- Issue/master/pe 10914 add osx 109 upgrade [#70](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/70) ([mwbutcher](https://github.com/mwbutcher))
- (maint) allow using the internal mirror when resolving gems [#69](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/69) ([justinstoller](https://github.com/justinstoller))
- (MODULES-2750) Pass in Puppet agent PID as command line parameter to avoid recreatin… [#68](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/68) ([dhs-rec](https://github.com/dhs-rec))
- (PE-10956) windows upgrade [#66](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/66) ([highb](https://github.com/highb))
- (PE-12001) Add solaris 10 [#65](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/65) ([jpartlow](https://github.com/jpartlow))
- (PE-10915) Add SLES 10 upgrade for PE [#63](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/63) ([jpartlow](https://github.com/jpartlow))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/1.0.0) - 2015-07-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/0.2.0...1.0.0)

### Other

- (maint) Add changelog for 1.0.0 release [#61](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/61) ([MikaelSmith](https://github.com/MikaelSmith))
- (PUP-4925) Label a known issue with Server 2003 [#60](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/60) ([MikaelSmith](https://github.com/MikaelSmith))
- (PUP-4921) Add PE version restriction [#59](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/59) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Clarify upgrade process in docs [#58](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/58) ([MikaelSmith](https://github.com/MikaelSmith))
- (doc) Fix minor typo and note changing client.cfg [#57](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/57) ([MikaelSmith](https://github.com/MikaelSmith))
- Remove classfile puppet.conf setting, update for PE windows [#56](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/56) ([ericwilliamson](https://github.com/ericwilliamson))

## [0.2.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/0.2.0) - 2015-07-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/0.1.0...0.2.0)

### Other

- (maint) Provide changelog for 0.2.0 release [#55](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/55) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Add Windows support to metadata [#54](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/54) ([MikaelSmith](https://github.com/MikaelSmith))
- Metadata updates [#53](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/53) ([underscorgan](https://github.com/underscorgan))
- FM-2915: added known issue for Windows [#52](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/52) ([jbondpdx](https://github.com/jbondpdx))
- (PUP-4886) Clear settings at global level [#51](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/51) ([MikaelSmith](https://github.com/MikaelSmith))
- (PUP-4808) Remove Ubuntu 14.10 support [#50](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/50) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fix issue where we are breaking uri path for windows [#49](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/49) ([cyberious](https://github.com/cyberious))
- (PUP-4849) Make puppet_agent ensure platform type in tests [#48](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/48) ([MikaelSmith](https://github.com/MikaelSmith))
- (maint) Fixes for Forge score [#47](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/47) ([MikaelSmith](https://github.com/MikaelSmith))
- (PE-10132) Remove old PE 3.8 repo [#46](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/46) ([ericwilliamson](https://github.com/ericwilliamson))
- (maint) Use BKR-314 and BKR-317 fixes [#32](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/32) ([MikaelSmith](https://github.com/MikaelSmith))

## [0.1.0](https://github.com/puppetlabs/puppetlabs-puppet_agent/tree/0.1.0) - 2015-07-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_agent/compare/1012a070fc7632ea6eb5b73de378c6e0003c959d...0.1.0)
