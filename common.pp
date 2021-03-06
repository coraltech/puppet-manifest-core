/**
 * Hiera default configurations.
 *
 * These configurations are used as a last resort in puppet nodes and classes
 * in this manifest directory.
 */
class data::common {

  include data::private

  include git::params
  include puppet::params

  #-----------------------------------------------------------------------------

  $global_facts                 = {
    'server_identity'            => 'test',
    'server_stage'               => 'bootstrap',
    'server_type'                => 'core',
  }

  $vagrant_user                 = 'vagrant'

  $ssh_port                     = 22

  if $::vagrant_exists {
    $ssh_bootstrap_users        = [ 'root', $git::params::user , $vagrant_user ]
  }
  else {
    $ssh_bootstrap_users        = [ 'root', $git::params::user ]
  }

  $sudo_permissions             = [ "git ALL=NOPASSWD:${puppet::params::bin}" ]

  $git_home                     = $git::params::home
  $git_init_password            = $data::private::git_init_password

  $ruby_gems                    = [ 'coral' ]

  $base_config_repo             = 'config.git'
  $base_config_dir              = "${git_home}/${base_config_repo}"

  $config_address               = "git@${::fqdn}:${base_config_repo}"
  $common_config                = "${base_config_dir}/common.json"

  $hiera_backends               = [
    {
      'type'                     => 'json',
      'datadir'                  => $base_config_dir,
    },
    {
      'type'                     => 'puppet',
      'datasource'               => 'data',
    },
  ]
  $hiera_hierarchy              = [
    "identity/%{::server_identity}/%{::server_stage}",
    "identity/%{::server_identity}",
    "server/%{::server_environment}/%{::server_location}/%{::hostname}/%{::server_stage}",
    "server/%{::server_environment}/%{::server_location}/%{::hostname}",
    "server/%{::server_environment}/%{::hostname}/%{::server_stage}",
    "server/%{::server_environment}/%{::hostname}",
    "server/%{::hostname}/%{::server_stage}",
    "server/%{::hostname}",
    "location/%{::server_location}/%{::server_stage}",
    "location/%{::server_location}",
    "environment/%{::server_environment}/%{::server_stage}",
    "environment/%{::server_environment}",
    "stage/%{::server_stage}",
    "type/%{::server_type}",
    "common"
  ]

  $base_puppet_repo             = 'puppet.git'
  $base_puppet_dir              = "${git_home}/${base_puppet_repo}"
  $base_puppet_source           = $data::private::puppet_source
  $base_puppet_revision         = 'master'

  $puppet_manifest_file         = $puppet::params::manifest_file
  $puppet_manifest_dir          = $base_puppet_dir
  $puppet_manifest              = "${puppet_manifest_dir}/${puppet_manifest_file}"
  $puppet_template_dir          = "${base_puppet_dir}/templates"
  $puppet_module_dirs           = [ "${base_puppet_dir}/core/modules", "${base_puppet_dir}/modules" ]
  $puppet_update_environment    = $puppet::params::update_environment
  $puppet_update_command        = "sudo puppet apply '${puppet_manifest}'"

  $base_post_update_commands    = [
    $puppet_update_environment,
    $puppet_update_command,
  ]

  $base_classes = []
}
