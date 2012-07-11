
class base {

  include config::common

  include global_lib

  #-----------------------------------------------------------------------------

  $allow_icmp                      = hiera('allow_icmp', true)
  $ssh_port                        = hiera('ssh_port', 22)
  $allow_root_login                = hiera('allow_root_login', false)
  $allow_password_auth             = hiera('allow_password_auth', false)
  $permit_empty_passwords          = hiera('permit_empty_passwords', false)
  $sudo_permissions                = hiera('sudo_permissions', [])
  $locales                         = hiera('locales', [])
  $user_umask                      = hiera('user_umask', '022')

  $email_servers                   = hiera('email_servers', [])

  $admin_name                      = hiera('admin_name', 'admin')
  $admin_group                     = hiera('admin_group', 'admin')
  $admin_email                     = hiera('admin_email', '')
  $admin_allowed_ssh_key           = hiera('admin_allowed_ssh_key')
  $admin_allowed_ssh_key_type      = hiera('admin_allowed_ssh_key_type')
  $admin_public_ssh_key            = hiera('admin_public_ssh_key', '')
  $admin_private_ssh_key           = hiera('admin_private_ssh_key', '')
  $admin_ssh_key_type              = hiera('admin_ssh_key_type', 'rsa')
  $admin_editor                    = hiera('admin_editor', 'vim')

  $git_home                        = hiera('git_home')
  $git_user                        = hiera('git_user')
  $git_group                       = hiera('git_group')
  $git_root_email                  = hiera('git_root_email', '')
  $git_skel_email                  = hiera('git_skel_email', '')

  $ruby_gems                       = hiera('ruby_gems')
  $gem_home                        = hiera('gem_home')
  $gem_path                        = hiera('gem_path')

  $puppet_repo                     = hiera('puppet_repo')
  $puppet_manifest_file            = hiera('puppet_manifest_file')
  $puppet_manifest_path            = hiera('puppet_manifest_path')
  $puppet_manifest                 = hiera('puppet_manifest')
  $puppet_template_path            = hiera('puppet_template_path')
  $puppet_module_paths             = hiera('puppet_module_paths')
  $puppet_source                   = hiera('puppet_source')
  $puppet_revision                 = hiera('puppet_revision')
  $puppet_update_interval          = hiera('puppet_update_interval')
  $puppet_update_environment       = hiera('puppet_update_environment')
  $puppet_update_command           = hiera('puppet_update_command')

  $hiera_hierarchy                 = hiera('hiera_hierarchy')
  $hiera_backends                  = hiera('hiera_backends')

  $config_repo                     = hiera('config_repo')
  $config_source                   = hiera('config_source', '')
  $config_revision                 = hiera('config_revision', '')

  $haproxy_user                    = hiera('haproxy_user', 'haproxy')
  $haproxy_group                   = hiera('haproxy_group', 'haproxy')
  $haproxy_debug                   = hiera('haproxy_debug', false)
  $haproxy_quiet                   = hiera('haproxy_quiet', false)
  $haproxy_max_connections         = hiera('haproxy_max_connections', 5000)
  $haproxy_default_mode            = hiera('haproxy_default_mode', 'http')
  $haproxy_default_retries         = hiera('haproxy_default_retries', 3)
  $haproxy_default_max_connections = hiera('haproxy_default_max_connections', 1000)
  $haproxy_default_options         = hiera('haproxy_default_options', {})
  $haproxy_proxies                 = hiera('haproxy_proxies', {})

  #-----------------------------------------------------------------------------
  # Basic systems

  class { 'ntp': autoupdate => false }
  class { 'nullmailer': remotes => $email_servers }

  include xinetd

  #-----------------------------------------------------------------------------
  # Security

  class { 'iptables': allow_icmp => $allow_icmp }
  class { 'sudo': permissions => $sudo_permissions }
  class { 'ssh':
    port                   => $ssh_port,
    allow_root_login       => $allow_root_login ? {
      false                => false,
      /(false|)/           => false,
      default              => true,
    },
    allow_password_auth    => $allow_password_auth ? {
      false                => false,
      /(false|)/           => false,
      default              => true,
    },
    permit_empty_passwords => $permit_empty_passwords ? {
      false                => false,
      /(false|)/           => false,
      default              => true,
    },
    user_groups            => [ $admin_group, $git_group ],
  }

  #-----------------------------------------------------------------------------
  # User environment

  class { 'locales': locales => $locales }

  class { 'users':
    editor               => $admin_editor,
    umask                => $user_umask,
    root_public_ssh_key  => $admin_public_ssh_key ? {
      ""                   => undef,
      default              => $admin_public_ssh_key,
    },
    root_private_ssh_key => $admin_private_ssh_key ? {
      ""                   => undef,
      default              => $admin_private_ssh_key,
    },
    root_ssh_key_type    => $admin_ssh_key_type ? {
      ""                   => undef,
      default              => $admin_ssh_key_type,
    },
  }

  users::user { $admin_name:
    group                => $admin_group,
    alt_groups           => [ $git_group ],
    email                => $admin_email,
    allowed_ssh_key      => $admin_allowed_ssh_key,
    allowed_ssh_key_type => $admin_allowed_ssh_key_type,
    public_ssh_key       => $admin_public_ssh_key ? {
      ""                   => undef,
      default              => $admin_public_ssh_key,
    },
    private_ssh_key      => $admin_private_ssh_key ? {
      ""                   => undef,
      default              => $admin_private_ssh_key,
    },
    ssh_key_type         => $admin_ssh_key_type ? {
      ""                   => undef,
      default              => $admin_ssh_key_type,
    },
  }

  #-----------------------------------------------------------------------------
  # Puppet

  class { 'ruby':
    ruby_gems => $ruby_gems,
    gem_home  => $gem_home,
    gem_path  => $gem_path,
  }

  class { 'puppet':
    manifest_file      => $puppet_manifest_file,
    manifest_path      => $puppet_manifest_path,
    template_path      => $puppet_template_path,
    module_paths       => $puppet_module_paths,
    update_interval    => $puppet_update_interval,
    update_environment => $puppet_update_environment,
    update_command     => $puppet_update_command,
    hiera_hierarchy    => $hiera_hierarchy,
    hiera_backends     => $hiera_backends,
  }

  #-----------------------------------------------------------------------------
  # Git

  class { 'git':
    home                 => $git_home,
    user                 => $git_user,
    group                => $git_group,
    allowed_ssh_key      => $admin_allowed_ssh_key,
    allowed_ssh_key_type => $admin_allowed_ssh_key_type,
    password             => undef, # We are now using SSH key based authentication.
    root_email           => $git_root_email,
    skel_email           => $git_skel_email,
  }

  #-----------------------------------------------------------------------------
  # Configuration repositories

  if  $puppet_update_environment and $puppet_update_command {
    $push_commands = [
      $puppet_update_environment,
      $puppet_update_command,
    ]
  }
  elsif $puppet_update_command {
    $push_commands = [ $puppet_update_command ]
  }
  else {
    $push_commands = []
  }

  #---

  git::repo { $puppet_repo:
    home          => $git_home,
    user          => $git_user,
    group         => $git_group,
    source        => $puppet_source ? {
      ""      => undef,
      default => $puppet_source,
    },
    revision      => $puppet_revision ? {
      ""      => undef,
      default => $puppet_revision,
    },
    base          => false,
    push_commands => $push_commands,
  }

  git::repo { $config_repo:
    home          => $git_home,
    user          => $git_user,
    group         => $git_group,
    source        => $config_source ? {
      ""            => undef,
      default       => $config_source,
    },
    revision      => $config_revision ? {
      ""            => undef,
      default       => $config_revision,
    },
    base          => false,
    push_commands => $push_commands,
  }

  #-----------------------------------------------------------------------------
  # Load balancer

  if ! empty($haproxy_proxies) {
    class { 'haproxy':
      user                    => $haproxy_user,
      group                   => $haproxy_group,
      debug                   => $haproxy_debug ? {
        false                => false,
        /(false|)/           => false,
        default              => true,
      },
      quiet                   => $haproxy_quiet ? {
        false                => false,
        /(false|)/           => false,
        default              => true,
      },
      max_connections         => $haproxy_max_connections,
      default_mode            => $haproxy_default_mode,
      default_retries         => $haproxy_default_retries,
      default_max_connections => $haproxy_default_max_connections,
      default_options         => $haproxy_default_options,
      proxies                 => $haproxy_proxies,
    }

    #---

    Class['sudo'] -> Class['haproxy']
  }

  #-----------------------------------------------------------------------------
  # Execution order

  Class['ruby'] -> Class['puppet']
  -> Class['global_lib']
  -> Class['ntp']
  -> Class['nullmailer']
  -> Class['xinetd']
  -> Class['iptables'] -> Class['ssh'] -> Class['sudo']
  -> Class['locales'] -> Class['users'] -> Class['git']
}
