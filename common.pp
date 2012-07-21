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

  include git::params
  include puppet::params

  #-----------------------------------------------------------------------------

  $global_packages           = {
    'main'                    => {
      'present'                 => [
        'build-essential',
        'vim',
        'unzip',
      ],
    },
  }

  $global_facts              = {
    'environment'             => 'production',
    'server_type'             => 'bootstrap',
  }

  $ssh_port                  = 22
  $ssh_bootstrap_users       = [ 'root', $git::params::user ]

  $git_home                  = $git::params::os_home
  $git_init_password         = $data::private::git_init_password

  $ruby_gems                 = [ 'git' ]

  $base_config_repo          = 'config.git'
  $base_config_dir           = "${git_home}/${base_config_repo}"

  #$hiera_common_config       = "${base_config_dir}/common.json"
  $hiera_backends            = [
    {
      'type'                  => 'json',
      'datadir'               => $base_config_dir,
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

  $base_puppet_repo          = 'puppet.git'
  $base_puppet_dir           = "${git_home}/${base_puppet_repo}"
  $base_puppet_source        = $data::private::puppet_source
  $base_puppet_revision      = 'master'

  $puppet_manifest_file      = $puppet::params::manifest_file
  $puppet_manifest_dir       = "${base_puppet_dir}/manifests"
  $puppet_manifest           = "${puppet_manifest_dir}/${puppet_manifest_file}"
  $puppet_template_dir       = "${base_puppet_dir}/templates"
  $puppet_module_dirs        = [ "${base_puppet_dir}/modules" ]
  $puppet_update_environment = $puppet::params::os_update_environment
  $puppet_update_command     = "puppet apply '${puppet_manifest}'"
}
