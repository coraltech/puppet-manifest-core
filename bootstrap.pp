
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

  class { 'sudo':
    permissions => $data::common::sudo_permissions,
  }

  include users

  class { 'git':
    password => $data::common::git_init_password,
  }

  class { 'ruby':
    gems => $data::common::ruby_gems,
  }

  class { 'puppet':
    manifest_file      => $data::common::puppet_manifest_file,
    manifest_dir       => $data::common::puppet_manifest_dir,
    template_dir       => $data::common::puppet_template_dir,
    module_dirs        => $data::common::puppet_module_dirs,
    update_environment => $data::common::puppet_update_environment,
  }

  class { 'hiera':
    backends  => $data::common::hiera_backends,
    hierarchy => $data::common::hiera_hierarchy,
  }

  #-----------------------------------------------------------------------------
  # Environment

  if $::vagrant_exists {
    users::conf { $data::common::vagrant_user: }
  }

  #---

  git::repo { $data::common::base_puppet_repo:
    source               => $data::common::base_puppet_source,
    revision             => $data::common::base_puppet_revision,
    base                 => 'false',
    post_update_commands => $data::common::base_post_update_commands,
  }

  git::repo { $data::common::base_config_repo:
    revision             => '',
    base                 => 'false',
    post_update_commands => $data::common::base_post_update_commands,
  }
}
