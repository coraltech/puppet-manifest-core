
class bootstrap {

  #-----------------------------------------------------------------------------
  # Boostrap configurations

  if $::vagrant_exists {
    $ssh_users = flatten([ $data::common::ssh_bootstrap_users, 'vagrant' ])
  }
  else {
    $ssh_users = $data::common::ssh_bootstrap_users
  }

  $git_push_commands = [
    $data::common::puppet_update_environment,
    $data::common::puppet_update_command,
  ]

  #-----------------------------------------------------------------------------
  # Required systems

  class { 'global':
    packages => $data::common::global_packages,
    facts    => $data::common::global_facts,
  }

  class { 'iptables':
    allow_icmp => 'true',
  }

  class { 'ssh':
    port                   => $data::common::ssh_port,
    configure_firewall     => 'true',
    allow_root_login       => 'true',
    allow_password_auth    => 'true',
    permit_empty_passwords => 'true',
    users                  => $ssh_users,
    user_groups            => [],
  }

  include users

  class { 'git':
    password => $data::common::git_init_password,
  }

  class { 'ruby':
    ruby_gems => $data::common::ruby_gems,
  }

  class { 'puppet':
    manifest_file      => $data::common::puppet_manifest_file,
    manifest_dir       => $data::common::puppet_manifest_dir,
    template_dir       => $data::common::puppet_template_dir,
    module_dirs        => $data::common::puppet_module_dirs,
    update_environment => $data::common::puppet_update_environment,
    update_command     => $data::common::puppet_update_command,
  }

  class { 'hiera':
    backends  => $data::common::hiera_backends,
    hierarchy => $data::common::hiera_hierarchy,
  }

  #---

  Class['global']
  -> Class['ruby'] -> Class['puppet'] -> Class['hiera']
  -> Class['iptables'] -> Class['ssh']
  -> Class['users'] -> Class['git']

  #-----------------------------------------------------------------------------
  # Environment

  git::repo { $data::common::base_puppet_repo:
    source        => $data::common::base_puppet_source,
    revision      => $data::common::base_puppet_revision,
    base          => 'false',
    push_commands => $git_push_commands,
  }

  git::repo { $data::common::base_config_repo:
    base          => 'false',
    push_commands => $git_push_commands,
  }
}
