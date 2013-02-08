
class base {

  if ! config_initialized {
    fail('Configuration system (Hiera) is required to install and manage the base profile.')
  }

  #-----------------------------------------------------------------------------
  # Configurations

  $vagrant_user         = global_param('vagrant_user')
  $repos                = global_array('base_repos', [])
  $services             = global_array('base_services', [])
  $users                = global_array('base_users', [])
  $puppet_repo          = global_param('base_puppet_repo')
  $puppet_source        = global_param('base_puppet_source')
  $puppet_revision      = global_param('base_puppet_revision')
  $config_repo          = global_param('base_config_repo')
  $config_source        = global_param('base_config_source')
  $config_revision      = global_param('base_config_revision')
  $post_update_commands = global_param('base_post_update_commands')

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
  include xinetd

  class { 'puppet':
    manifest_file => $data::common::puppet_manifest_file,
    manifest_dir  => $data::common::puppet_manifest_dir,
    template_dir  => $data::common::puppet_template_dir,
    module_dirs   => $data::common::puppet_module_dirs,
  }
  class { 'hiera':
    backends => $data::common::hiera_backends,
  }

  global_include('base_classes')

  #-----------------------------------------------------------------------------
  # Environment

  if $::vagrant_exists {
    users::conf { $vagrant_user: }
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

  #---

  if ! empty($repos) {
    base::repo { $repos: }
  }
  if ! empty($services) {
    base::service { $services: }
  }
  if ! empty($users) {
    base::user { $users: }
  }
}

#*******************************************************************************
# Scalable resources
#*******************************************************************************

define base::service ( $service = $name ) {
  xinetd::service { $service:
    conf_ensure        => global_param("base_service_${service}_conf_ensure", $xinetd::params::service_conf_ensure),
    configure_firewall => global_param("base_service_${service}_configure_firewall", $xinetd::params::service_configure_firewall),
    service_ports      => global_param("base_service_${service}_service_ports", $xinetd::params::service_service_ports),
    port               => global_param("base_service_${service}_port", $xinetd::params::service_port),
    server             => global_param("base_service_${service}_server", $xinetd::params::service_server),
    cps                => global_param("base_service_${service}_cps", $xinetd::params::service_cps),
    flags              => global_param("base_service_${service}_flags", $xinetd::params::service_flags),
    log_on_failure     => global_param("base_service_${service}_log_on_failure", $xinetd::params::service_log_on_failure),
    per_source         => global_param("base_service_${service}_per_source", $xinetd::params::service_per_source),
    server_args        => global_param("base_service_${service}_server_args", $xinetd::params::service_server_args),
    disable            => global_param("base_service_${service}_disable", $xinetd::params::service_disable),
    socket_type        => global_param("base_service_${service}_socket_type", $xinetd::params::service_socket_type),
    protocol           => global_param("base_service_${service}_protocol", $xinetd::params::service_protocol),
    user               => global_param("base_service_${service}_user", $xinetd::params::service_user),
    group              => global_param("base_service_${service}_group", $xinetd::params::service_group),
    instances          => global_param("base_service_${service}_instances", $xinetd::params::service_instances),
    wait               => global_param("base_service_${service}_wait", $xinetd::params::service_wait),
    bind               => global_param("base_service_${service}_bind", $xinetd::params::service_bind),
    service_type       => global_param("base_service_${service}_service_type", $xinetd::params::service_type),
  }
}

#-------------------------------------------------------------------------------

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
