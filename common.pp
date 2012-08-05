/**
 * Hiera default configurations.
 *
 * These configurations are used as a last resort in puppet nodes and classes
 * in this manifest directory.
 *
 * These are the minimum server configurations needed to bootstrap Puppet and
 * the server environment.  Configurations that are not prefixed with "os_"
 * may be overridden once Hiera exists and is properly configured.
 *
 * We separate configurations into two logical groupings; hiera configurable,
 * and operating system specific.  Operating system specific configurations
 * are mainly comprised of packages, directories and files, and other
 * confgurations that are unsafe to dynamically change through Hiera over time.
 */
class data::common {

  include data::private

  include git::params
  include puppet::params

  #-----------------------------------------------------------------------------

  $global_facts                 = {
    'environment'                => 'production',
    'server_type'                => 'bootstrap',
  }

  $ssh_port                     = 22
  $ssh_bootstrap_users          = [ 'root', $git::params::user ]

  $os_git_home                  = $git::params::os_home
  $git_init_password            = $data::private::git_init_password

  $ruby_gems                    = [ 'git' ]

  $os_base_config_repo          = 'config.git'
  $os_base_config_dir           = "${os_git_home}/${os_base_config_repo}"

  $os_hiera_common_config       = "${os_base_config_dir}/common.json"
  $os_hiera_backends            = [
    {
      'type'                     => 'json',
      'datadir'                  => $os_base_config_dir,
    },
    {
      'type'                     => 'puppet',
      'datasource'               => 'data',
    },
  ]
  $hiera_hierarchy              = [
    '%{hostname}',
    '%{location}',
    '%{environment}',
    '%{server_type}',
    'common'
  ]

  $os_base_puppet_repo          = 'puppet.git'
  $os_base_puppet_dir           = "${os_git_home}/${os_base_puppet_repo}"
  $base_puppet_source           = $data::private::puppet_source
  $base_puppet_revision         = 'master'

  $os_puppet_manifest_file      = $puppet::params::manifest_file
  $os_puppet_manifest_dir       = $os_base_puppet_dir
  $os_puppet_manifest           = "${os_puppet_manifest_dir}/${os_puppet_manifest_file}"
  $os_puppet_template_dir       = "${os_base_puppet_dir}/templates"
  $os_puppet_module_dirs        = [ "${os_base_puppet_dir}/core/modules", "${os_base_puppet_dir}/modules" ]
  $os_puppet_update_environment = $puppet::params::os_update_environment
  $os_puppet_update_command     = "puppet apply '${os_puppet_manifest}'"

  $os_git_push_commands         = [
    $os_puppet_update_environment,
    $os_puppet_update_command,
  ]
}
