
class base {

  if ! $::hiera_ready {
    fail('Hiera is required to install and manage base profile.')
  }

  #-----------------------------------------------------------------------------
  # Configurations

  $admin_name                      = hiera('base_admin_name', 'admin')
  $admin_email                     = hiera('base_admin_email', '')
  $admin_allowed_ssh_key           = hiera('base_admin_allowed_ssh_key')
  $admin_allowed_ssh_key_type      = hiera('base_admin_allowed_ssh_key_type', 'rsa')
  $admin_public_ssh_key            = hiera('base_admin_public_ssh_key', '')
  $admin_private_ssh_key           = hiera('base_admin_private_ssh_key', '')
  $admin_ssh_key_type              = hiera('base_admin_ssh_key_type', 'rsa')

  $puppet_source                   = hiera('base_puppet_source', '')
  $puppet_revision                 = hiera('base_puppet_revision', 'master')

  $config_source                   = hiera('base_config_source', '')
  $config_revision                 = hiera('base_config_revision', 'master')

  #-----------------------------------------------------------------------------
  # Required systems

  class { 'global':
    packages => $data::common::os_global_packages,
  }

  include ntp
  include keepalived
  include nullmailer
  include xinetd
  include iptables
  include sudo
  include ssh
  include locales
  include users
  include git
  include ruby

  class { 'puppet':
    manifest_dir       => $data::common::os_puppet_manifest_dir,
    template_dir       => $data::common::os_puppet_template_dir,
    module_dirs        => $data::common::os_puppet_module_dirs,
    update_environment => $data::common::os_puppet_update_environment,
    update_command     => $data::common::os_puppet_update_command,
  }

  class { 'hiera':
    backends => $data::common::os_hiera_backends,
  }

  #---

  Class['global']
  -> Class['ruby'] -> Class['puppet'] -> Class['hiera']
  -> Class['ntp']
  -> Class['keepalived']
  -> Class['nullmailer']
  -> Class['xinetd']
  -> Class['iptables'] -> Class['ssh'] -> Class['sudo']
  -> Class['locales'] -> Class['users'] -> Class['git']

  #-----------------------------------------------------------------------------
  # Optional systems

  if ! empty($haproxy::params::proxies) {
    include haproxy
    Class['sudo'] -> Class['haproxy']
  }

  #-----------------------------------------------------------------------------
  # Environment

  users::user { $admin_name:
    alt_groups           => [ $git::params::group ],
    email                => $admin_email,
    allowed_ssh_key      => $admin_allowed_ssh_key,
    allowed_ssh_key_type => $admin_allowed_ssh_key_type,
    public_ssh_key       => $admin_public_ssh_key,
    private_ssh_key      => $admin_private_ssh_key,
    ssh_key_type         => $admin_ssh_key_type,
  }

  git::repo { $data::common::os_base_puppet_repo:
    source        => $puppet_source,
    revision      => $puppet_revision,
    base          => 'false',
    push_commands => $data::common::os_git_push_commands,
  }

  git::repo { $data::common::os_base_config_repo:
    source        => $config_source,
    revision      => $config_revision,
    base          => 'false',
    push_commands => $data::common::os_git_push_commands,
  }
}
