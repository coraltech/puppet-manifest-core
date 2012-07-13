
class bootstrap {

  include data::common

  #-----------------------------------------------------------------------------
  # Basic systems

  class { 'global_lib':
    facts => $data::common::facts,
  }

  #-----------------------------------------------------------------------------
  # Security

  if $::vagrant_exists {
    $ssh_users = flatten([ $data::common::bootstrap_users, 'vagrant' ])
  }
  else {
    $ssh_users = $data::common::bootstrap_users
  }

  class { 'iptables': allow_icmp => true }
  class { 'ssh':
    port                   => $data::common::ssh_port,
    allow_root_login       => true,
    allow_password_auth    => true,
    permit_empty_passwords => true,
    users                  => $ssh_users,
    user_groups            => [],
  }

  #-----------------------------------------------------------------------------
  # User environment

  include users

  #-----------------------------------------------------------------------------
  # Puppet

  class { 'ruby':
    ruby_gems => $data::common::ruby_gems,
  }

  class { 'puppet':
    manifest_file      => $data::common::puppet_manifest_file,
    manifest_path      => $data::common::puppet_manifest_path,
    template_path      => $data::common::puppet_template_path,
    module_paths       => $data::common::puppet_module_paths,
    update_interval    => $data::common::puppet_update_interval,
    update_environment => $data::common::puppet_update_environment,
    update_command     => $data::common::puppet_update_command,
    hiera_hierarchy    => $data::common::hiera_hierarchy,
    hiera_backends     => $data::common::hiera_backends,
  }

  #-----------------------------------------------------------------------------
  # Git

  # Initially the git user will have no password until the server is bootstrapped
  # at which time only a valid private/public keypair will be valid for git.
  class { 'git':
    home       => $data::common::git_home,
    user       => $data::common::git_user,
    group      => $data::common::git_group,
    password   => $data::common::git_init_password,
  }

  #-----------------------------------------------------------------------------
  # Configuration repositories

  git::repo { $data::common::puppet_repo:
    home          => $data::common::git_home,
    user          => $data::common::git_user,
    group         => $data::common::git_group,
    source        => $data::common::puppet_source,
    revision      => $data::common::puppet_revision,
    base          => false,
    push_commands => [
      $data::common::puppet_update_environment,
      $data::common::puppet_update_command,
    ],
  }

  git::repo { $data::common::config_repo:
    home          => $data::common::git_home,
    user          => $data::common::git_user,
    group         => $data::common::git_group,
    base          => false,
    push_commands => [
      $data::common::puppet_update_environment,
      $data::common::puppet_update_command,
    ],
  }

  #-----------------------------------------------------------------------------
  # Execution order

  Class['global_lib']
  -> Class['ruby'] -> Class['puppet']
  -> Class['iptables'] -> Class['ssh']
  -> Class['users'] -> Class['git']
}
