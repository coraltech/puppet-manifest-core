
class base {

  if ! $::hiera_ready {
    fail('Hiera is required to install and manage the base profile.')
  }

  #-----------------------------------------------------------------------------
  # Configurations

  $users           = unique(hiera_array('base_users', []))
  $repos           = unique(hiera_array('base_repos', []))

  $puppet_source   = hiera('base_puppet_source', '')
  $puppet_revision = hiera('base_puppet_revision', 'master')

  $config_source   = hiera('base_config_source', '')
  $config_revision = hiera('base_config_revision', '')

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

  include keepalived
  include nullmailer
  include xinetd

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
  -> Class['iptables'] -> Class['ssh'] -> Class['sudo']
  -> Class['ntp'] -> Class['locales'] -> Class['users'] -> Class['git']
  -> Class['ruby'] -> Class['puppet'] -> Class['hiera']
  -> Class['keepalived']
  -> Class['nullmailer']
  -> Class['xinetd']

  #-----------------------------------------------------------------------------
  # Optional systems

  if ! empty($haproxy::params::proxies) {
    include haproxy
    Class['xinetd'] -> Class['haproxy']
  }

  #-----------------------------------------------------------------------------
  # Environment

  if $::vagrant_exists {
    users::conf { $data::common::vagrant_user: }
    Class['users'] -> Users::Conf[$data::common::vagrant_user]
  }

  if ! empty($users) {
    base::user { $users: }
  }

  #---

  git::repo { $data::common::os_base_puppet_repo:
    source               => $puppet_source,
    revision             => $puppet_revision,
    base                 => 'false',
    post_update_commands => $data::common::os_git_post_update_commands,
  }

  git::repo { $data::common::os_base_config_repo:
    source               => $config_source,
    revision             => $config_revision,
    base                 => 'false',
    post_update_commands => $data::common::os_git_post_update_commands,
  }

  if ! empty($repos) {
    base::repo { $repos: }
  }

  #---

  Class['xinetd']  # Last of the required systems
  -> Users::User <| |>
  -> Git::Repo[$data::common::os_base_puppet_repo]
  -> Git::Repo[$data::common::os_base_config_repo]
  -> Git::Repo <| |>
}

#*******************************************************************************
# Scalable resources
#*******************************************************************************

define base::user ( $user = $name ) {
  @users::user { $user:
    ensure               => hiera("base_user_${user}_ensure", $users::params::user_ensure),
    alt_groups           => hiera("base_user_${user}_alt_groups", $users::params::user_alt_groups),
    email                => hiera("base_user_${user}_email", $users::params::user_email),
    comment              => hiera("base_user_${user}_comment", $users::params::user_comment),
    allowed_ssh_key      => hiera("base_user_${user}_allowed_ssh_key", $users::params::user_allowed_ssh_key),
    allowed_ssh_key_type => hiera("base_user_${user}_allowed_ssh_key_type", $users::params::user_allowed_ssh_key_type),
    public_ssh_key       => hiera("base_user_${user}_public_ssh_key", $users::params::user_public_ssh_key),
    private_ssh_key      => hiera("base_user_${user}_private_ssh_key", $users::params::user_private_ssh_key),
    ssh_key_type         => hiera("base_user_${user}_ssh_key_type", $users::params::user_ssh_key_type),
    password             => hiera("base_user_${user}_password", $users::params::user_password),
    shell                => hiera("base_user_${user}_shell", $users::params::user_shell),
  }
}

#-------------------------------------------------------------------------------

define base::repo ( $repo = $name ) {
  @git::repo { "${repo}.git":
    source               => hiera("base_repo_${repo}_source", $git::params::source),
    revision             => hiera("base_repo_${repo}_revision", $git::params::revision),
    base                 => hiera("base_repo_${repo}_base", $git::params::base),
    post_update_commands => hiera("base_repo_${repo}_post_update_commands", $git::params::post_update_commands),
  }
}
