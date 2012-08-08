
class bootstrap {

  #-----------------------------------------------------------------------------
  # Required systems

  class { 'global':
    facts => $data::common::global_facts,
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
    users                  => $data::common::ssh_bootstrap_users,
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
    manifest_file      => $data::common::os_puppet_manifest_file,
    manifest_dir       => $data::common::os_puppet_manifest_dir,
    template_dir       => $data::common::os_puppet_template_dir,
    module_dirs        => $data::common::os_puppet_module_dirs,
    update_environment => $data::common::os_puppet_update_environment,
    update_command     => $data::common::os_puppet_update_command,
  }

  class { 'hiera':
    backends  => $data::common::os_hiera_backends,
    hierarchy => $data::common::hiera_hierarchy,
  }

  #---

  Class['global']
  -> Class['iptables'] -> Class['ssh']
  -> Class['users'] -> Class['git']
  -> Class['ruby'] -> Class['puppet'] -> Class['hiera']

  #-----------------------------------------------------------------------------
  # Environment

  if $::vagrant_exists {
    users::conf { $data::common::vagrant_user: }
    Class['users'] -> Users::Conf[$data::common::vagrant_user]
  }

  #---

  git::repo { $data::common::os_base_puppet_repo:
    source               => $data::common::base_puppet_source,
    revision             => $data::common::base_puppet_revision,
    base                 => 'false',
    post_update_commands => $data::common::os_git_post_update_commands,
  }

  git::repo { $data::common::os_base_config_repo:
    revision             => '',
    base                 => 'false',
    post_update_commands => $data::common::os_git_post_update_commands,
  }

  #---

  Class['hiera']  # Last of the required systems
  -> Git::Repo[$data::common::os_base_puppet_repo]
  -> Git::Repo[$data::common::os_base_config_repo]
}
