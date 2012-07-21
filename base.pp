
class base {

  if ! $::hiera_ready {
    fail('Hiera is required to install and manage base profile.')
  }

  #-----------------------------------------------------------------------------
  # Module configurations (existing)

  $packages                        = $data::common::global_packages

  $git_group                       = hiera('git_group', 'git')

  $puppet_manifest_dir             = $data::common::puppet_manifest_dir
  $puppet_template_dir             = $data::common::puppet_template_dir
  $puppet_module_dirs              = $data::common::puppet_module_dirs

  $puppet_update_environment       = $data::common::puppet_update_environment
  $puppet_update_command           = $data::common::puppet_update_command

  $hiera_backends                  = $data::common::hiera_backends

  $git_push_commands               = [
    $puppet_update_environment,
    $puppet_update_command,
  ]

  $haproxy_proxies                 = hiera('haproxy_proxies', {})

  #-----------------------------------------------------------------------------
  # Profile configurations (new)

  $admin_name                      = hiera('base_admin_name', 'admin')
  $admin_email                     = hiera('base_admin_email', '')
  $admin_allowed_ssh_key           = hiera('base_admin_allowed_ssh_key')
  $admin_allowed_ssh_key_type      = hiera('base_admin_allowed_ssh_key_type', 'rsa')
  $admin_public_ssh_key            = hiera('base_admin_public_ssh_key', '')
  $admin_private_ssh_key           = hiera('base_admin_private_ssh_key', '')
  $admin_ssh_key_type              = hiera('base_admin_ssh_key_type', 'rsa')

  $puppet_repo                     = hiera('base_puppet_repo', 'puppet.git')
  $puppet_source                   = hiera('base_puppet_source', '')
  $puppet_revision                 = hiera('base_puppet_revision', 'master')

  $config_repo                     = hiera('base_config_repo', 'config.git')
  $config_source                   = hiera('base_config_source', '')
  $config_revision                 = hiera('base_config_revision', 'master')

  #-----------------------------------------------------------------------------
  # Required systems

  class { 'global':
    packages => $packages,
  }

  include ntp
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
    manifest_dir       => $puppet_manifest_dir,
    template_dir       => $puppet_template_dir,
    module_dirs        => $puppet_module_dirs,
    update_environment => $puppet_update_environment,
    update_command     => $puppet_update_command,
  }

  class { 'hiera':
    backends => $hiera_backends,
  }

  #---

  Class['global']
  -> Class['ruby'] -> Class['puppet'] -> Class['hiera']
  -> Class['ntp']
  -> Class['nullmailer']
  -> Class['xinetd']
  -> Class['iptables'] -> Class['ssh'] -> Class['sudo']
  -> Class['locales'] -> Class['users'] -> Class['git']

  #-----------------------------------------------------------------------------
  # Optional systems

  if ! empty($haproxy_proxies) {
    include haproxy
    Class['sudo'] -> Class['haproxy']
  }

  #-----------------------------------------------------------------------------
  # Environment

  users::user { $admin_name:
    alt_groups           => [ $git_group ],
    email                => $admin_email,
    allowed_ssh_key      => $admin_allowed_ssh_key,
    allowed_ssh_key_type => $admin_allowed_ssh_key_type,
    public_ssh_key       => $admin_public_ssh_key,
    private_ssh_key      => $admin_private_ssh_key,
    ssh_key_type         => $admin_ssh_key_type,
  }

  git::repo { $puppet_repo:
    source        => $puppet_source,
    revision      => $puppet_revision,
    base          => 'false',
    push_commands => $git_push_commands,
  }

  git::repo { $config_repo:
    source        => $config_source,
    revision      => $config_revision,
    base          => 'false',
    push_commands => $git_push_commands,
  }
}
