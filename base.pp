
class base {

  if ! config_initialized {
    fail('Configuration system (Hiera) is required to install and manage the base profile.')
  }

  #-----------------------------------------------------------------------------
  # Configurations

  $users                = global_array('base_users', [])
  $repos                = global_array('base_repos', [])

  $post_update_commands = global_array('base_post_update_commands')

  $puppet_repo          = global_param('base_puppet_repo')
  $puppet_source        = global_param('base_puppet_source')
  $puppet_revision      = global_param('base_puppet_revision')

  $config_repo          = global_param('base_config_repo')
  $config_source        = global_param('base_config_source')
  $config_revision      = global_param('base_config_revision')

  $vagrant_user         = global_param('vagrant_user')

  #-----------------------------------------------------------------------------
  # Required systems

  include global

  include iptables
  include ssh
  include sudo

  include ntp
  include locales
  include users

  include git
  include ruby

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
  }

  include keepalived
  include nullmailer
  include xinetd

  #---

  Class['global']
  -> Class['iptables'] -> Class['ssh'] -> Class['sudo']
  -> Class['ntp']
  -> Class['locales'] -> Class['users']
  -> Class['git']
  -> Class['ruby'] -> Class['puppet'] -> Class['hiera']
  -> Class['keepalived']
  -> Class['nullmailer']
  -> Class['xinetd']

  #-----------------------------------------------------------------------------
  # Optional systems

  include haproxy::params

  if ! empty($haproxy::params::proxies) {
    include haproxy
    Class['xinetd'] -> Class['haproxy']
  }

  #-----------------------------------------------------------------------------
  # Environment

  if $::vagrant_exists {
    users::conf { $vagrant_user: }
    Class['users'] -> Users::Conf[$vagrant_user]
  }

  if ! empty($users) {
    base::user { $users:
      require => Class['users'],
    }
  }

  #---

  git::repo { $puppet_repo:
    source               => $puppet_source,
    revision             => $puppet_revision,
    base                 => 'false',
    post_update_commands => $post_update_commands,
  }

  git::repo { $config_repo:
    source               => $config_source,
    revision             => $config_revision,
    base                 => 'false',
    post_update_commands => $post_update_commands,
  }

  if ! empty($repos) {
    base::repo { $repos:
      require => Class['git'],
    }
  }

  #---

  Class['xinetd']  # Last of the required systems
  -> Git::Repo[$puppet_repo]
  -> Git::Repo[$config_repo]
}

#*******************************************************************************
# Scalable resources
#*******************************************************************************

define base::user ( $user = $name ) {
  users::user { $user:
    ensure               => global_param("base_user_${user}_ensure", $users::params::user_ensure),
    alt_groups           => global_param("base_user_${user}_alt_groups", $users::params::user_alt_groups),
    email                => global_param("base_user_${user}_email", $users::params::user_email),
    comment              => global_param("base_user_${user}_comment", $users::params::user_comment),
    password             => global_param("base_user_${user}_password", $users::params::user_password),
    allowed_ssh_key      => global_param("base_user_${user}_allowed_ssh_key", $users::params::user_allowed_ssh_key),
    allowed_ssh_key_type => global_param("base_user_${user}_allowed_ssh_key_type", $users::params::user_allowed_ssh_key_type),
    public_ssh_key       => global_param("base_user_${user}_public_ssh_key", $users::params::user_public_ssh_key),
    private_ssh_key      => global_param("base_user_${user}_private_ssh_key", $users::params::user_private_ssh_key),
    ssh_key_type         => global_param("base_user_${user}_ssh_key_type", $users::params::user_ssh_key_type),
    shell                => global_param("base_user_${user}_shell", $users::params::user_shell),
  }
}

#-------------------------------------------------------------------------------

define base::repo ( $repo = $name ) {
  git::repo { "${repo}.git":
    source               => global_param("base_repo_${repo}_source", $git::params::source),
    revision             => global_param("base_repo_${repo}_revision", $git::params::revision),
    base                 => global_param("base_repo_${repo}_base", $git::params::base),
    post_update_commands => global_param("base_repo_${repo}_post_update_commands", $git::params::post_update_commands),
  }
}
