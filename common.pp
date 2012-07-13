/**
 * Hiera default configurations.
 *
 * These configurations are used as a last resort in puppet nodes and classes
 * in this manifest directory.
 *
 * These are the minimum server configurations needed to bootstrap Puppet and
 * the server environment.  All of these configurations may be overridden
 * once Hiera exists and is properly configured.
 */
class data::common {

  include data::private

  #-----------------------------------------------------------------------------

  $ssh_port                  = 22

  $bootstrap_users           = [ 'root', 'git' ]

  $git_home                  = '/var/git'
  $git_user                  = 'git'
  $git_group                 = 'git'
  $git_init_password         = $data::private::git_init_password

  $config_repo               = 'config.git'
  $config_path               = "${git_home}/${config_repo}"

  $ruby_gems                 = [ 'git', 'hiera', 'hiera-json' ]

  $facts                     = {
    'environment'             => 'production',
  }

  $hiera_common_config       = "${config_path}/common.json"
  $hiera_backends            = [
    {
      'type'                  => 'json',
      'datadir'               => $config_path,
    },
    {
      'type'                  => 'puppet',
      'datasource'            => 'data',
    },
  ]
  $hiera_hierarchy           = [
    '%{hostname}',
    '%{location}',
    '%{environment}',
    '%{server_type}',
    'common'
  ]

  $puppet_repo               = 'puppet.git'
  $puppet_path               = "${git_home}/${puppet_repo}"
  $puppet_manifest_file      = 'site.pp'
  $puppet_manifest_path      = "${puppet_path}/manifests"
  $puppet_manifest           = "${puppet_manifest_path}/${puppet_manifest_file}"
  $puppet_template_path      = "${puppet_path}/templates"
  $puppet_module_paths       = [ "${puppet_path}/modules" ]
  $puppet_source             = $data::private::puppet_source
  $puppet_revision           = 'master'
  $puppet_update_interval    = 30  # Minutes
  $puppet_update_environment = 'PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
  $puppet_update_command     = "puppet apply '${puppet_manifest}'"
}
