
class bootstrap {

  include config::common

  include users
  include global_lib

  #-----------------------------------------------------------------------------
  # Security

  if $::vagrant_exists {
    $ssh_users = flatten([ $config::common::bootstrap_users, 'vagrant' ])
  }
  else {
    $ssh_users = $config::common::bootstrap_users
  }

  class { 'iptables': allow_icmp => true }
  class { 'ssh':
    port                   => $config::common::ssh_port,
    allow_root_login       => true,
    allow_password_auth    => true,
    permit_empty_passwords => true,
    users                  => $ssh_users,
    user_groups            => [],
  }

  #-----------------------------------------------------------------------------
  # Puppet

  class { 'ruby':
    ruby_gems => $config::common::ruby_gems,
    gem_home  => $config::common::gem_home,
    gem_path  => $config::common::gem_path,
  }

  class { 'puppet':
    manifest_file      => $config::common::puppet_manifest_file,
    manifest_path      => $config::common::puppet_manifest_path,
    template_path      => $config::common::puppet_template_path,
    module_paths       => $config::common::puppet_module_paths,
    update_interval    => $config::common::puppet_update_interval,
    update_environment => $config::common::puppet_update_environment,
    update_command     => $config::common::puppet_update_command,
    hiera_hierarchy    => $config::common::hiera_hierarchy,
    hiera_backends     => $config::common::hiera_backends,
  }

  #-----------------------------------------------------------------------------
  # Git

  # Initially the git user will have no password until the server is bootstrapped
  # at which time only a valid private/public keypair will be valid for git.
  class { 'git':
    home       => $config::common::git_home,
    user       => $config::common::git_user,
    group      => $config::common::git_group,
    password   => $config::common::git_init_password,
  }

  #-----------------------------------------------------------------------------
  # Configuration repositories

  git::repo { $config::common::puppet_repo:
    home          => $config::common::git_home,
    user          => $config::common::git_user,
    group         => $config::common::git_group,
    source        => $config::common::puppet_source,
    revision      => $config::common::puppet_revision,
    base          => false,
    push_commands => [
      $config::common::puppet_update_environment,
      $config::common::puppet_update_command,
    ],
  }

  git::repo { $config::common::config_repo:
    home          => $config::common::git_home,
    user          => $config::common::git_user,
    group         => $config::common::git_group,
    base          => false,
    push_commands => [
      $config::common::puppet_update_environment,
      $config::common::puppet_update_command,
    ],
  }

  #-----------------------------------------------------------------------------
  # Execution order

  Class['ruby'] -> Class['puppet']
  -> Class['global_lib']
  -> Class['iptables'] -> Class['ssh']
  -> Class['users'] -> Class['git']
}
