# Starts a Puppet agent run on the specified targets.
# Note: This plan may cause issues when run in Puppet Enterprise.
# @param targets The targets to start a Puppet agent run on.
# @param noop if true, all runs will use --noop
# @param environment the desired puppet code environment
# @param tags an optional string that will be passed to --tags
plan puppet_agent::run (
  TargetSpec $targets,
  Boolean $noop = false,
  Optional[String[1]] $environment = undef,
  Optional[Variant[String[1],Array[String[1]]]] $tags = undef
) {
  # Check which targets have the agent installed by checking
  # the version of the agent. No point in trying to run the
  # agent if it's not installed.
  $version_results = run_task(
    'puppet_agent::version',
    $targets,
    'Check for Puppet agent',
    '_catch_errors' => true
  )

  # Create results with more descriptive error messages for any targets
  # where the version task failed.
  $version_error_results = $version_results.error_set.map |$result| {
    $err = {
      '_error' => {
        'msg'     => "The task puppet_agent::version failed: ${result.error.message}. Unable to determine if the Puppet agent is installed.",
        'kind'    => 'puppet_agent/agent-version-error',
        'details' => {},
      },
    }

    Result.new($result.target, $err)
  }

  # Filter targets by those that have an agent installed and
  # those that don't. The puppet_agent::version task will return
  # version:null for any targets that don't have an agent.
  $agentless_results = $version_results.ok_set.filter_set |$result| {
    $result['version'] == undef
  }

  $agent_results = $version_results.ok_set.filter_set |$result| {
    $result['version'] != undef
  }

  # Create fail results for agentless targets.
  $agentless_error_results = $agentless_results.map |$result| {
    $err = {
      '_error' => {
        'msg'     => 'Puppet agent is not installed on the target. Run the puppet_agent::install task on these targets to install the Puppet agent.',
        'kind'    => 'puppet_agent/agent-not-installed',
        'details' => {},
      },
    }

    Result.new($result.target, $err)
  }

  # Run the agent on all targets that have the agent installed.
  $arg_env = $environment ? {
    Undef   => {},
    default => { 'environment' => $environment, },
  }
  $arg_noop = $noop ? {
    true    => { 'noop' => true, },
    default => {},
  }
  $arg_tags = $tags ? {
    Undef   => {},
    default => { 'tags' => $tags },
  }
  $args = $arg_env + $arg_noop + $arg_tags + { '_catch_errors' => true }
  $run_results = run_task(
    'puppet_agent::run',
    $agent_results.targets,
    'Run Puppet agent',
    $args,
  )

  # Merge all of the results into a single ResultSet so each
  # target has a result.
  return ResultSet.new(
    $version_error_results +
    $agentless_error_results +
    $run_results.results
  )
}
