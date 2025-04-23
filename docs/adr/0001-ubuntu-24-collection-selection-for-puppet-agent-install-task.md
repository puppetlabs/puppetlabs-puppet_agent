# 1. Ubuntu 24 Collection Selection for puppet_agent::install Task

Date: 2025-04-23

## Status

Proposed

## Context

When running Bolt apply with Ubuntu 24 (codename: noble), installations were failing because the puppet_agent::install task defaulted to using the generic 'puppet' collection, resulting in the installation of `puppet-release-noble.deb` instead of the version-specific `puppet8-release-noble.deb`.

This issue specifically affected Ubuntu 24, while other operating systems worked correctly. The underlying cause was that the generic 'puppet' repository didn't properly support Ubuntu 24, whereas the version-specific repositories (like 'puppet8') did have proper packages available.

The puppet_agent::install task (implemented in install_shell.sh) provides a mechanism for installing the Puppet agent across various platforms. It accepts parameters including 'collection', which determines which package collection to use. If no collection is specified, it was defaulting to the generic 'puppet' collection.

A temporary fix was implemented in Bolt's apply_prep.rb function, which added logic to determine the Puppet version and set the collection parameter accordingly. While this fix worked, it violated architectural separation of concerns by placing target-specific logic in the higher-level orchestration function.

## Decision

Move the Puppet version detection and collection selection logic from Bolt's apply_prep function to the puppet_agent::install task's install_shell.sh script, which is the architecturally appropriate location for this functionality.

The implementation enhances the collection selection logic to:

1. First check if a collection was explicitly specified
   - If so, use that collection as before
   - This maintains backward compatibility and user control

2. If no collection is specified, intelligently determine the appropriate collection:
   - First try to detect Puppet version from `/opt/puppetlabs/puppet/VERSION`
   - If that fails, try using the `puppet --version` command
   - Use the major version to set the collection to `puppet{major_version}` (e.g., `puppet8`)
   - Only fall back to the generic `puppet` collection as a last resort

This ensures that for Ubuntu 24, the task will use puppet8-release-noble.deb (assuming Puppet 8) instead of puppet-release-noble.deb.

Rationale:

- The task script is the appropriate location for OS-specific installation logic, maintaining separation of concerns.
- The task already handles platform-specific behavior, making it the natural location for this enhancement.

## Consequences

Positive:

- Ubuntu 24 installations now work correctly out of the box.
- The solution keeps high-level consumers, like bolt, agnostic to implementation details.
- All platforms will now prefer version-specific collections by default, which is generally more reliable.

Negative:

- The install_shell.sh script becomes slightly more complex with additional logic.
- The solution relies on either /opt/puppetlabs/puppet/VERSION existing or the puppet command being available, though it falls back gracefully if neither is available.
- If a very different version of Puppet is running Bolt compared to what should be installed on the target, this approach might select a non-optimal collection. However, this is mitigated by the ability to explicitly specify a collection when needed.
